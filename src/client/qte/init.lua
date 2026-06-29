--!strict
-- OffensiveQte (contrôleur du QTE offensif, côté client)
-- Lot 05 — Enchaîne les curseurs sur la barre, capture le clic d'arrêt de chaque
-- curseur, laisse un marqueur figé, applique l'annulation immédiate dès qu'un curseur
-- s'arrête hors de la zone rouge, puis renvoie les positions au serveur (autoritaire).
--
-- Le client n'applique AUCUN effet de jeu : il calcule un verdict local seulement pour
-- l'affichage immédiat (via la logique partagée Shared.Qte, identique au serveur). Le
-- serveur recalcule le verdict et applique les conséquences.
--
-- Outil développeur : `setSpeedMultiplier` ralentit (<1) ou accélère (>1) le QTE pendant
-- les tests sans changer le résultat (calculé à partir des positions normalisées).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Qte = require(Shared:WaitForChild("Qte"))
local Types = require(Shared:WaitForChild("Types"))

local OffensiveBar = require(script:WaitForChild("OffensiveBar"))

type OffensiveQteProfile = Types.OffensiveQteProfile

local DevConfig = Config.Qte.Dev

local OffensiveQte = {}
OffensiveQte.__index = OffensiveQte

function OffensiveQte.new(parent: Instance)
	local self = setmetatable({}, OffensiveQte)
	self._bar = OffensiveBar.new(parent)
	self._speed = DevConfig.DEFAULT_SPEED_MULTIPLIER
	self._running = false
	return self
end

-- Outil développeur : règle le multiplicateur de vitesse (borné par la configuration).
-- Renvoie la valeur réellement appliquée.
function OffensiveQte:setSpeedMultiplier(multiplier: number): number
	if type(multiplier) ~= "number" or multiplier ~= multiplier then
		return self._speed
	end
	self._speed = math.clamp(multiplier, DevConfig.MIN_SPEED_MULTIPLIER, DevConfig.MAX_SPEED_MULTIPLIER)
	return self._speed
end

function OffensiveQte:getSpeedMultiplier(): number
	return self._speed
end

function OffensiveQte:isRunning(): boolean
	return self._running
end

-- Lance le QTE offensif pour une action et appelle `onComplete(payload)` à la fin.
-- payload = { action, cursors = { { stopped, position }, ... } }, ou nil si l'action
-- n'a pas de profil de QTE (rien à jouer).
function OffensiveQte:run(action: string, onComplete: (any) -> ())
	if self._running then
		return
	end
	local profile = Qte.profileForAction(action)
	if not profile then
		onComplete(nil)
		return
	end

	self._running = true
	task.spawn(function()
		local cursors = self:_play(profile)
		self._running = false
		onComplete({ action = action, cursors = cursors })
	end)
end

-- Déroule tous les curseurs du profil et renvoie le tableau des saisies.
function OffensiveQte:_play(profile: OffensiveQteProfile): { any }
	local bar = self._bar
	bar:mount(profile)

	local cursors = {}
	local cancelledEarly = false

	for i = 1, profile.cursorCount do
		if cancelledEarly then
			-- Curseurs non joués après une annulation immédiate : comptés comme hors zone.
			cursors[i] = { stopped = false }
		else
			bar:setInstruction(("Curseur %d / %d — cliquez dans la zone."):format(i, profile.cursorCount))
			local position = self:_runCursor(profile)
			if position then
				local zone = Qte.classify(profile, position)
				bar:addMarker(position, zone)
				cursors[i] = { stopped = true, position = position }
				if zone == "out" then
					-- Annulation immédiate : un curseur hors de la zone rouge arrête le QTE.
					cancelledEarly = true
				end
			else
				-- Aucun clic : le curseur a atteint le bout, traité comme hors zone.
				bar:addMarker(1, "out")
				cursors[i] = { stopped = false }
				cancelledEarly = true
			end

			if not cancelledEarly and i < profile.cursorCount then
				task.wait(profile.spacingSeconds / self._speed)
			end
		end
	end

	-- Verdict local (affichage immédiat ; identique au calcul serveur).
	local positions: { number? } = {}
	for i = 1, profile.cursorCount do
		local cursor = cursors[i]
		positions[i] = (cursor.stopped and cursor.position) or nil
	end
	local verdict = Qte.computeOutcome(profile, positions)
	bar:hideCursor()
	bar:setVerdict(verdict.outcome)
	if verdict.cancelled then
		bar:playFailure()
	end

	-- Laisse voir les marqueurs figés et le verdict avant de fermer.
	task.wait(0.7)
	bar:unmount()

	return cursors
end

-- Anime un curseur de gauche à droite ; renvoie la position d'arrêt [0,1] au clic,
-- ou nil si le curseur atteint le bout sans clic. Le clic souris/tactile ou la barre
-- d'espace arrête le curseur.
function OffensiveQte:_runCursor(profile: OffensiveQteProfile): number?
	local bar = self._bar
	-- Vitesse appliquée : durée = base / multiplicateur (>1 accélère, <1 ralentit).
	local duration = profile.cursorSeconds / self._speed
	local startClock = os.clock()
	local stoppedAt: number? = nil
	local finished = false

	local conn
	conn = UserInputService.InputBegan:Connect(function(input: InputObject)
		if finished then
			return
		end
		local kind = input.UserInputType
		local isStop = kind == Enum.UserInputType.MouseButton1
			or kind == Enum.UserInputType.Touch
			or (kind == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space)
		if isStop then
			stoppedAt = math.clamp((os.clock() - startClock) / duration, 0, 1)
			finished = true
		end
	end)

	while not finished do
		local t = (os.clock() - startClock) / duration
		if t >= 1 then
			bar:setCursor(1)
			break
		end
		bar:setCursor(t)
		RunService.RenderStepped:Wait()
	end

	conn:Disconnect()

	if stoppedAt then
		bar:setCursor(stoppedAt)
	end
	return stoppedAt
end

return OffensiveQte
