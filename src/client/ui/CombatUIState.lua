--!strict
-- CombatUIState
-- Lot 03 — Modèle d'état local de l'interface de combat (côté client).
-- Centralise ce que l'UI affiche et notifie les composants quand l'état change.
--
-- Rôle : l'UI ne décide rien d'autorité. Cet état est alimenté par :
--   * l'événement serveur « CombatStateChanged » (lot 02) pour la phase et la manche ;
--   * une API publique d'affichage (`applyDisplay`) pour les valeurs encore non
--     exposées par le serveur (PV, Essence, fragments, or, cristaux). Ces valeurs
--     pourront être branchées sur le serveur dans un lot ultérieur sans changer l'UI.
--
-- Tant qu'aucune donnée n'arrive, l'état reste neutre (HUD lisible, aucune erreur).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local UI = Config.UI
local ESSENCE_MAX = Config.Essence.MAX
-- Valeurs temporaires du prototype affichées tant que le serveur n'a rien répliqué.
-- Centralisées en configuration : aucune duplication en dur ici.
local ESSENCE_START = Config.Essence.START_OF_COMBAT
local EPEISTE_MAX_HP = Config.Epeiste.STATS.MAX_HP
local SOUL_FRAGMENTS = UI.SOUL_FRAGMENTS
local TURN_SECONDS = Config.Combat.TURN_CHOICE_SECONDS

export type TurnEntry = {
	name: string,
	side: string, -- "Player" | "Enemy"
	isCurrent: boolean,
}

export type DisplayState = {
	-- Phase exposée par le serveur (lot 02). "Idle" = aucun combat en cours.
	combatState: string,
	round: number,
	inCombat: boolean,
	-- Vrai uniquement quand le joueur doit choisir une action (active les boutons).
	canAct: boolean,

	-- Bloc « personnage » du HUD (valeurs d'affichage, neutres par défaut).
	characterName: string,
	masteryLevel: number,
	hp: number,
	maxHp: number,
	essence: number,
	essenceMax: number,
	soulFragments: number, -- nombre de fragments possédés (0..SOUL_FRAGMENTS)
	gold: number,
	crystals: number,

	-- Lot 04 — Données de ressources répliquées (affichage des coûts/recharges/durée).
	-- Par action : { cost, cooldownRemaining, available }. Vide tant qu'aucun combat.
	actions: { [string]: any },
	-- Horodatage serveur synchronisé de fin du tour (chronomètre), ou nil hors tour.
	turnEndsAt: number?,
	turnSeconds: number,

	-- Lot 06 — États défensifs courants répliqués par le serveur (bannières d'affichage).
	guardActive: boolean,
	meditateMalus: boolean,

	turnOrder: { TurnEntry },
	messages: { string },
}

local CombatUIState = {}
CombatUIState.__index = CombatUIState

export type State = typeof(setmetatable(
	{} :: {
		_data: DisplayState,
		_listeners: { (DisplayState) -> () },
	},
	CombatUIState
))

-- État neutre par défaut : aucun combat, HUD lisible sans aucune donnée serveur.
local function defaultData(): DisplayState
	return {
		combatState = "Idle",
		round = 0,
		inCombat = false,
		canAct = false,

		characterName = "—",
		masteryLevel = UI.DEFAULT_MASTERY_LEVEL,
		-- Valeurs temporaires du prototype (PV 30/30, Essence 0/6, 3 fragments d'âme)
		-- issues de la configuration, en attendant la réplication serveur.
		hp = EPEISTE_MAX_HP,
		maxHp = EPEISTE_MAX_HP,
		essence = ESSENCE_START,
		essenceMax = ESSENCE_MAX,
		soulFragments = SOUL_FRAGMENTS,
		gold = 0,
		crystals = 0,

		actions = {},
		turnEndsAt = nil,
		turnSeconds = TURN_SECONDS,

		guardActive = false,
		meditateMalus = false,

		turnOrder = {},
		messages = {},
	}
end

function CombatUIState.new(): State
	local self = setmetatable({
		_data = defaultData(),
		_listeners = {},
	}, CombatUIState)
	return (self :: any) :: State
end

function CombatUIState.get(self: State): DisplayState
	return self._data
end

-- Abonne un composant ; renvoie une fonction de désabonnement. Notifie immédiatement.
function CombatUIState.subscribe(self: State, fn: (DisplayState) -> ()): () -> ()
	table.insert(self._listeners, fn)
	fn(self._data)
	return function()
		local index = table.find(self._listeners, fn)
		if index then
			table.remove(self._listeners, index)
		end
	end
end

function CombatUIState._notify(self: State)
	for _, fn in self._listeners do
		fn(self._data)
	end
end

-- Applique la charge utile « CombatStateChanged » du serveur (lot 02).
-- Payload attendu : { sessionId, state, round }. Robuste aux champs manquants.
function CombatUIState.applyServerState(self: State, payload: { [string]: any })
	local data = self._data
	local state = if type(payload.state) == "string" then payload.state else data.combatState
	data.combatState = state
	data.round = if type(payload.round) == "number" then payload.round else data.round

	local terminal = state == "Victory" or state == "Defeat" or state == "Escaped"
	data.inCombat = state ~= "Idle" and state ~= "Cleanup" and not terminal
	data.canAct = state == "ChoosingAction"

	if state == "Idle" or state == "Cleanup" then
		-- Retour au repos : on remet l'ordre des tours à neutre (HUD reste lisible).
		data.turnOrder = {}
	end

	-- Lot 06 — Hors combat (repos ou issue terminale) : aucune bannière défensive résiduelle.
	if not data.inCombat then
		data.guardActive = false
		data.meditateMalus = false
	end

	self:_notify()
end

-- Met à jour les valeurs d'affichage (PV, Essence, fragments, or, cristaux, nom…).
-- Utilisé pour brancher des données (futur serveur) ou pour simuler en test manuel.
-- `partial` ne contient que les champs à changer.
function CombatUIState.applyDisplay(self: State, partial: { [string]: any })
	local data = self._data
	for key, value in partial do
		(data :: any)[key] = value
	end
	-- Bornage défensif des valeurs visibles (évite des barres incohérentes).
	data.essenceMax = math.max(1, data.essenceMax)
	data.essence = math.clamp(data.essence, 0, data.essenceMax)
	-- PV : les PV affichés ne dépassent jamais les PV maximum.
	-- maxHp > 0 -> hp borné entre 0 et maxHp ; maxHp <= 0 -> affichage neutre (0).
	data.maxHp = math.max(0, data.maxHp)
	if data.maxHp > 0 then
		data.hp = math.clamp(data.hp, 0, data.maxHp)
	else
		data.hp = 0
	end
	data.soulFragments = math.clamp(data.soulFragments, 0, UI.SOUL_FRAGMENTS)
	self:_notify()
end

-- Applique l'instantané de ressources répliqué par le serveur (lot 04).
-- Payload : { essence, essenceMax, turnEndsAt, turnSeconds, actions }. Robuste aux
-- champs manquants. C'est la source autoritaire de l'Essence et des coûts/recharges
-- affichés (l'API de simulation reste réservée aux tests manuels Studio).
function CombatUIState.applyResources(self: State, payload: { [string]: any })
	local data = self._data
	-- Lot 06 (correctif) — PV répliqués par le serveur autoritaire. Lus puis bornés ci-dessous,
	-- ils permettent au HUD de refléter immédiatement les dégâts subis (le `_notify` final
	-- redessine le HUD sans attendre un changement de tour).
	if type(payload.maxHp) == "number" then
		data.maxHp = payload.maxHp
	end
	if type(payload.hp) == "number" then
		data.hp = payload.hp
	end
	if type(payload.essence) == "number" then
		data.essence = payload.essence
	end
	if type(payload.essenceMax) == "number" then
		data.essenceMax = payload.essenceMax
	end
	data.turnEndsAt = if type(payload.turnEndsAt) == "number" then payload.turnEndsAt else nil
	if type(payload.turnSeconds) == "number" then
		data.turnSeconds = payload.turnSeconds
	end
	if type(payload.actions) == "table" then
		data.actions = payload.actions
	end

	-- Lot 06 — États défensifs courants (bannières Garde / malus de Méditer).
	if type(payload.guardActive) == "boolean" then
		data.guardActive = payload.guardActive
	end
	if type(payload.meditateMalus) == "boolean" then
		data.meditateMalus = payload.meditateMalus
	end

	-- Bornage défensif identique à applyDisplay (cohérence d'affichage).
	data.essenceMax = math.max(1, data.essenceMax)
	data.essence = math.clamp(data.essence, 0, data.essenceMax)
	-- PV : maxHp >= 0 ; hp borné dans [0, maxHp] (ou 0 si maxHp nul) — jamais de barre incohérente.
	data.maxHp = math.max(0, data.maxHp)
	if data.maxHp > 0 then
		data.hp = math.clamp(data.hp, 0, data.maxHp)
	else
		data.hp = 0
	end
	self:_notify()
end

-- Remplace l'ordre des tours affiché en haut.
function CombatUIState.setTurnOrder(self: State, entries: { TurnEntry })
	self._data.turnOrder = entries
	self:_notify()
end

-- Ajoute un message dans la zone centrale (journal de combat), borné en taille.
function CombatUIState.pushMessage(self: State, message: string)
	local messages = self._data.messages
	table.insert(messages, message)
	while #messages > UI.Layout.MaxMessages do
		table.remove(messages, 1)
	end
	self:_notify()
end

return CombatUIState
