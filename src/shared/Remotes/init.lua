--!strict
-- Remotes
-- Déclaration centralisée (et vide) des RemoteEvents / RemoteFunctions du combat.
-- Aucune logique réseau n'est branchée ici : on se contente de réserver les noms
-- et de fournir un accès get-or-create commun au serveur et au client.
-- Les handlers seront ajoutés par les lots suivants.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Noms réservés (vides pour l'instant). Catalogue volontairement minimal.
local EVENTS: { string } = {
	"CombatTriggered", -- un déclencheur (Loup/Bandit) a été activé
	-- Lot 02 — hooks réseau neutres pour le moteur de combat.
	-- Serveur -> client : notifie l'état courant de la session (UI branchée au lot 03).
	"CombatStateChanged",
	-- Client -> serveur : le joueur soumet son action de tour (validée serveur).
	"PlayerCombatAction",
	-- Lot 04 — Serveur -> client : instantané autoritaire des ressources du joueur
	-- (Essence, coûts/recharges des actions, chronomètre du tour). Affichage seul.
	"CombatResourcesChanged",
	-- Lot 05 — Client -> serveur : résultat saisi d'un QTE offensif (action + positions
	-- des curseurs). Le serveur recalcule le verdict de façon autoritaire.
	"PlayerOffensiveQte",
	-- Lot 05 — Serveur -> client : verdict autoritaire du QTE offensif (résultat,
	-- multiplicateur, dégâts) pour l'affichage et l'animation d'échec.
	"OffensiveQteOutcome",
}

local FUNCTIONS: { string } = {
	-- (aucune RemoteFunction nécessaire pour le lot de fondation)
}

local FOLDER_NAME = "CombatRemotes"

local Remotes = {}

-- Retourne le dossier des remotes, en le créant côté serveur si besoin.
local function getFolder(): Instance
	local existing = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
	if existing then
		return existing
	end

	if RunService:IsServer() then
		local folder = Instance.new("Folder")
		folder.Name = FOLDER_NAME
		folder.Parent = ReplicatedStorage
		return folder
	end

	-- Côté client : attendre que le serveur l'ait créé.
	return ReplicatedStorage:WaitForChild(FOLDER_NAME)
end

local function ensureChild(folder: Instance, name: string, className: string): Instance
	local existing = folder:FindFirstChild(name)
	if existing then
		return existing
	end

	if RunService:IsServer() then
		local remote = Instance.new(className)
		remote.Name = name
		remote.Parent = folder
		return remote
	end

	return folder:WaitForChild(name)
end

-- À appeler une fois côté serveur pour matérialiser les remotes réservés (vides).
function Remotes.init(): ()
	local folder = getFolder()
	for _, name in EVENTS do
		ensureChild(folder, name, "RemoteEvent")
	end
	for _, name in FUNCTIONS do
		ensureChild(folder, name, "RemoteFunction")
	end
end

-- Accès générique à un remote par son nom (serveur ou client).
function Remotes.get(name: string): Instance
	return ensureChild(getFolder(), name, "RemoteEvent")
end

return Remotes
