--!strict
-- Client (point d'entrée client)
-- Lot 01 — Fondation : accès à la configuration partagée.
-- Lot 03 — Démarre l'interface de combat (HUD, menu d'actions, ordre des tours,
-- zone centrale) branchée sur l'état exposé par le serveur (lot 02).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

print(("[Client] Fondation prête (Essence max = %d, durée du tour = %ds)."):format(
	Config.Essence.MAX,
	Config.Combat.TURN_CHOICE_SECONDS
))

-- Lot 03 — Interface de combat.
local CombatUI = require(script:WaitForChild("ui"))
local ui = CombatUI.new()
ui:start()

-- Exposé pour les tests manuels (Studio) : _G.CombatUI:simulate({ hp = 18, ... }).
_G.CombatUI = ui

-- Lot 05 — Outil développeur : ralentir/accélérer le QTE offensif pendant les tests.
-- Exemples : _G.OffensiveQte.setSpeed(0.5) ralentit ; _G.OffensiveQte.setSpeed(2) accélère.
_G.OffensiveQte = {
	setSpeed = function(multiplier: number): number
		local applied = ui.qte:setSpeedMultiplier(multiplier)
		print(("[OffensiveQte] Vitesse du QTE réglée à x%.2f."):format(applied))
		return applied
	end,
	getSpeed = function(): number
		return ui.qte:getSpeedMultiplier()
	end,
}

-- Lot 06 — Outil développeur : ralentir/accélérer le QTE défensif pendant les tests
-- (le curseur unique va vite : un ralenti aide à viser les zones jaune/rouge). Pour
-- déclencher une attaque entrante de test, utiliser _G.CombatDev.attackPlayer(...) côté
-- SERVEUR (console serveur Studio).
_G.DefensiveQte = {
	setSpeed = function(multiplier: number): number
		local applied = ui.defensiveQte:setSpeedMultiplier(multiplier)
		print(("[DefensiveQte] Vitesse du QTE défensif réglée à x%.2f."):format(applied))
		return applied
	end,
	getSpeed = function(): number
		return ui.defensiveQte:getSpeedMultiplier()
	end,
}

print("[Client] Interface de combat prête (lot 03) ; QTE offensif (lot 05) et défensif (lot 06) prêts.")
