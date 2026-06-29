--!strict
-- EssenceConfig
-- Constantes liées à la ressource Essence.
-- Valeurs de placeholder issues de docs/design-decisions.md (prototype).

local EssenceConfig = {
	MAX = 6, -- maximum, jamais dépassé
	START_OF_COMBAT = 0, -- Essence au début du combat

	-- Gains d'Essence.
	GAIN_PER_PERSONAL_TURN = 1, -- +1 au début de chaque tour personnel
	GAIN_BASE_ATTACK = 1, -- +1 sur attaque de base réussie/normale (0 si annulée)
	GAIN_MEDITATE = 2, -- Méditer : +2

	-- Une parade parfaite, une riposte ou une contre-parade ne donne aucune Essence.
	GAIN_PARRY = 0,
	GAIN_RIPOSTE = 0,
	GAIN_COUNTER_PARRY = 0,
}

return EssenceConfig
