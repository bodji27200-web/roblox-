--!strict
-- DefensiveBar
-- Lot 06 — Rendu du QTE défensif : une barre horizontale avec une zone rouge (défense
-- normale, large) et une zone jaune plus petite (parade parfaite), un curseur UNIQUE
-- mobile, et un marqueur figé à la position d'arrêt. Pur affichage : aucune règle de jeu
-- ici (la logique vit dans le contrôleur et la logique partagée Shared.Qte, autoritaire
-- côté serveur).
--
-- Volontairement distinct d'OffensiveBar : on ne touche pas au QTE offensif sécurisé
-- (PR #8/#9). La géométrie des zones (center, demi-largeurs) provient du profil défensif.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Types = require(Shared:WaitForChild("Types"))

type DefensiveQteProfile = Types.DefensiveQteProfile
type QteZone = Types.QteZone

local Palette = Config.UI.Palette
local Fonts = Config.UI.Fonts
local Labels = Config.UI.Labels

-- Couleurs des zones et marqueurs (cohérentes avec la barre offensive / le HUD).
local RED_ZONE = Color3.fromRGB(170, 65, 65)
local YELLOW_ZONE = Color3.fromRGB(232, 200, 92)
local CURSOR_COLOR = Color3.fromRGB(245, 247, 252)
local MARKER_COLOR: { [string]: Color3 } = {
	yellow = Color3.fromRGB(245, 220, 120),
	red = Color3.fromRGB(220, 110, 110),
	out = Color3.fromRGB(120, 126, 144),
}
-- Couleurs du verdict défensif (DefenseOutcome : PerfectParry / Normal / Miss).
local VERDICT_COLOR: { [string]: Color3 } = {
	PerfectParry = Color3.fromRGB(245, 220, 120),
	Normal = Color3.fromRGB(150, 210, 150),
	Miss = Color3.fromRGB(225, 105, 105),
}

local DefensiveBar = {}
DefensiveBar.__index = DefensiveBar

local function newZone(name: string, color: Color3, parent: Instance, zIndex: number): Frame
	local zone = Instance.new("Frame")
	zone.Name = name
	zone.BackgroundColor3 = color
	zone.BackgroundTransparency = 0.15
	zone.BorderSizePixel = 0
	zone.ZIndex = zIndex
	zone.Parent = parent
	return zone
end

function DefensiveBar.new(parent: Instance)
	local self = setmetatable({}, DefensiveBar)
	self._markers = {} :: { Frame }

	-- Conteneur central (masqué tant qu'aucun QTE défensif n'est en cours). Placé un peu
	-- plus haut que la barre offensive pour ne pas se superposer si jamais coexistence.
	local root = Instance.new("Frame")
	root.Name = "DefensiveQte"
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.new(0.5, 0, 0.26, 0)
	root.Size = UDim2.new(0.6, 0, 0, 150)
	root.BackgroundColor3 = Palette.Panel
	root.BackgroundTransparency = 0.1
	root.BorderSizePixel = 0
	root.Visible = false
	root.ZIndex = 20
	root.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = root

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = Palette.PanelBorder
	stroke.Parent = root
	self._stroke = stroke

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 14)
	pad.PaddingBottom = UDim.new(0, 14)
	pad.PaddingLeft = UDim.new(0, 18)
	pad.PaddingRight = UDim.new(0, 18)
	pad.Parent = root

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Text = Labels.DefenseTitle
	title.Font = Fonts.Title
	title.TextSize = 18
	title.TextColor3 = Palette.Text
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.Size = UDim2.new(1, 0, 0, 22)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.ZIndex = 21
	title.Parent = root

	-- Piste (la barre horizontale). Les zones et le curseur sont positionnés dessus.
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.AnchorPoint = Vector2.new(0.5, 0.5)
	track.Position = UDim2.new(0.5, 0, 0.5, 0)
	track.Size = UDim2.new(1, 0, 0, 30)
	track.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
	track.BorderSizePixel = 0
	track.ZIndex = 21
	track.Parent = root
	self._track = track

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(0, 6)
	trackCorner.Parent = track

	-- Zone rouge (large, défense normale) puis zone jaune (plus petite, parade parfaite).
	self._redZone = newZone("RedZone", RED_ZONE, track, 22)
	self._yellowZone = newZone("YellowZone", YELLOW_ZONE, track, 23)

	-- Curseur unique mobile (caché hors QTE).
	local cursor = Instance.new("Frame")
	cursor.Name = "Cursor"
	cursor.AnchorPoint = Vector2.new(0.5, 0)
	cursor.Size = UDim2.new(0, 4, 1, 0)
	cursor.Position = UDim2.new(0, 0, 0, 0)
	cursor.BackgroundColor3 = CURSOR_COLOR
	cursor.BorderSizePixel = 0
	cursor.ZIndex = 26
	cursor.Visible = false
	cursor.Parent = track
	self._cursor = cursor

	local instruction = Instance.new("TextLabel")
	instruction.Name = "Instruction"
	instruction.BackgroundTransparency = 1
	instruction.Text = ""
	instruction.Font = Fonts.Body
	instruction.TextSize = 15
	instruction.TextColor3 = Palette.TextMuted
	instruction.TextXAlignment = Enum.TextXAlignment.Center
	instruction.AnchorPoint = Vector2.new(0.5, 1)
	instruction.Position = UDim2.new(0.5, 0, 1, 0)
	instruction.Size = UDim2.new(1, 0, 0, 20)
	instruction.ZIndex = 21
	instruction.Parent = root
	self._instruction = instruction

	self._root = root
	self._homePosition = root.Position
	return self
end

-- Prépare la barre pour un nouveau QTE défensif : dessine les zones selon le profil,
-- efface le marqueur précédent, replace le curseur à gauche et affiche le conteneur.
function DefensiveBar:mount(profile: DefensiveQteProfile)
	-- Zone rouge (large, défense normale).
	local redLeft = math.clamp(profile.center - profile.redHalfWidth, 0, 1)
	local redWidth = math.clamp(profile.redHalfWidth * 2, 0, 1)
	self._redZone.Position = UDim2.new(redLeft, 0, 0, 0)
	self._redZone.Size = UDim2.new(redWidth, 0, 1, 0)

	-- Zone jaune (plus petite, parade parfaite), centrée dans la rouge.
	local yellowLeft = math.clamp(profile.center - profile.yellowHalfWidth, 0, 1)
	local yellowWidth = math.clamp(profile.yellowHalfWidth * 2, 0, 1)
	self._yellowZone.Position = UDim2.new(yellowLeft, 0, 0, 0)
	self._yellowZone.Size = UDim2.new(yellowWidth, 0, 1, 0)

	self:clearMarkers()
	self:hideCursor()
	self:setVerdict(nil)
	self:setInstruction(Config.UI.Labels.DefenseInstruction)
	self._stroke.Color = Palette.PanelBorder
	self._root.Position = self._homePosition
	self._root.Visible = true
end

-- Place le curseur mobile à la position normalisée donnée et le rend visible.
function DefensiveBar:setCursor(t: number)
	self._cursor.Position = UDim2.new(math.clamp(t, 0, 1), 0, 0, 0)
	self._cursor.Visible = true
end

function DefensiveBar:hideCursor()
	self._cursor.Visible = false
end

function DefensiveBar:setInstruction(text: string)
	self._instruction.Text = text
end

-- Ajoute un marqueur figé à la position d'arrêt du curseur, coloré selon sa zone.
function DefensiveBar:addMarker(t: number, zone: QteZone)
	local marker = Instance.new("Frame")
	marker.Name = "Marker"
	marker.AnchorPoint = Vector2.new(0.5, 0)
	marker.Size = UDim2.new(0, 4, 1, 0)
	marker.Position = UDim2.new(math.clamp(t, 0, 1), 0, 0, 0)
	marker.BackgroundColor3 = MARKER_COLOR[zone] or MARKER_COLOR.out
	marker.BorderSizePixel = 0
	marker.ZIndex = 25
	marker.Parent = self._track
	table.insert(self._markers, marker)
end

function DefensiveBar:clearMarkers()
	for _, marker in self._markers do
		marker:Destroy()
	end
	table.clear(self._markers)
end

-- Affiche le verdict final de défense (ou l'efface avec nil). `outcome` est un DefenseOutcome
-- (« PerfectParry » / « Normal » / « Miss »).
function DefensiveBar:setVerdict(outcome: string?)
	if outcome == nil then
		self._instruction.TextColor3 = Palette.TextMuted
		return
	end
	local labels = Config.UI.Labels
	local text: { [string]: string } = {
		PerfectParry = labels.DefenseVerdictParry,
		Normal = labels.DefenseVerdictPartial,
		Miss = labels.DefenseVerdictMiss,
	}
	self._instruction.Text = text[outcome] or outcome
	self._instruction.TextColor3 = VERDICT_COLOR[outcome] or Palette.Text
end

-- Courte animation d'échec (secousse + bordure rouge) jouée quand la défense rate
-- (hors zone). Purement visuelle. `isCurrent` (optionnel) est testé entre chaque image de
-- la secousse (qui cède la coroutine) : s'il renvoie faux, l'animation s'arrête net sans plus
-- toucher la barre — utile si le QTE a été annulé/remplacé pendant la secousse.
function DefensiveBar:playFailure(isCurrent: (() -> boolean)?)
	local home = self._homePosition
	self._stroke.Color = VERDICT_COLOR.Miss
	for i = 1, 6 do
		if isCurrent and not isCurrent() then
			return
		end
		local offset = (i % 2 == 0) and 10 or -10
		self._root.Position = home + UDim2.fromOffset(offset, 0)
		task.wait(0.04)
	end
	if isCurrent and not isCurrent() then
		return
	end
	self._root.Position = home
	TweenService:Create(self._stroke, TweenInfo.new(0.4), { Color = Palette.PanelBorder }):Play()
end

function DefensiveBar:unmount()
	self._root.Visible = false
	self:hideCursor()
end

return DefensiveBar
