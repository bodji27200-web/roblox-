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

print("[Client] Interface de combat prête (lot 03).")
