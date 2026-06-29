--!strict
-- Server (point d'entrée serveur)
-- Lot 01 — Fondation : initialise les remotes (vides) et génère la zone de test
-- avec les deux déclencheurs « Loup » et « Bandit ».
-- Lot 02 — Démarre le moteur de combat serveur (branché sur les déclencheurs).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))

local TestZone = require(script:WaitForChild("TestZone"))
local CombatService = require(script:WaitForChild("combat"))

-- Réserve les RemoteEvents/Functions (vides) pour les lots suivants.
Remotes.init()

-- Construit la zone de test et ses déclencheurs.
TestZone.build()

-- Initialise le moteur de combat (câble les déclencheurs Loup/Bandit).
CombatService.init()

print("[Server] Prototype de combat prêt (zone de test + moteur de combat).")
