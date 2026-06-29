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
		hp = 0,
		maxHp = 0,
		essence = 0,
		essenceMax = ESSENCE_MAX,
		soulFragments = 0,
		gold = 0,
		crystals = 0,

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
	data.maxHp = math.max(0, data.maxHp)
	data.hp = math.clamp(data.hp, 0, math.max(data.maxHp, data.hp))
	data.soulFragments = math.clamp(data.soulFragments, 0, UI.SOUL_FRAGMENTS)
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
