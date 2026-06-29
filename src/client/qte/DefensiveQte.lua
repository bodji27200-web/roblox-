--!strict
-- DefensiveQte (contrôleur du QTE défensif, côté client)
-- Lot 06 — Joue le QTE défensif universel à UN SEUL curseur, déclenché par le SERVEUR
-- (à la différence de l'offensif, demandé par le client). Anime le curseur, capture le
-- clic/tap/espace d'arrêt, laisse un marqueur figé, puis renvoie la position au serveur
-- (autoritaire) accompagnée de la durée physique mesurée.
--
-- Le client n'applique AUCUN effet de jeu : il calcule un verdict local SEULEMENT pour
-- l'affichage immédiat (via la logique partagée Shared.Qte, identique au serveur). Le
-- serveur recalcule la zone, les dégâts et l'absorption et fait seul autorité.
--
-- Support souris / tactile / clavier (espace), comme le QTE offensif. Le multiplicateur
-- de vitesse dev est réutilisé pour faciliter les tests sans changer le résultat.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Qte = require(Shared:WaitForChild("Qte"))
local Types = require(Shared:WaitForChild("Types"))

local DefensiveBar = require(script.Parent:WaitForChild("DefensiveBar"))

type DefensiveQteProfile = Types.DefensiveQteProfile

local DevConfig = Config.Qte.Dev

local DefensiveQte = {}
DefensiveQte.__index = DefensiveQte

function DefensiveQte.new(parent: Instance)
	local self = setmetatable({}, DefensiveQte)
	self._bar = DefensiveBar.new(parent)
	self._speed = DevConfig.DEFAULT_SPEED_MULTIPLIER
	self._running = false
	-- Drapeau d'annulation propre et connexion d'entrée du curseur en cours : permettent
	-- d'arrêter la boucle, de couper la saisie et d'empêcher l'envoi de la charge utile.
	self._cancelled = false
	self._activeConn = nil :: RBXScriptConnection?
	return self
end

-- Annulation propre du QTE défensif en cours (le contexte est devenu invalide : timeout/
-- verdict serveur reçu, fin de combat, changement de session, nettoyage). Arrête la boucle,
-- coupe la saisie, masque la barre et empêche l'envoi (onComplete ne sera pas rappelé).
-- Sans effet si rien n'est en cours.
function DefensiveQte:cancel()
	if not self._running then
		return
	end
	self._cancelled = true
	self._running = false
	if self._activeConn then
		self._activeConn:Disconnect()
		self._activeConn = nil
	end
	self._bar:unmount()
end

-- Outil développeur : règle le multiplicateur de vitesse (borné par la configuration).
function DefensiveQte:setSpeedMultiplier(multiplier: number): number
	if type(multiplier) ~= "number" or multiplier ~= multiplier then
		return self._speed
	end
	self._speed = math.clamp(multiplier, DevConfig.MIN_SPEED_MULTIPLIER, DevConfig.MAX_SPEED_MULTIPLIER)
	return self._speed
end

function DefensiveQte:getSpeedMultiplier(): number
	return self._speed
end

function DefensiveQte:isRunning(): boolean
	return self._running
end

-- Joue un défi de QTE défensif (curseur unique) pour le profil donné et appelle
-- `onComplete(result)` à la fin. result = { stopped, position?, duration }. onComplete
-- n'est PAS appelé si le QTE est annulé en cours (le serveur gère alors timeout/abandon).
function DefensiveQte:playChallenge(profile: DefensiveQteProfile, onComplete: (any) -> ())
	if self._running then
		return
	end
	if type(profile) ~= "table" then
		onComplete(nil)
		return
	end

	self._running = true
	self._cancelled = false
	task.spawn(function()
		local stopped, position, duration = self:_play(profile)
		self._running = false
		-- QTE annulé pendant le jeu : ne JAMAIS envoyer de charge utile.
		if self._cancelled then
			return
		end
		onComplete({ stopped = stopped, position = position, duration = duration })
	end)
end

-- Déroule le curseur unique et renvoie (stopped, position?, durée physique en secondes).
function DefensiveQte:_play(profile: DefensiveQteProfile): (boolean, number?, number)
	local bar = self._bar
	bar:mount(profile)

	-- Mesure de la durée physique réelle (du début du curseur jusqu'au verdict), transmise
	-- au serveur pour une validation raisonnable du timing.
	local playStart = os.clock()

	local position = self:_runCursor(profile)

	-- QTE annulé en cours de jeu : ne calcule pas de verdict, ne ferme pas (barre déjà
	-- masquée par cancel()). Les valeurs renvoyées sont ignorées par playChallenge().
	if self._cancelled then
		return false, nil, 0
	end

	local duration = os.clock() - playStart
	local stopped = position ~= nil

	-- Verdict local (affichage immédiat ; identique au calcul serveur autoritaire).
	local zone = Qte.classify(profile, position)
	if stopped then
		bar:addMarker(position :: number, zone)
	else
		-- Aucun clic : le curseur a atteint le bout, traité comme hors zone.
		bar:addMarker(1, "out")
	end
	bar:hideCursor()
	bar:setVerdict(Qte.defenseOutcomeForZone(zone))
	if zone == "out" then
		bar:playFailure()
	end

	-- Laisse voir le marqueur figé et le verdict avant de fermer.
	task.wait(0.7)
	bar:unmount()

	return stopped, position, duration
end

-- Anime le curseur de gauche à droite ; renvoie la position d'arrêt [0,1] au clic, ou nil
-- si le curseur atteint le bout sans clic. Souris / tactile / barre d'espace arrêtent.
function DefensiveQte:_runCursor(profile: DefensiveQteProfile): number?
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

return DefensiveQte
