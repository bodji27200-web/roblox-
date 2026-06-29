--!strict
-- CombatConfig
-- Constantes générales du combat au tour par tour actif.
-- Valeurs de placeholder issues de docs/design-decisions.md (prototype, à rééquilibrer).
-- Aucune logique ici : uniquement des données configurables centralisées.

local CombatConfig = {
	-- Durée (secondes) accordée au joueur pour choisir son action avant
	-- d'utiliser Garde automatiquement.
	TURN_CHOICE_SECONDS = 20,

	-- La Clairvoyance est le facteur principal de l'initiative.
	-- Les égalités sont départagées côté serveur (placeholder, lots suivants).
	INITIATIVE_STAT = "Clairvoyance",

	-- Action appliquée automatiquement quand le timer du joueur expire.
	AUTO_TIMEOUT_ACTION = "Garde",

	-- Action neutre par défaut d'un ennemi tant qu'aucune IA n'est branchée (lot 08).
	ENEMY_DEFAULT_ACTION = "Attendre",

	-- Absorptions de défense (proportion des dégâts absorbés).
	DEFENSE = {
		RED_ZONE_ABSORB = 0.50, -- défense normale (zone rouge)
		PERFECT_PARRY_ABSORB = 1.00, -- parade parfaite (zone jaune)
		GUARD_ABSORB = 0.70, -- action Garde
	},

	-- Malus appliqué après Méditer, jusqu'au prochain tour personnel.
	MEDITATE_MALUS = {
		RED_ZONE_ABSORB = 0.30,
		GUARD_ABSORB = 0.50,
		-- La parade parfaite (jaune) reste inchangée.
	},

	-- Dégâts : pour le prototype, arrondir les dégâts restants vers le haut ;
	-- une attaque non totalement annulée inflige au minimum 1 dégât.
	DAMAGE = {
		MIN_DAMAGE_IF_NOT_CANCELLED = 1,
		ROUND_REMAINING_UP = true,
	},

	-- Bonus de l'attaque parfaite (QTE offensif).
	PERFECT_ATTACK_DAMAGE_BONUS = 0.20,
}

return CombatConfig
