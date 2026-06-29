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

local QteConfig = Config.Qte
-- Bonus de l'attaque parfaite : source unique dans CombatConfig (pas de duplication).
local PERFECT_BONUS = Config.Combat.PERFECT_ATTACK_DAMAGE_BONUS

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
--   * tous en jaune                         -> Perfect (+20 %) ;
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

return Qte
