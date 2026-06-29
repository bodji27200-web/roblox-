--!strict
-- CreaturesConfig
-- Créatures de test (provisoire) — placeholders issus de docs/design-decisions.md.
-- Sert de base aux déclencheurs « Loup » et « Bandit » de la zone de test.
-- Aucune IA ni logique de combat ici : seulement des données de configuration.

local CreaturesConfig = {
	Loup = {
		displayName = "Loup gris",
		level = 1,
		maxHp = 16,
		clairvoyance = 7,
		-- Ne peut pas parer (arme) ; esquive adaptée à son anatomie.
		canArmedParry = false,
		skills = {
			Morsure = { displayName = "Morsure", damage = 3, cooldownPersonalTurns = 0 },
			Bond = { displayName = "Bond", damage = 5, cooldownPersonalTurns = 2 },
		},
	},

	Bandit = {
		displayName = "Bandit égaré",
		level = 1,
		maxHp = 22,
		clairvoyance = 5,
		-- Peut défendre, garder, parer parfaitement, riposter et contre-parer.
		canArmedParry = true,
		skills = {
			CoupDEpee = { displayName = "Coup d'épée", damage = 4, cooldownPersonalTurns = 0 },
			FrappeLourde = { displayName = "Frappe lourde", damage = 7, cooldownPersonalTurns = 3 },
		},
	},
}

return CreaturesConfig
