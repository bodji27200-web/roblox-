--!strict
-- Client (point d'entrée client)
-- Lot 01 — Fondation : client minimal. Aucune UI ni logique de combat ici.
-- Vérifie seulement l'accès à la configuration partagée et journalise son démarrage.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

print(("[Client] Fondation prête (Essence max = %d, durée du tour = %ds)."):format(
	Config.Essence.MAX,
	Config.Combat.TURN_CHOICE_SECONDS
))
