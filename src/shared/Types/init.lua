--!strict
-- Types
-- Structures de données de base du combat (fondation pour les lots suivants).
-- Ce module n'exporte que des types Luau : aucune logique, aucune valeur runtime.
-- Référence : docs/design-decisions.md.

export type CreatureKind = "Loup" | "Bandit"

-- Camp d'un combattant (le prototype est solo mais le code prévoit le multijoueur).
export type Side = "Player" | "Enemy"

-- Statistiques de base communes à tous les combattants.
export type CombatantStats = {
	maxHp: number,
	hp: number,
	clairvoyance: number,
	essence: number,
}

-- Définition d'une compétence (données seulement ; QTE détaillés plus tard).
export type Skill = {
	id: string,
	displayName: string,
	essenceCost: number,
	damage: number?,
	cooldownPersonalTurns: number,
	offensiveCursors: number?,
}

-- Un combattant générique (joueur ou ennemi).
export type Combatant = {
	id: string,
	displayName: string,
	side: Side,
	stats: CombatantStats,
}

-- Résultat possible d'un QTE défensif (voir design-decisions : zones rouge/jaune/hors).
export type DefenseOutcome = "PerfectParry" | "Normal" | "Miss"

-- Résultat possible d'un QTE offensif.
export type AttackOutcome = "Perfect" | "Normal" | "Cancelled"

-- Lot 02 — Moteur de combat et tours.
-- États possibles de la machine à états d'une session de combat (serveur autoritaire).
export type CombatState =
	"Idle"
	| "Starting"
	| "ChoosingAction"
	| "ResolvingAction"
	| "Defending"
	| "RoundEnd"
	| "Victory"
	| "Defeat"
	| "Escaped"
	| "Cleanup"

-- Issue terminale d'un combat (sous-ensemble des états terminaux non-Cleanup).
export type CombatResult = "Victory" | "Defeat" | "Escaped"

-- Un combattant tel que suivi par le moteur de combat côté serveur.
-- (Étend le Combatant statique avec l'état runtime nécessaire au moteur de tours.)
export type CombatParticipant = {
	id: string,
	displayName: string,
	side: Side,
	clairvoyance: number,
	maxHp: number,
	hp: number,
	-- Référence joueur (côté "Player") ou modèle d'ennemi (côté "Enemy").
	player: Player?,
	model: Instance?,
	-- État de manche : Garde active et verrou anti double-action.
	isGuarding: boolean,
	hasActedThisRound: boolean,
	-- Lot 04 — Ressource Essence et recharges, autoritaires côté serveur.
	essence: number,
	-- Recharge restante par action (en tours personnels). 0/absent = disponible.
	cooldowns: { [string]: number },
	-- Nombre de tours personnels déjà joués par ce combattant.
	personalTurns: number,
}

-- Lot 04 — Disponibilité d'une action telle que répliquée au client (affichage).
export type ActionAvailability = {
	cost: number,
	cooldownRemaining: number,
	available: boolean,
}

-- Lot 04 — Instantané des ressources du joueur, répliqué côté client (affichage seul).
export type CombatResources = {
	sessionId: string,
	essence: number,
	essenceMax: number,
	-- Horodatage serveur synchronisé de la fin du tour (chronomètre), ou nil hors tour.
	turnEndsAt: number?,
	turnSeconds: number,
	actions: { [string]: ActionAvailability },
}

-- Type vide retourné par ce module : seuls les types exportés ci-dessus sont utilisés.
local Types = {}

return Types
