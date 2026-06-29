--!strict
-- EpeisteConfig
-- Kit Épéiste niveau 1 (provisoire) — placeholders issus de docs/design-decisions.md.
-- Aucune logique de combat ici : seulement des données de configuration.

local EpeisteConfig = {
	-- Statistiques de départ.
	STATS = {
		MAX_HP = 30,
		CLAIRVOYANCE = 5,
		START_ESSENCE = 0,
	},

	-- Compétences équipées (placeholder ; les QTE/profils détaillés viendront plus tard).
	SKILLS = {
		Taille = {
			displayName = "Taille",
			essenceCost = 0,
			damage = 3,
			offensiveCursors = 2,
			cooldownPersonalTurns = 0,
			grantsEssenceIfNotCancelled = true,
			isBaseAttack = true,
		},
		Fente = {
			displayName = "Fente",
			essenceCost = 2,
			damage = 5,
			offensiveCursors = 3,
			cooldownPersonalTurns = 2,
		},
		EntailleCroisee = {
			displayName = "Entaille croisée",
			essenceCost = 3,
			-- Deux frappes indépendantes de 3 dégâts, deux curseurs chacune.
			strikes = 2,
			damagePerStrike = 3,
			offensiveCursorsPerStrike = 2,
			cooldownPersonalTurns = 3,
		},
		PostureDuDuelliste = {
			displayName = "Posture du duelliste",
			essenceCost = 2,
			cooldownPersonalTurns = 4,
			-- Agrandit de 50 % la zone jaune du prochain QTE défensif.
			yellowZoneBonus = 0.50,
			damage = 0,
		},
	},
}

return EpeisteConfig
