--!strict
-- CenterZone
-- Lot 03 — Zone centrale : messages de combat et emplacement réservé aux QTE.
-- Le QTE n'est qu'un PLACEHOLDER ici (la logique de QTE viendra aux lots 05/06).
-- Pur affichage : `render(data)` recopie les messages et l'état courant.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local Helpers = require(script.Parent:WaitForChild("UIHelpers"))

local UI = Config.UI
local Palette = UI.Palette
local Layout = UI.Layout
local Fonts = UI.Fonts
local Labels = UI.Labels

local CenterZone = {}
CenterZone.__index = CenterZone

function CenterZone.new(parent: Instance)
	local self = setmetatable({}, CenterZone)

	local frame = Instance.new("Frame")
	frame.Name = "CenterZone"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	-- Légèrement au-dessus du centre pour laisser respirer le HUD/menu en bas.
	frame.Position = UDim2.new(0.5, 0, 0.42, 0)
	frame.Size = UDim2.new(Layout.CenterWidthScale, 0, Layout.CenterHeightScale, 0)
	frame.BackgroundTransparency = 1
	Helpers.minSize(frame, 280, 160)
	frame.Parent = parent

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Vertical
	list.Padding = UDim.new(0, 8)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.VerticalAlignment = Enum.VerticalAlignment.Bottom
	list.Parent = frame

	-- Lot 04 — Chronomètre du tour (durée restante), masqué hors tour du joueur.
	local timer = Helpers.label("TurnTimer", "", Fonts.Value, 20)
	timer.TextColor3 = Palette.Accent
	timer.TextXAlignment = Enum.TextXAlignment.Center
	timer.Size = UDim2.new(1, 0, 0, 24)
	timer.Visible = false
	timer.LayoutOrder = 0
	timer.Parent = frame

	-- Lot 06 — Bannières d'état défensif (Garde active / malus de Méditer), masquées
	-- tant que l'effet n'est pas actif. Pur affichage piloté par l'état serveur répliqué.
	local guardBanner = Helpers.label("GuardBanner", Labels.GuardActive, Fonts.Value, 16)
	guardBanner.TextColor3 = Palette.Accent
	guardBanner.TextXAlignment = Enum.TextXAlignment.Center
	guardBanner.Size = UDim2.new(1, 0, 0, 20)
	guardBanner.Visible = false
	guardBanner.LayoutOrder = 1
	guardBanner.Parent = frame
	self._guardBanner = guardBanner

	local malusBanner = Helpers.label("MalusBanner", Labels.MeditateMalus, Fonts.Value, 16)
	malusBanner.TextColor3 = Palette.SoulFilled
	malusBanner.TextXAlignment = Enum.TextXAlignment.Center
	malusBanner.Size = UDim2.new(1, 0, 0, 20)
	malusBanner.Visible = false
	malusBanner.LayoutOrder = 2
	malusBanner.Parent = frame
	self._malusBanner = malusBanner

	-- Emplacement QTE (placeholder, masqué tant qu'aucun combat n'est en cours).
	local qte = Helpers.panel("QtePlaceholder")
	qte.BackgroundTransparency = 0.4
	qte.Size = UDim2.new(0.7, 0, 0, 56)
	qte.LayoutOrder = 3
	local qteStroke = qte:FindFirstChildOfClass("UIStroke")
	if qteStroke then
		qteStroke.LineJoinMode = Enum.LineJoinMode.Round
	end
	qte.Parent = frame

	local qteLabel = Helpers.label("QteLabel", Labels.QtePlaceholder, Fonts.Body, 16)
	qteLabel.TextColor3 = Palette.TextMuted
	qteLabel.TextXAlignment = Enum.TextXAlignment.Center
	qteLabel.Size = UDim2.new(1, 0, 1, 0)
	qteLabel.Parent = qte

	-- Journal des messages de combat (les plus récents en bas).
	local log = Instance.new("Frame")
	log.Name = "MessageLog"
	log.BackgroundTransparency = 1
	log.Size = UDim2.new(1, 0, 0, 0)
	log.AutomaticSize = Enum.AutomaticSize.Y
	log.LayoutOrder = 4
	log.Parent = frame

	local logList = Instance.new("UIListLayout")
	logList.FillDirection = Enum.FillDirection.Vertical
	logList.Padding = UDim.new(0, 2)
	logList.SortOrder = Enum.SortOrder.LayoutOrder
	logList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	logList.VerticalAlignment = Enum.VerticalAlignment.Bottom
	logList.Parent = log

	self.instance = frame
	self._qte = qte
	self._log = log
	self._timer = timer
	return self
end

-- Lot 04 — Met à jour le chronomètre du tour (durée restante en secondes), piloté
-- par l'horloge serveur synchronisée. `secondsRemaining = nil` masque le chronomètre.
function CenterZone:setTimer(secondsRemaining: number?)
	local timer = self._timer
	if secondsRemaining == nil then
		timer.Visible = false
		return
	end
	timer.Visible = true
	timer.Text = Labels.TurnTimer:format(math.max(0, math.ceil(secondsRemaining)))
end

function CenterZone:render(data)
	-- L'emplacement QTE n'apparaît que pendant un combat (placeholder neutre sinon).
	self._qte.Visible = data.inCombat

	-- Lot 06 — Bannières d'état défensif, pilotées par l'état serveur répliqué.
	self._guardBanner.Visible = data.inCombat and data.guardActive == true
	self._malusBanner.Visible = data.inCombat and data.meditateMalus == true

	-- Reconstruit le journal des messages (simple, peu d'entrées : MaxMessages borné).
	for _, child in self._log:GetChildren() do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	local messages = data.messages
	if #messages == 0 then
		local placeholder = Helpers.label("Empty", if data.inCombat then Labels.ChooseAction else Labels.NoCombat, Fonts.Body, 15)
		placeholder.TextColor3 = Palette.TextMuted
		placeholder.TextXAlignment = Enum.TextXAlignment.Center
		placeholder.Size = UDim2.new(1, 0, 0, 20)
		placeholder.LayoutOrder = 1
		placeholder.Parent = self._log
		return
	end

	for index, message in messages do
		local lbl = Helpers.label("Msg" .. index, message, Fonts.Body, 15)
		lbl.TextColor3 = Palette.Text
		lbl.TextXAlignment = Enum.TextXAlignment.Center
		lbl.TextWrapped = true
		lbl.Size = UDim2.new(1, 0, 0, 20)
		lbl.AutomaticSize = Enum.AutomaticSize.Y
		lbl.LayoutOrder = index
		lbl.Parent = self._log
	end
end

return CenterZone
