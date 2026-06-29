--!strict
-- Config (agrégateur)
-- Point d'entrée unique vers la configuration centralisée du prototype.
-- Permet : local Config = require(Shared.Config) ; Config.Combat.MAX ...
-- Aucune valeur en dur ailleurs : tout passe par ces sous-modules.

local Config = {
	Combat = require(script.CombatConfig),
	Essence = require(script.EssenceConfig),
	ActionRules = require(script.ActionRulesConfig),
	Epeiste = require(script.EpeisteConfig),
	Creatures = require(script.CreaturesConfig),
	UI = require(script.UIConfig),
}

return Config
