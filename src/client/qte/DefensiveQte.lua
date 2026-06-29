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
	-- Jeton de génération de l'exécution courante (et non un simple booléen partagé) : chaque
	-- nouvelle exécution capture sa propre valeur. Une coroutine, animation ou reprise
	-- vérifie que son jeton est toujours le jeton courant avant de toucher la barre, d'afficher
	-- un verdict, de masquer la barre ou d'appeler onComplete. Une ANCIENNE coroutine (jeton
	-- périmé) ne peut donc plus jamais modifier ni fermer le QTE suivant.
	self._runToken = 0
	-- Connexion d'entrée du curseur en cours (déconnectée à l'annulation/à la fin du curseur).
	self._activeConn = nil :: RBXScriptConnection?
	return self
end

-- Annulation propre du QTE défensif en cours (le contexte est devenu invalide : timeout/
-- verdict serveur reçu, fin de combat, changement de session, nettoyage). Invalide le jeton
-- courant (toute ancienne coroutine s'arrêtera et n'enverra rien), coupe la saisie et masque
-- la barre. Idempotent : sans effet visible si rien n'est en cours.
function DefensiveQte:cancel()
	-- Invalider le jeton AVANT tout : une coroutine encore en vol (jeton désormais périmé)
	-- ne pourra plus modifier la barre, afficher un verdict, la masquer ni rappeler onComplete.
	self._runToken += 1
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

	-- Nouvelle exécution : on capture un jeton de génération propre. Toute coroutine d'une
	-- exécution précédente possède un jeton désormais périmé et ne pourra plus rien faire.
	self._runToken += 1
	local token = self._runToken
	self._running = true
	task.spawn(function()
		local stopped, position, duration = self:_play(profile, token)
		-- Exécution devenue obsolète (annulée ou remplacée par une plus récente) : ne toucher
		-- ni au verrou `_running` (la nouvelle exécution le possède) ni à onComplete.
		if token ~= self._runToken then
			return
		end
		self._running = false
		onComplete({ stopped = stopped, position = position, duration = duration })
	end)
end

-- Déroule le curseur unique et renvoie (stopped, position?, durée physique en secondes).
-- `token` : jeton de génération de cette exécution ; revérifié après chaque attente/animation.
function DefensiveQte:_play(profile: DefensiveQteProfile, token: number): (boolean, number?, number)
	local bar = self._bar
	bar:mount(profile)

	-- Mesure de la durée physique réelle (du début du curseur jusqu'au verdict), transmise
	-- au serveur pour une validation raisonnable du timing.
	local playStart = os.clock()

	local position = self:_runCursor(profile, token)

	-- Exécution obsolète après l'animation du curseur : ne calcule pas de verdict et ne ferme
	-- pas (la barre est gérée par l'exécution courante / cancel). Valeurs ignorées en amont.
	if token ~= self._runToken then
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
		-- L'animation d'échec cède la coroutine : on lui passe un test de jeton pour qu'elle
		-- s'arrête net si l'exécution est annulée/remplacée pendant la secousse.
		bar:playFailure(function()
			return token == self._runToken
		end)
	end

	-- Revérifie le jeton après l'animation d'échec (qui a pu céder la main) avant d'attendre.
	if token ~= self._runToken then
		return false, nil, 0
	end

	-- Laisse voir le marqueur figé et le verdict avant de fermer.
	task.wait(0.7)

	-- Une annulation a pu survenir pendant l'attente : ne pas masquer la barre d'une éventuelle
	-- exécution suivante (cancel a déjà masqué la barre de cette exécution-ci).
	if token ~= self._runToken then
		return false, nil, 0
	end
	bar:unmount()

	return stopped, position, duration
end

-- Anime le curseur de gauche à droite ; renvoie la position d'arrêt [0,1] au clic, ou nil
-- si le curseur atteint le bout sans clic. Souris / tactile / barre d'espace arrêtent.
-- `token` : jeton de génération ; dès qu'il n'est plus courant, on stoppe sans toucher la barre.
function DefensiveQte:_runCursor(profile: DefensiveQteProfile, token: number): number?
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
		-- Annulation/remplacement externe : le jeton n'est plus courant -> on cesse d'animer.
		if token ~= self._runToken then
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
	-- Ne nullifie la connexion partagée que si elle est toujours la nôtre (une exécution plus
	-- récente a pu installer la sienne entre-temps : on ne doit pas la lui effacer).
	if self._activeConn == conn then
		self._activeConn = nil
	end

	-- Obsolète : aucune position d'arrêt valide à remonter (et on ne retouche pas la barre).
	if token ~= self._runToken then
		return nil
	end

	if stoppedAt then
		bar:setCursor(stoppedAt)
	end
	return stoppedAt
end

return DefensiveQte
