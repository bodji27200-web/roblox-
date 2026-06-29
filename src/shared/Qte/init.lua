--!strict
-- Qte (logique partagée du QTE offensif)
-- Lot 05 — Règles de résultat du QTE offensif, mutualisées entre le client (affichage
-- immédiat du verdict) et le serveur (validation autoritaire). Une seule implémentation
-- des règles évite toute divergence : le serveur recalcule le verdict à partir des
-- positions transmises et n'accepte jamais un verdict « prêt à l'emploi » du client.
--
-- Aucune dépendance à Roblox ici (sauf la lecture de la configuration) : ce module ne
-- fait que classer des positions et appliquer les règles validées du lot.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Types = require(Shared:WaitForChild("Types"))

type OffensiveQteProfile = Types.OffensiveQteProfile
type OffensiveQteResult = Types.OffensiveQteResult
type QteZone = Types.QteZone
-- Lot 06 — Types du QTE défensif (curseur unique) et de la résolution de défense.
type DefensiveQteProfile = Types.DefensiveQteProfile
type DefenseOutcome = Types.DefenseOutcome
type DefenseResolution = Types.DefenseResolution

local QteConfig = Config.Qte
-- Bonus de l'attaque parfaite : source unique dans CombatConfig (pas de duplication).
local PERFECT_BONUS = Config.Combat.PERFECT_ATTACK_DAMAGE_BONUS

-- Lot 06 — Pourcentages d'absorption et règles de dégâts, centralisés en configuration.
local DEFENSE = Config.Combat.DEFENSE
local MEDITATE_MALUS = Config.Combat.MEDITATE_MALUS
local DAMAGE = Config.Combat.DAMAGE
local DefensiveConfig = QteConfig.Defensive

local Qte = {}

-- Résout le profil de QTE offensif associé à une action/compétence, ou nil si
-- l'action n'a pas de QTE offensif. Client et serveur utilisent ce même résolveur.
function Qte.profileForAction(action: string): OffensiveQteProfile?
	local profileName = QteConfig.ProfileByAction[action]
	if not profileName then
		return nil
	end
	return QteConfig.Profiles[profileName]
end

-- Classe une position normalisée [0, 1] selon les zones d'un profil.
-- Une position absente (curseur non arrêté) est traitée comme « hors zone ».
function Qte.classify(profile: OffensiveQteProfile, position: number?): QteZone
	if type(position) ~= "number" then
		return "out"
	end
	local distance = math.abs(position - profile.center)
	if distance <= profile.yellowHalfWidth then
		return "yellow"
	elseif distance <= profile.redHalfWidth then
		return "red"
	end
	return "out"
end

-- Calcule le résultat d'un QTE offensif à partir des positions arrêtées.
-- `positions` : tableau de longueur profile.cursorCount, chaque entrée number|nil.
-- Règles (validées) :
--   * tous en jaune                         -> Perfect (bonus parfait configuré) ;
--   * aucun hors zone et au plus un rouge   -> Normal ;
--   * deux rouges ou plus                   -> Cancelled ;
--   * au moins un hors zone                 -> Cancelled (annulation immédiate côté UI).
function Qte.computeOutcome(profile: OffensiveQteProfile, positions: { number? }): OffensiveQteResult
	local zones: { QteZone } = {}
	local outCount, redCount = 0, 0

	for i = 1, profile.cursorCount do
		local zone = Qte.classify(profile, positions[i])
		zones[i] = zone
		if zone == "out" then
			outCount += 1
		elseif zone == "red" then
			redCount += 1
		end
	end

	local outcome: Types.AttackOutcome
	if outCount >= 1 then
		-- Un seul curseur hors de la zone rouge suffit à annuler.
		outcome = "Cancelled"
	elseif redCount >= 2 then
		-- Deux rouges ou plus : annulation.
		outcome = "Cancelled"
	elseif redCount == 0 then
		-- Aucun hors zone, aucun rouge : tous les curseurs sont jaunes.
		outcome = "Perfect"
	else
		-- Aucun hors zone, exactement un rouge : attaque normale.
		outcome = "Normal"
	end

	local cancelled = outcome == "Cancelled"
	local multiplier
	if cancelled then
		multiplier = 0
	elseif outcome == "Perfect" then
		multiplier = 1 + PERFECT_BONUS
	else
		multiplier = 1
	end

	return {
		zones = zones,
		outcome = outcome,
		multiplier = multiplier,
		cancelled = cancelled,
	}
end

-- ---------------------------------------------------------------------------
-- QTE défensif (Lot 06) — curseur unique, mêmes principes sécurisés que l'offensif
-- ---------------------------------------------------------------------------

-- Résout un profil de QTE défensif par son nom (source unique : configuration). Client
-- et serveur l'utilisent : le serveur classe la position avec ce même profil, donc aucun
-- risque de divergence avec le rendu client.
function Qte.defensiveProfileByName(name: string?): DefensiveQteProfile?
	if type(name) ~= "string" then
		return nil
	end
	return DefensiveConfig.Profiles[name]
end

-- Résout le profil défensif d'un contexte d'attaque (défaut si contexte absent/inconnu).
-- Renvoie (profil, nomDuProfil) : le serveur transmet le nom au client dans le défi.
function Qte.defensiveProfile(context: string?): (DefensiveQteProfile?, string)
	local key = if type(context) == "string" then context else "Default"
	local name = DefensiveConfig.ProfileByContext[key] or DefensiveConfig.DefaultProfile
	return DefensiveConfig.Profiles[name], name
end

-- Traduit une zone de défense en libellé de résultat (UI/journal). La logique de zones
-- est partagée avec `classify` : jaune = parade parfaite, rouge = défense normale,
-- hors zone = échec.
function Qte.defenseOutcomeForZone(zone: QteZone): DefenseOutcome
	if zone == "yellow" then
		return "PerfectParry"
	elseif zone == "red" then
		return "Normal"
	end
	return "Miss"
end

-- Calcul AUTORITAIRE et pur des dégâts défensifs (utilisé côté serveur). Centralise la
-- sélection de l'absorption (zone/Garde, avec ou sans malus de Méditer), l'arrondi vers
-- le haut et le plancher de 1 dégât. Aucune dépendance Roblox : entièrement testable.
--
-- params :
--   * rawDamage     : dégâts bruts entrants (> 0 attendu ; <= 0 -> 0 dégât).
--   * mode          : "guard" (Garde, sans QTE) ou "qte" (défense universelle).
--   * zone          : zone touchée si mode == "qte" ("yellow" | "red" | "out").
--   * meditateMalus : vrai si le malus de Méditer est actif sur le défenseur.
--
-- Règles (validées, design-decisions.md) :
--   * jaune  -> parade parfaite : 100 % absorbé, 0 dégât, AUCUN effet secondaire ;
--   * rouge  -> 50 % absorbé (30 % sous malus), effets secondaires applicables ;
--   * out    -> 0 % absorbé (dégâts complets), effets secondaires applicables ;
--   * Garde  -> 70 % absorbé (50 % sous malus), effets secondaires applicables.
-- Après absorption : arrondi VERS LE HAUT ; si l'attaque n'est pas totalement annulée,
-- au minimum 1 dégât ; une parade parfaite reste une annulation totale (0 dégât).
function Qte.resolveDefense(params: {
	rawDamage: number,
	mode: string,
	zone: QteZone?,
	meditateMalus: boolean?,
}): DefenseResolution
	local rawDamage = params.rawDamage
	local malus = params.meditateMalus == true

	local absorb = 0
	local perfectParry = false
	local sideEffects = true

	if params.mode == "guard" then
		-- Garde : 70 % (50 % sous malus). Le corps est touché : effets secondaires applicables.
		absorb = if malus then MEDITATE_MALUS.GUARD_ABSORB else DEFENSE.GUARD_ABSORB
		sideEffects = true
	else
		local zone = params.zone
		if zone == "yellow" then
			-- Parade parfaite : annulation totale, aucun effet secondaire.
			perfectParry = true
			absorb = DEFENSE.PERFECT_PARRY_ABSORB
			sideEffects = false
		elseif zone == "red" then
			-- Défense normale : 50 % (30 % sous malus). Effets secondaires applicables.
			absorb = if malus then MEDITATE_MALUS.RED_ZONE_ABSORB else DEFENSE.RED_ZONE_ABSORB
			sideEffects = true
		else
			-- Hors zone : dégâts complets. Effets secondaires applicables.
			absorb = 0
			sideEffects = true
		end
	end

	local damage: number
	if perfectParry then
		-- Parade parfaite : annulation totale (jamais de plancher de 1).
		damage = 0
	else
		local remaining = rawDamage * (1 - absorb)
		damage = if DAMAGE.ROUND_REMAINING_UP then math.ceil(remaining) else math.floor(remaining)
		if rawDamage > 0 then
			-- Attaque non totalement annulée : au minimum 1 dégât (même si l'arrondi donne 0).
			damage = math.max(damage, DAMAGE.MIN_DAMAGE_IF_NOT_CANCELLED)
		else
			damage = math.max(0, damage)
		end
	end

	return {
		absorb = absorb,
		perfectParry = perfectParry,
		sideEffects = sideEffects,
		damage = damage,
		cancelled = perfectParry,
	}
end

return Qte
