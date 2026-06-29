--!strict
-- HUD
-- Lot 03 — HUD permanent en bas à gauche.
-- Affiche : nom du personnage, maîtrise niveau 1, barre et valeur de PV,
-- six segments d'Essence + texte « x/6 », trois fragments d'âme, or et cristaux.
-- Purement de l'affichage : `render(data)` recopie l'état, il ne décide rien.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local Helpers = require(script.Parent:WaitForChild("UIHelpers"))

local UI = Config.UI
local Palette = UI.Palette
local Layout = UI.Layout
local Fonts = UI.Fonts
local Labels = UI.Labels
local SOUL_FRAGMENTS = UI.SOUL_FRAGMENTS

local HUD = {}
HUD.__index = HUD

-- Construit une rangée de segments (Essence ou fragments d'âme).
local function buildSegments(parent: Instance, count: number, layoutOrder: number): { Frame }
	local row = Instance.new("Frame")
	row.Name = "Segments"
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, 0, 0, 14)
	row.LayoutOrder = layoutOrder
	row.Parent = parent

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.Padding = UDim.new(0, 4)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Parent = row

	local segments = {}
	for i = 1, count do
		local seg = Instance.new("Frame")
		seg.Name = "Segment" .. i
		seg.Size = UDim2.new(0, 18, 1, 0)
		seg.BackgroundColor3 = Palette.EssenceEmpty
		seg.BorderSizePixel = 0
		seg.LayoutOrder = i
		Helpers.corner(seg, 3)
		seg.Parent = row
		segments[i] = seg
	end
	return segments
end

-- Crée le HUD complet et renvoie un objet avec `instance` et `render`.
function HUD.new(parent: Instance)
	local self = setmetatable({}, HUD)

	local frame = Helpers.panel("HUD")
	-- Ancré en bas à gauche ; taille en offset bornée par une taille minimale.
	frame.AnchorPoint = Vector2.new(0, 1)
	frame.Position = UDim2.new(0, Layout.Margin, 1, -Layout.Margin)
	frame.Size = UDim2.new(0, Layout.HudWidth, 0, Layout.HudHeight)
	Helpers.minSize(frame, Layout.HudMinWidth, Layout.HudHeight)
	frame.Parent = parent

	local pad = Helpers.padding(frame)
	pad.PaddingTop = UDim.new(0, 10)
	pad.PaddingBottom = UDim.new(0, 10)

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Vertical
	list.Padding = UDim.new(0, 6)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = frame

	-- 1) Nom du personnage.
	local nameLabel = Helpers.label("Name", "—", Fonts.Title, 20)
	nameLabel.Size = UDim2.new(1, 0, 0, 24)
	nameLabel.LayoutOrder = 1
	nameLabel.Parent = frame

	-- 2) Maîtrise niveau 1.
	local masteryLabel = Helpers.label("Mastery", "", Fonts.Body, 14)
	masteryLabel.TextColor3 = Palette.TextMuted
	masteryLabel.Size = UDim2.new(1, 0, 0, 16)
	masteryLabel.LayoutOrder = 2
	masteryLabel.Parent = frame

	-- 3) Barre + valeur de PV.
	local hpRow = Instance.new("Frame")
	hpRow.Name = "HpRow"
	hpRow.BackgroundTransparency = 1
	hpRow.Size = UDim2.new(1, 0, 0, 20)
	hpRow.LayoutOrder = 3
	hpRow.Parent = frame

	local hpBg = Instance.new("Frame")
	hpBg.Name = "HpBackground"
	hpBg.Size = UDim2.new(1, 0, 0, 16)
	hpBg.Position = UDim2.new(0, 0, 0.5, 0)
	hpBg.AnchorPoint = Vector2.new(0, 0.5)
	hpBg.BackgroundColor3 = Palette.HpBackground
	hpBg.BorderSizePixel = 0
	Helpers.corner(hpBg, 4)
	hpBg.Parent = hpRow

	local hpFill = Instance.new("Frame")
	hpFill.Name = "HpFill"
	hpFill.Size = UDim2.new(0, 0, 1, 0)
	hpFill.BackgroundColor3 = Palette.HpFill
	hpFill.BorderSizePixel = 0
	Helpers.corner(hpFill, 4)
	hpFill.Parent = hpBg

	local hpValue = Helpers.label("HpValue", "0 / 0", Fonts.Value, 13)
	hpValue.TextXAlignment = Enum.TextXAlignment.Center
	hpValue.Size = UDim2.new(1, 0, 1, 0)
	hpValue.Parent = hpBg

	-- 4) Six segments d'Essence + texte « x/6 ».
	local essenceTitle = Helpers.label("EssenceTitle", "Essence", Fonts.Body, 13)
	essenceTitle.TextColor3 = Palette.TextMuted
	essenceTitle.Size = UDim2.new(1, 0, 0, 14)
	essenceTitle.LayoutOrder = 4
	essenceTitle.Parent = frame

	local essenceRow = Instance.new("Frame")
	essenceRow.Name = "EssenceRow"
	essenceRow.BackgroundTransparency = 1
	essenceRow.Size = UDim2.new(1, 0, 0, 16)
	essenceRow.LayoutOrder = 5
	essenceRow.Parent = frame

	local essenceSegments = buildSegments(essenceRow, Config.Essence.MAX, 1)
	local essenceSegsHolder = essenceRow:FindFirstChild("Segments") :: Frame
	essenceSegsHolder.Size = UDim2.new(1, -54, 1, 0)

	local essenceValue = Helpers.label("EssenceValue", "0/6", Fonts.Value, 14)
	essenceValue.TextXAlignment = Enum.TextXAlignment.Right
	essenceValue.AnchorPoint = Vector2.new(1, 0.5)
	essenceValue.Position = UDim2.new(1, 0, 0.5, 0)
	essenceValue.Size = UDim2.new(0, 48, 1, 0)
	essenceValue.Parent = essenceRow

	-- 5) Trois fragments d'âme.
	local soulRow = Instance.new("Frame")
	soulRow.Name = "SoulRow"
	soulRow.BackgroundTransparency = 1
	soulRow.Size = UDim2.new(1, 0, 0, 16)
	soulRow.LayoutOrder = 6
	soulRow.Parent = frame

	local soulTitle = Helpers.label("SoulTitle", Labels.SoulFragments, Fonts.Body, 13)
	soulTitle.TextColor3 = Palette.TextMuted
	soulTitle.Size = UDim2.new(0, 110, 1, 0)
	soulTitle.Parent = soulRow

	local soulHolder = Instance.new("Frame")
	soulHolder.Name = "SoulHolder"
	soulHolder.BackgroundTransparency = 1
	soulHolder.Position = UDim2.new(0, 114, 0, 0)
	soulHolder.Size = UDim2.new(1, -114, 1, 0)
	soulHolder.Parent = soulRow
	local soulSegments = buildSegments(soulHolder, SOUL_FRAGMENTS, 1)

	-- 6) Or et cristaux (valeurs temporaires).
	local economyRow = Instance.new("Frame")
	economyRow.Name = "EconomyRow"
	economyRow.BackgroundTransparency = 1
	economyRow.Size = UDim2.new(1, 0, 0, 16)
	economyRow.LayoutOrder = 7
	economyRow.Parent = frame

	local goldLabel = Helpers.label("Gold", "Or 0", Fonts.Value, 14)
	goldLabel.TextColor3 = Palette.Gold
	goldLabel.Size = UDim2.new(0.5, 0, 1, 0)
	goldLabel.Parent = economyRow

	local crystalLabel = Helpers.label("Crystals", "Cristaux 0", Fonts.Value, 14)
	crystalLabel.TextColor3 = Palette.Crystal
	crystalLabel.TextXAlignment = Enum.TextXAlignment.Right
	crystalLabel.AnchorPoint = Vector2.new(1, 0)
	crystalLabel.Position = UDim2.new(1, 0, 0, 0)
	crystalLabel.Size = UDim2.new(0.5, 0, 1, 0)
	crystalLabel.Parent = economyRow

	self.instance = frame
	self._nameLabel = nameLabel
	self._masteryLabel = masteryLabel
	self._hpFill = hpFill
	self._hpValue = hpValue
	self._essenceSegments = essenceSegments
	self._essenceValue = essenceValue
	self._soulSegments = soulSegments
	self._goldLabel = goldLabel
	self._crystalLabel = crystalLabel

	return self
end

-- Recopie l'état d'affichage dans les widgets (aucune décision : pur rendu).
function HUD:render(data)
	self._nameLabel.Text = data.characterName
	self._masteryLabel.Text = Labels.Mastery:format(data.masteryLevel)

	-- PV : barre + texte. Division par zéro évitée (état neutre = barre vide).
	local ratio = if data.maxHp > 0 then math.clamp(data.hp / data.maxHp, 0, 1) else 0
	self._hpFill.Size = UDim2.new(ratio, 0, 1, 0)
	self._hpValue.Text = Labels.HpValue:format(data.hp, data.maxHp)

	-- Essence : remplit les segments jusqu'à `essence`, texte « x/max ».
	for i, seg in self._essenceSegments do
		seg.BackgroundColor3 = if i <= data.essence then Palette.EssenceFilled else Palette.EssenceEmpty
	end
	self._essenceValue.Text = Labels.EssenceValue:format(data.essence, data.essenceMax)

	-- Fragments d'âme.
	for i, seg in self._soulSegments do
		seg.BackgroundColor3 = if i <= data.soulFragments then Palette.SoulFilled else Palette.SoulEmpty
	end

	-- Économie (valeurs temporaires).
	self._goldLabel.Text = ("%s %d"):format(Labels.Gold, data.gold)
	self._crystalLabel.Text = ("%s %d"):format(Labels.Crystals, data.crystals)
end

return HUD
