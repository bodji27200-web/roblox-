--!strict
-- TurnOrder
-- Lot 03 — Affichage de l'ordre des tours en haut de l'écran.
-- Construit une rangée de « pastilles » (une par combattant) ; la pastille du
-- combattant courant est mise en évidence. Pur affichage piloté par `render(data)`.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local Helpers = require(script.Parent:WaitForChild("UIHelpers"))

local UI = Config.UI
local Palette = UI.Palette
local Layout = UI.Layout
local Fonts = UI.Fonts
local Labels = UI.Labels

local TurnOrder = {}
TurnOrder.__index = TurnOrder

function TurnOrder.new(parent: Instance)
	local self = setmetatable({}, TurnOrder)

	local frame = Helpers.panel("TurnOrder")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0, Layout.Margin)
	frame.Size = UDim2.new(0.6, 0, 0, Layout.TurnOrderHeight)
	Helpers.minSize(frame, 280, Layout.TurnOrderHeight)
	-- Borne supérieure : évite une barre démesurée sur très grands écrans.
	local maxConstraint = Instance.new("UISizeConstraint")
	maxConstraint.MaxSize = Vector2.new(720, Layout.TurnOrderHeight)
	maxConstraint.Parent = frame
	frame.Parent = parent

	Helpers.padding(frame, 8)

	local title = Helpers.label("Title", Labels.TurnOrderTitle, Fonts.Body, 12)
	title.TextColor3 = Palette.TextMuted
	title.Size = UDim2.new(0, 120, 0, 14)
	title.Position = UDim2.new(0, 0, 0, -2)
	title.Parent = frame

	local holder = Instance.new("Frame")
	holder.Name = "Chips"
	holder.BackgroundTransparency = 1
	holder.AnchorPoint = Vector2.new(0, 1)
	holder.Position = UDim2.new(0, 0, 1, 0)
	holder.Size = UDim2.new(1, 0, 0, 26)
	holder.Parent = frame

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.Padding = UDim.new(0, 6)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Parent = holder

	self.instance = frame
	self._holder = holder
	self._emptyLabel = nil
	return self
end

-- Reconstruit les pastilles à partir de l'ordre des tours courant.
function TurnOrder:render(data)
	local holder = self._holder

	-- Vide les pastilles existantes (hors UIListLayout).
	for _, child in holder:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	if #data.turnOrder == 0 then
		-- État neutre : message discret, pas d'erreur.
		local empty = Instance.new("Frame")
		empty.Name = "Empty"
		empty.BackgroundTransparency = 1
		empty.Size = UDim2.new(1, 0, 1, 0)
		empty.LayoutOrder = 1
		empty.Parent = holder

		local lbl = Helpers.label("EmptyLabel", Labels.WaitingState, Fonts.Body, 13)
		lbl.TextColor3 = Palette.TextMuted
		lbl.TextXAlignment = Enum.TextXAlignment.Center
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.Parent = empty
		return
	end

	for index, entry in data.turnOrder do
		local chip = Instance.new("Frame")
		chip.Name = "Chip" .. index
		chip.Size = UDim2.new(0, 0, 1, 0)
		chip.AutomaticSize = Enum.AutomaticSize.X
		chip.BackgroundColor3 = if entry.isCurrent
			then (if entry.side == "Enemy" then Palette.EnemyTurn else Palette.CurrentTurn)
			else Palette.ButtonEnabled
		chip.BorderSizePixel = 0
		chip.LayoutOrder = index
		Helpers.corner(chip, 6)
		chip.Parent = holder

		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 10)
		pad.PaddingRight = UDim.new(0, 10)
		pad.Parent = chip

		local lbl = Helpers.label("Name", entry.name, Fonts.Value, 14)
		lbl.AutomaticSize = Enum.AutomaticSize.X
		lbl.Size = UDim2.new(0, 0, 1, 0)
		lbl.TextColor3 = if entry.isCurrent then Color3.fromRGB(15, 18, 26) else Palette.Text
		lbl.Parent = chip
	end
end

return TurnOrder
