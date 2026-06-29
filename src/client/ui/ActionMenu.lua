--!strict
-- ActionMenu
-- Lot 03 — Menu d'actions à droite : Attaque, Objet, Garde, Méditer, S'échapper.
-- Les boutons sont activés uniquement quand le joueur doit choisir (état serveur
-- « ChoosingAction »). Entrées : souris, clavier (1..5) et bases manette (Selectable).
-- Le menu signale l'action choisie via un callback ; il n'applique rien lui-même.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local Helpers = require(script.Parent:WaitForChild("UIHelpers"))

local UI = Config.UI
local Palette = UI.Palette
local Layout = UI.Layout
local Fonts = UI.Fonts
local ACTIONS = UI.Actions

local ActionMenu = {}
ActionMenu.__index = ActionMenu

-- parent    : conteneur (ScreenGui).
-- onAction  : fonction appelée avec l'id de l'action choisie (ex. « Garde »).
function ActionMenu.new(parent: Instance, onAction: (string) -> ())
	local self = setmetatable({}, ActionMenu)
	self._onAction = onAction
	self._enabled = false
	self._buttons = {} :: { [string]: TextButton }

	local frame = Helpers.panel("ActionMenu")
	frame.AnchorPoint = Vector2.new(1, 0.5)
	frame.Position = UDim2.new(1, -Layout.Margin, 0.5, 0)
	frame.Size = UDim2.new(0, Layout.MenuWidth, 0, #ACTIONS * (Layout.MenuButtonHeight + Layout.MenuButtonSpacing) + Layout.Margin)
	Helpers.minSize(frame, Layout.MenuMinWidth, 0)
	frame.Parent = parent

	Helpers.padding(frame)

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Vertical
	list.Padding = UDim.new(0, Layout.MenuButtonSpacing)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.Parent = frame

	for index, action in ACTIONS do
		local button = Instance.new("TextButton")
		button.Name = action.id
		button.Size = UDim2.new(1, 0, 0, Layout.MenuButtonHeight)
		button.BackgroundColor3 = Palette.ButtonDisabled
		button.BorderSizePixel = 0
		button.AutoButtonColor = false
		button.Text = action.label
		button.Font = Fonts.Value
		button.TextSize = 18
		button.TextColor3 = Palette.Text
		button.LayoutOrder = index
		-- Bases manette : navigable au stick / D-pad.
		button.Selectable = true
		Helpers.corner(button)
		Helpers.stroke(button)
		button.Parent = frame

		-- Indice clavier (1..5) discret dans le coin.
		local hint = Helpers.label("Hint", tostring(index), Fonts.Body, 12)
		hint.TextColor3 = Palette.TextMuted
		hint.TextXAlignment = Enum.TextXAlignment.Right
		hint.AnchorPoint = Vector2.new(1, 0)
		hint.Position = UDim2.new(1, -6, 0, 2)
		hint.Size = UDim2.new(0, 16, 0, 14)
		hint.Parent = button

		button.MouseEnter:Connect(function()
			if self._enabled then
				button.BackgroundColor3 = Palette.ButtonHover
			end
		end)
		button.MouseLeave:Connect(function()
			button.BackgroundColor3 = if self._enabled then Palette.ButtonEnabled else Palette.ButtonDisabled
		end)
		button.Activated:Connect(function()
			self:_trigger(action.id)
		end)

		self._buttons[action.id] = button
	end

	self.instance = frame

	-- Raccourcis clavier (1..5) via ContextActionService (n'intercepte que ces touches).
	self._actionName = "CombatActionMenu"
	local keys = {}
	for _, action in ACTIONS do
		table.insert(keys, action.key)
	end
	ContextActionService:BindAction(self._actionName, function(_, inputState: Enum.UserInputState, input: InputObject)
		if inputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end
		for _, action in ACTIONS do
			if input.KeyCode == action.key then
				self:_trigger(action.id)
				return Enum.ContextActionResult.Sink
			end
		end
		return Enum.ContextActionResult.Pass
	end, false, table.unpack(keys))

	self:setEnabled(false)
	return self
end

-- Déclenche une action si le menu est actif.
function ActionMenu:_trigger(actionId: string)
	if not self._enabled then
		return
	end
	self._onAction(actionId)
end

-- Active / désactive l'ensemble des boutons (selon le contexte de combat).
function ActionMenu:setEnabled(enabled: boolean)
	self._enabled = enabled
	for _, button in self._buttons do
		button.AutoButtonColor = false
		button.Active = enabled
		button.BackgroundColor3 = if enabled then Palette.ButtonEnabled else Palette.ButtonDisabled
		button.TextColor3 = if enabled then Palette.Text else Palette.TextMuted
		button.Selectable = enabled
	end

	-- Bases manette : sélectionne par défaut le premier bouton quand le menu s'active.
	if enabled then
		local first = self._buttons[ACTIONS[1].id]
		if first then
			GuiService.SelectedObject = first
		end
	elseif GuiService.SelectedObject and self._buttons[GuiService.SelectedObject.Name] then
		GuiService.SelectedObject = nil
	end
end

function ActionMenu:destroy()
	ContextActionService:UnbindAction(self._actionName)
	if self.instance then
		self.instance:Destroy()
	end
end

return ActionMenu
