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
	-- Drapeau d'annulation propre (cancel) et connexion d'entrée du curseur en cours :
	-- permettent d'arrêter la boucle, de couper la saisie et d'empêcher l'envoi.
	self._cancelled = false
	self._activeConn = nil :: RBXScriptConnection?
	return self
end

-- Annulation propre du QTE en cours (le serveur a quitté ChoosingAction, le tour a
-- expiré, la session a changé ou le combat s'est terminé). Arrête la boucle active,
-- déconnecte la saisie du curseur, masque la barre et empêche l'envoi de la charge utile
-- (la coroutine de `run` ne rappellera pas `onComplete`). Sans effet si rien n'est en cours.
function OffensiveQte:cancel()
	if not self._running then
		return
	end
	self._cancelled = true
	self._running = false
	-- Couper l'entrée en cours pour ne plus capturer le moindre clic d'arrêt.
	if self._activeConn then
		self._activeConn:Disconnect()
		self._activeConn = nil
	end
	-- Masquer la barre immédiatement.
	self._bar:unmount()
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

-- Lance le QTE offensif pour une action et appelle `onComplete(result)` à la fin.
-- result = { cursors = { { stopped, position }, ... }, duration = secondes }, ou nil si
-- l'action n'a pas de profil de QTE (rien à jouer).
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
	self._cancelled = false
	task.spawn(function()
		local cursors, duration = self:_play(profile)
		self._running = false
		-- QTE annulé pendant le jeu : ne JAMAIS envoyer de charge utile (le tour est géré
		-- côté serveur — timeout/Garde, fin de combat, etc.).
		if self._cancelled then
			return
		end
		onComplete({ cursors = cursors, duration = duration })
	end)
end

-- Déroule tous les curseurs du profil et renvoie (saisies, durée physique en secondes).
function OffensiveQte:_play(profile: OffensiveQteProfile): ({ any }, number)
	local bar = self._bar
	bar:mount(profile)

	-- Mesure de la durée physique réelle du QTE (du premier curseur jusqu'au verdict),
	-- transmise au serveur pour une validation raisonnable du timing.
	local playStart = os.clock()

	local cursors = {}
	local cancelledEarly = false

	for i = 1, profile.cursorCount do
		-- Annulation externe (cancel) : on interrompt aussitôt la boucle de curseurs.
		if self._cancelled then
			break
		end
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

	-- QTE annulé en cours de jeu : ne calcule pas de verdict, n'attend pas et ne ferme pas
	-- (la barre est déjà masquée par cancel()). La valeur renvoyée est ignorée par run().
	if self._cancelled then
		return cursors, 0
	end

	-- Verdict local (affichage immédiat ; identique au calcul serveur).
	local positions: { number? } = {}
	for i = 1, profile.cursorCount do
		local cursor = cursors[i]
		positions[i] = (cursor.stopped and cursor.position) or nil
	end
	local verdict = Qte.computeOutcome(profile, positions)
	local duration = os.clock() - playStart
	bar:hideCursor()
	bar:setVerdict(verdict.outcome)
	if verdict.cancelled then
		bar:playFailure()
	end

	-- Laisse voir les marqueurs figés et le verdict avant de fermer.
	task.wait(0.7)
	bar:unmount()

	return cursors, duration
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
	-- Connexion suivie pour que cancel() puisse couper la saisie en cours.
	self._activeConn = conn

	while not finished do
		-- Annulation externe (cancel) : cesse d'animer le curseur immédiatement.
		if self._cancelled then
			break
		end
		local t = (os.clock() - startClock) / duration
		if t >= 1 then
			bar:setCursor(1)
			break
		end
		bar:setCursor(t)
		RunService.RenderStepped:Wait()
	end

	conn:Disconnect()
	if self._activeConn == conn then
		self._activeConn = nil
	end

	-- Annulé : aucune position d'arrêt valide à remonter.
	if self._cancelled then
		return nil
	end

	if stoppedAt then
		bar:setCursor(stoppedAt)
	end
	return stoppedAt
end

return OffensiveQte
