--!strict
-- Server (point d'entrée serveur)
-- Lot 01 — Fondation : initialise les remotes (vides) et génère la zone de test
-- avec les deux déclencheurs « Loup » et « Bandit ». Aucune logique de combat.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))

local TestZone = require(script:WaitForChild("TestZone"))

-- Réserve les RemoteEvents/Functions (vides) pour les lots suivants.
Remotes.init()

-- Construit la zone de test et ses déclencheurs.
TestZone.build()

print("[Server] Fondation du prototype de combat prête (zone de test générée).")
