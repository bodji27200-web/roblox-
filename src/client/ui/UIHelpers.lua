--!strict
-- UIHelpers
-- Lot 03 — Fabriques d'éléments d'interface réutilisables (panneaux, textes, coins).
-- Mutualise la création d'Instances GUI pour garder les composants concis et cohérents.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local UI = Config.UI
local Palette = UI.Palette
local Layout = UI.Layout
local Fonts = UI.Fonts

local UIHelpers = {}

-- Coin arrondi standard.
function UIHelpers.corner(parent: Instance, radius: number?): UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or Layout.CornerRadius)
	corner.Parent = parent
	return corner
end

-- Bordure fine standard.
function UIHelpers.stroke(parent: Instance, color: Color3?): UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = Layout.BorderThickness
	stroke.Color = color or Palette.PanelBorder
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

-- Marge intérieure uniforme.
function UIHelpers.padding(parent: Instance, amount: number?): UIPadding
	local pad = Instance.new("UIPadding")
	local px = UDim.new(0, amount or Layout.Margin)
	pad.PaddingTop = px
	pad.PaddingBottom = px
	pad.PaddingLeft = px
	pad.PaddingRight = px
	pad.Parent = parent
	return pad
end

-- Panneau de fond standard (Frame stylisé).
function UIHelpers.panel(name: string): Frame
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundColor3 = Palette.Panel
	frame.BackgroundTransparency = 0.05
	frame.BorderSizePixel = 0
	UIHelpers.corner(frame)
	UIHelpers.stroke(frame)
	return frame
end

-- Libellé texte standard.
function UIHelpers.label(name: string, text: string, font: Enum.Font?, size: number?): TextLabel
	local lbl = Instance.new("TextLabel")
	lbl.Name = name
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = font or Fonts.Body
	lbl.TextColor3 = Palette.Text
	lbl.TextSize = size or 16
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextYAlignment = Enum.TextYAlignment.Center
	lbl.RichText = false
	return lbl
end

-- Contrainte de taille minimale (lisibilité sur petites résolutions).
function UIHelpers.minSize(parent: GuiObject, minX: number, minY: number): UISizeConstraint
	local constraint = Instance.new("UISizeConstraint")
	constraint.MinSize = Vector2.new(minX, minY)
	constraint.Parent = parent
	return constraint
end

return UIHelpers
