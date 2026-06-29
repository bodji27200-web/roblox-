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
local Labels = UI.Labels
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
	-- Lot 04 — Disponibilité par action répliquée par le serveur (coût/recharge/dispo).
	self._actions = {} :: { [string]: any }

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

		-- Lot 04 — Coût en Essence (bas-gauche), masqué si l'action est gratuite.
		local costBadge = Helpers.label("CostBadge", "", Fonts.Body, 12)
		costBadge.TextColor3 = Palette.EssenceFilled
		costBadge.TextXAlignment = Enum.TextXAlignment.Left
		costBadge.AnchorPoint = Vector2.new(0, 1)
		costBadge.Position = UDim2.new(0, 6, 1, -3)
		costBadge.Size = UDim2.new(0, 64, 0, 14)
		costBadge.Visible = false
		costBadge.Parent = button

		-- Lot 04 — Sablier de recharge (bas-droite), masqué hors recharge.
		local cooldownBadge = Helpers.label("CooldownBadge", "", Fonts.Value, 13)
		cooldownBadge.TextColor3 = Palette.TextMuted
		cooldownBadge.TextXAlignment = Enum.TextXAlignment.Right
		cooldownBadge.AnchorPoint = Vector2.new(1, 1)
		cooldownBadge.Position = UDim2.new(1, -6, 1, -3)
		cooldownBadge.Size = UDim2.new(0, 56, 0, 14)
		cooldownBadge.Visible = false
		cooldownBadge.Parent = button

		button.MouseEnter:Connect(function()
			if self._enabled and self:_isAvailable(action.id) then
				button.BackgroundColor3 = Palette.ButtonHover
			end
		end)
		button.MouseLeave:Connect(function()
			self:_applyButtonVisual(action.id, button)
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

-- Une action est utilisable si le serveur n'a pas signalé d'indisponibilité
-- (Essence suffisante et recharge écoulée). Sans donnée, on suppose disponible.
function ActionMenu:_isAvailable(actionId: string): boolean
	local info = self._actions[actionId]
	if info == nil then
		return true
	end
	return info.available ~= false
end

-- Applique l'apparence d'un bouton selon l'état (actif du combat + disponibilité).
function ActionMenu:_applyButtonVisual(actionId: string, button: TextButton)
	local usable = self._enabled and self:_isAvailable(actionId)
	button.AutoButtonColor = false
	button.Active = usable
	button.Selectable = usable
	button.BackgroundColor3 = if usable then Palette.ButtonEnabled else Palette.ButtonDisabled
	button.TextColor3 = if usable then Palette.Text else Palette.TextMuted
end

-- Recalcule l'apparence de tous les boutons.
function ActionMenu:_refreshButtons()
	for actionId, button in self._buttons do
		self:_applyButtonVisual(actionId, button)
	end
end

-- Déclenche une action si le menu est actif et l'action disponible (validée serveur).
function ActionMenu:_trigger(actionId: string)
	if not self._enabled or not self:_isAvailable(actionId) then
		return
	end
	self._onAction(actionId)
end

-- Met à jour les badges coût/recharge depuis l'instantané de ressources serveur (lot 04).
-- L'affichage suit la donnée répliquée : coût masqué si gratuit, sablier masqué hors recharge.
function ActionMenu:setActions(actions: { [string]: any }?)
	self._actions = actions or {}
	for actionId, button in self._buttons do
		local info = self._actions[actionId]
		local cost = (info and info.cost) or 0
		local cooldownRemaining = (info and info.cooldownRemaining) or 0

		local costBadge = button:FindFirstChild("CostBadge") :: TextLabel?
		if costBadge then
			costBadge.Visible = cost > 0
			if cost > 0 then
				costBadge.Text = Labels.EssenceCost:format(cost)
			end
		end

		local cooldownBadge = button:FindFirstChild("CooldownBadge") :: TextLabel?
		if cooldownBadge then
			cooldownBadge.Visible = cooldownRemaining > 0
			if cooldownRemaining > 0 then
				cooldownBadge.Text = Labels.Cooldown:format(cooldownRemaining)
			end
		end
	end
	self:_refreshButtons()
end

-- Active / désactive l'ensemble des boutons (selon le contexte de combat).
function ActionMenu:setEnabled(enabled: boolean)
	self._enabled = enabled
	self:_refreshButtons()

	-- Bases manette : sélectionne par défaut le premier bouton utilisable.
	if enabled then
		local first = self._buttons[ACTIONS[1].id]
		if first and first.Active then
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
