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

-- Type vide retourné par ce module : seuls les types exportés ci-dessus sont utilisés.
local Types = {}

return Types
