--!strict
-- CombatState
-- Lot 02 — Machine à états du combat (côté serveur, autoritaire).
-- Déclare les états du cycle de vie d'une session et la table de transitions
-- explicites entre eux. Toute transition non listée est refusée (erreur),
-- ce qui garantit un cycle de vie contrôlé de bout en bout.
-- Aucune logique de combat ici : uniquement la structure d'états.

local CombatState = {}

-- Énumération des états (valeurs = noms, pour des logs lisibles).
local States = {
	Idle = "Idle",
	Starting = "Starting",
	ChoosingAction = "ChoosingAction",
	ResolvingAction = "ResolvingAction",
	Defending = "Defending",
	RoundEnd = "RoundEnd",
	Victory = "Victory",
	Defeat = "Defeat",
	Escaped = "Escaped",
	Cleanup = "Cleanup",
}
CombatState.States = States

-- Transitions autorisées : depuis -> { vers = true }.
-- - Starting -> ChoosingAction (premier acteur joueur) ou ResolvingAction (ennemi).
-- - ChoosingAction -> ResolvingAction (action) | Defending (Garde) | Escaped (fuite).
-- - ResolvingAction/Defending -> début du tour suivant (ChoosingAction/ResolvingAction/
--   Defending) ou RoundEnd (dernier combattant).
-- - RoundEnd -> nouvelle manche, ou état terminal (Victory/Defeat/Escaped).
-- - Tous les états actifs peuvent rejoindre Cleanup (ex. déconnexion en plein combat).
-- - Les états terminaux rejoignent Cleanup, puis Cleanup revient à Idle.
local Transitions: { [string]: { [string]: boolean } } = {
	Idle = { Starting = true },
	Starting = { ChoosingAction = true, ResolvingAction = true, Cleanup = true },
	ChoosingAction = { ResolvingAction = true, Defending = true, Escaped = true, Cleanup = true },
	ResolvingAction = {
		ChoosingAction = true,
		ResolvingAction = true,
		Defending = true,
		RoundEnd = true,
		Cleanup = true,
	},
	Defending = {
		ChoosingAction = true,
		ResolvingAction = true,
		Defending = true,
		RoundEnd = true,
		Cleanup = true,
	},
	RoundEnd = {
		ChoosingAction = true,
		ResolvingAction = true,
		Victory = true,
		Defeat = true,
		Escaped = true,
		Cleanup = true,
	},
	Victory = { Cleanup = true },
	Defeat = { Cleanup = true },
	Escaped = { Cleanup = true },
	Cleanup = { Idle = true },
}

export type Machine = {
	get: (Machine) -> string,
	canTransition: (Machine, to: string) -> boolean,
	transition: (Machine, to: string) -> (),
	_current: string,
	_onChange: ((from: string, to: string) -> ())?,
}

-- Crée une machine à états démarrant à Idle.
-- onChange (optionnel) est appelé après chaque transition valide.
function CombatState.new(onChange: ((from: string, to: string) -> ())?): Machine
	local self = {
		_current = States.Idle,
		_onChange = onChange,
	}

	function self:get(): string
		return self._current
	end

	function self:canTransition(to: string): boolean
		local allowed = Transitions[self._current]
		return allowed ~= nil and allowed[to] == true
	end

	function self:transition(to: string): ()
		if not self:canTransition(to) then
			error(("[CombatState] Transition interdite : %s -> %s"):format(tostring(self._current), tostring(to)), 2)
		end
		local from = self._current
		self._current = to
		if self._onChange then
			self._onChange(from, to)
		end
	end

	return (self :: any) :: Machine
end

return CombatState
