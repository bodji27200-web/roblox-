--!strict
-- ActionRulesConfig
-- Lot 04 — Règles génériques par action (coût en Essence, recharge en tours
-- personnels). Données seulement : aucune logique. Le serveur (autoritaire) lit ces
-- règles pour valider les coûts et décompter les recharges.
--
-- Les gains d'Essence restent centralisés dans EssenceConfig ; ici on ne décrit
-- que le COÛT et la RECHARGE, plus des drapeaux pointant vers le bon gain.
--
-- Portée prototype : les cinq actions de base (menu du lot 03) sont gratuites et
-- sans recharge — c'est conforme aux règles (seules les compétences du kit Épéiste,
-- lot 07, portent des coûts/recharges). Le système reste générique : toute action
-- peut recevoir un coût > 0 et/ou une recharge > 0 sans changer le moteur ni l'UI.

local ActionRulesConfig = {
	-- Attaque de base : gratuite, accorde de l'Essence si elle n'est pas annulée.
	Attaque = { essenceCost = 0, cooldownPersonalTurns = 0, isBaseAttack = true },

	-- Garde (défense) : gratuite, aucune recharge, aucun gain.
	Garde = { essenceCost = 0, cooldownPersonalTurns = 0 },

	-- Méditer : gratuite, accorde +2 Essence (voir EssenceConfig.GAIN_MEDITATE).
	["Méditer"] = { essenceCost = 0, cooldownPersonalTurns = 0, isMeditate = true },

	-- Objet : gratuit (la logique d'objets viendra au lot 10).
	Objet = { essenceCost = 0, cooldownPersonalTurns = 0 },

	-- Fuite : gratuite (résolution traitée par le moteur du lot 02).
	Fuite = { essenceCost = 0, cooldownPersonalTurns = 0 },
}

return ActionRulesConfig
