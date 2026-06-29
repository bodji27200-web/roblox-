--!strict
-- TestZone
-- Génère par code une petite zone de test (sans asset externe) et deux
-- déclencheurs visibles « Loup » et « Bandit ».
-- Aucune logique de combat : les déclencheurs n'impriment qu'un log au clic.
-- Les valeurs descriptives proviennent de la configuration centralisée.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local TestZone = {}

local ZONE_NAME = "CombatTestZone"

-- Petite spécification des deux déclencheurs (position + clé de config créature).
local TRIGGERS = {
	{ key = "Loup", color = Color3.fromRGB(120, 120, 130), offset = Vector3.new(-8, 0, 0) },
	{ key = "Bandit", color = Color3.fromRGB(150, 90, 60), offset = Vector3.new(8, 0, 0) },
}

local function makeFloor(parent: Instance): Part
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Anchored = true
	floor.Size = Vector3.new(48, 1, 48)
	floor.Position = Vector3.new(0, 0, 0)
	floor.Color = Color3.fromRGB(70, 80, 70)
	floor.Material = Enum.Material.SmoothPlastic
	floor.TopSurface = Enum.SurfaceType.Smooth
	floor.Parent = parent
	return floor
end

local function makeTrigger(parent: Instance, name: string, color: Color3, position: Vector3): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = Vector3.new(4, 6, 4)
	part.Position = position
	part.Color = color
	part.Material = Enum.Material.Neon
	part.Parent = parent

	-- Étiquette flottante avec le nom lisible de la créature.
	local creature = Config.Creatures[name]
	local label = Instance.new("BillboardGui")
	label.Name = "Label"
	label.Size = UDim2.fromOffset(160, 36)
	label.StudsOffset = Vector3.new(0, 4, 0)
	label.AlwaysOnTop = true
	label.Parent = part

	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.TextScaled = true
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.Text = (creature and creature.displayName) or name
	text.Parent = label

	-- Déclencheur cliquable : aucun combat ici, simple log côté serveur.
	local click = Instance.new("ClickDetector")
	click.MaxActivationDistance = 32
	click.Parent = part

	click.MouseClick:Connect(function(player: Player)
		print(("[TestZone] Déclencheur « %s » activé par %s (aucun combat : fondation)."):format(name, player.Name))
	end)

	return part
end

-- Construit (ou reconstruit) la zone de test dans le Workspace.
function TestZone.build(): Model
	local existing = workspace:FindFirstChild(ZONE_NAME)
	if existing then
		existing:Destroy()
	end

	local zone = Instance.new("Model")
	zone.Name = ZONE_NAME

	makeFloor(zone)
	for _, spec in TRIGGERS do
		makeTrigger(zone, spec.key, spec.color, Vector3.new(0, 4, 0) + spec.offset)
	end

	zone.Parent = workspace
	return zone
end

return TestZone
