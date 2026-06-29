--!strict
-- CombatUI (contrôleur de l'interface de combat)
-- Lot 03 — Assemble les composants (HUD, menu d'actions, ordre des tours, zone
-- centrale), les abonne à l'état d'affichage et branche cet état sur le serveur.
--
-- Sources de données :
--   * « CombatStateChanged » (lot 02) : phase de combat + numéro de manche. Pilote
--     l'activation des boutons, l'ordre des tours et les messages.
--   * Nom du joueur local : pour le nom affiché dans le HUD.
--   * `CombatUI:simulate(...)` : API de test manuel pour injecter PV/Essence/etc.
--     (les valeurs réelles seront branchées quand le serveur les exposera).
--
-- Le serveur reste autoritaire : le menu envoie l'action via « PlayerCombatAction »,
-- l'UI n'applique jamais d'effet de jeu elle-même.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
-- Lot 05 — Résolution partagée des profils de QTE offensif (action -> profil).
local Qte = require(Shared:WaitForChild("Qte"))

local CombatUIState = require(script:WaitForChild("CombatUIState"))
local HUD = require(script:WaitForChild("HUD"))
local ActionMenu = require(script:WaitForChild("ActionMenu"))
local TurnOrder = require(script:WaitForChild("TurnOrder"))
local CenterZone = require(script:WaitForChild("CenterZone"))
-- Lot 05 — Contrôleur du QTE offensif (rendu de la barre + saisie des curseurs).
local OffensiveQte = require(script.Parent:WaitForChild("qte"))

local UI = Config.UI

-- Lot 05 — Bonus d'attaque parfaite affiché, dérivé de la configuration (jamais écrit en
-- dur) : source unique Config.Combat.PERFECT_ATTACK_DAMAGE_BONUS.
local PERFECT_BONUS_PERCENT = math.floor(Config.Combat.PERFECT_ATTACK_DAMAGE_BONUS * 100 + 0.5)

-- Libellés français des phases de combat (messages de la zone centrale).
local STATE_MESSAGES: { [string]: string } = {
	Starting = "Le combat commence !",
	ChoosingAction = "À vous de jouer : choisissez une action.",
	ResolvingAction = "Résolution de l'action…",
	Defending = "Vous vous mettez en Garde.",
	RoundEnd = "Fin de la manche.",
	Victory = "Victoire !",
	Defeat = "Défaite…",
	Escaped = "Vous avez fui le combat.",
}

local CombatUI = {}
CombatUI.__index = CombatUI

local function localName(): string
	local player = Players.LocalPlayer
	return (player and (player.DisplayName ~= "" and player.DisplayName or player.Name)) or "Joueur"
end

function CombatUI.new()
	local self = setmetatable({}, CombatUI)

	self.state = CombatUIState.new()

	-- ScreenGui racine : occupe tout l'écran, survit aux réapparitions.
	local gui = Instance.new("ScreenGui")
	gui.Name = "CombatUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Enabled = true
	self.gui = gui

	-- Composants.
	self.hud = HUD.new(gui)
	self.turnOrder = TurnOrder.new(gui)
	self.centerZone = CenterZone.new(gui)
	self.actionMenu = ActionMenu.new(gui, function(actionId: string)
		self:_onActionChosen(actionId)
	end)

	-- Lot 05 — QTE offensif. `_qteActive` (pendant la saisie) et `_actionPending`
	-- (action envoyée, en attente de résolution serveur) verrouillent le menu pour
	-- éviter une seconde action dans le même tour.
	self.qte = OffensiveQte.new(gui)
	self._qteActive = false
	self._actionPending = false
	-- Identifiant de session courant : un changement signale une nouvelle rencontre et
	-- doit annuler tout QTE encore en cours (charge utile devenue obsolète).
	self._sessionId = nil :: any

	-- Abonnements : chaque composant se redessine quand l'état change.
	self.state:subscribe(function(data)
		self.hud:render(data)
		self.turnOrder:render(data)
		self.centerZone:render(data)
		-- Lot 04 — Badges coût/recharge depuis l'instantané serveur, puis activation.
		self.actionMenu:setActions(data.actions)
		-- Lot 05 — Menu verrouillé pendant un QTE ou tant que l'action n'est pas résolue.
		self.actionMenu:setEnabled(data.canAct and not self._qteActive and not self._actionPending)
	end)

	-- Nom du personnage (donnée réellement disponible côté client).
	self.state:applyDisplay({ characterName = localName() })

	return self
end

-- Construit un ordre des tours d'affichage minimal (joueur + ennemi) à l'entrée en
-- combat. L'ordre d'initiative réel est calculé côté serveur (lot 02) et n'est pas
-- répliqué : cet affichage marque le joueur comme actif pendant sa phase de choix.
function CombatUI:_refreshTurnOrder(combatState: string)
	if not self.state:get().inCombat then
		self.state:setTurnOrder({})
		return
	end
	local playerCurrent = combatState == "ChoosingAction"
	self.state:setTurnOrder({
		{ name = localName(), side = "Player", isCurrent = playerCurrent },
		{ name = "Ennemi", side = "Enemy", isCurrent = not playerCurrent },
	})
end

-- Réception de l'état serveur (lot 02).
function CombatUI:_onServerState(payload: { [string]: any })
	if type(payload) ~= "table" then
		return
	end
	local previous = self.state:get().combatState
	self.state:applyServerState(payload)

	local newState = self.state:get().combatState

	-- Lot 05 (finition) — Annulation propre du QTE en cours dès qu'il ne peut plus aboutir :
	-- le serveur quitte ChoosingAction (choix résolu OU tour expiré côté serveur), la
	-- session change (nouvelle rencontre), ou le combat se termine. On arrête la boucle,
	-- on coupe la saisie, on masque la barre et on n'envoie pas la charge utile périmée.
	local newSessionId = payload.sessionId
	local leftChoosing = previous == "ChoosingAction" and newState ~= "ChoosingAction"
	local sessionChanged = self._sessionId ~= nil and newSessionId ~= nil and newSessionId ~= self._sessionId
	local combatEnded = newState == "Victory" or newState == "Defeat" or newState == "Escaped"
	if self._qteActive and (leftChoosing or sessionChanged or combatEnded) then
		self.qte:cancel()
		self._qteActive = false
		self._actionPending = false
	end
	self._sessionId = newSessionId

	if newState ~= previous then
		local message = STATE_MESSAGES[newState]
		if message then
			self.state:pushMessage(message)
		end
		-- Lot 05 — Nouveau tour de choix : on rouvre le menu (verrous réinitialisés).
		if newState == "ChoosingAction" then
			self._actionPending = false
			self._qteActive = false
		end
	end
	self:_refreshTurnOrder(newState)
	self:_refreshMenu()
end

-- Lot 05 — Réapplique l'état d'activation du menu d'après les verrous courants.
-- (L'abonnement d'état ne se déclenche que sur changement ; ces verrous changent aussi
-- en dehors d'un message serveur, par exemple à la fin d'un QTE.)
function CombatUI:_refreshMenu()
	local data = self.state:get()
	self.actionMenu:setEnabled(data.canAct and not self._qteActive and not self._actionPending)
end

-- Le joueur a cliqué/tapé une action. Une action offensive (profil de QTE) déclenche
-- d'abord le QTE ; les autres sont transmises directement au serveur (autoritaire).
function CombatUI:_onActionChosen(actionId: string)
	if self._qteActive or self._actionPending then
		return
	end

	if Qte.profileForAction(actionId) then
		self:_startOffensiveQte(actionId)
		return
	end

	local ok, remote = pcall(function()
		return Remotes.get("PlayerCombatAction")
	end)
	if ok and remote and remote:IsA("RemoteEvent") then
		remote:FireServer(actionId)
	end
	-- Retour visuel local immédiat (le serveur reste seul juge du résultat).
	self.state:pushMessage(("Action choisie : %s"):format(actionId))
end

-- Lot 05 (sécurité) — Demande d'abord un défi au serveur (autoritaire), puis joue le
-- QTE et soumet les positions accompagnées du challengeId. Le verrou est posé avant la
-- requête (qui cède la main) pour empêcher tout double-déclenchement, et relâché si le
-- serveur refuse ou si rien n'est joué — `_actionPending` ne reste jamais bloqué.
function CombatUI:_startOffensiveQte(actionId: string)
	self._actionPending = true
	self:_refreshMenu()

	-- Requête synchrone du défi (RemoteFunction). Toute erreur/refus relâche le verrou.
	local ok, response = pcall(function()
		local remote = Remotes.getFunction("RequestOffensiveQte")
		if remote and remote:IsA("RemoteFunction") then
			return remote:InvokeServer(actionId)
		end
		return nil
	end)

	if not ok or type(response) ~= "table" or response.accepted ~= true then
		local reason = (type(response) == "table" and response.reason) or "indisponible"
		self.state:pushMessage(("QTE refusé par le serveur (%s)."):format(tostring(reason)))
		self._qteActive = false
		self._actionPending = false
		self:_refreshMenu()
		return
	end

	local challengeId = response.challengeId
	self._qteActive = true
	self:_refreshMenu()
	self.state:pushMessage("QTE : arrêtez chaque curseur dans la zone.")

	self.qte:run(actionId, function(result)
		self._qteActive = false
		if result then
			local sent = pcall(function()
				local remote = Remotes.get("PlayerOffensiveQte")
				if remote and remote:IsA("RemoteEvent") then
					remote:FireServer({
						challengeId = challengeId,
						action = actionId,
						cursors = result.cursors,
						duration = result.duration,
					})
				end
			end)
			if not sent then
				-- Échec d'envoi : relâche le verrou pour ne pas bloquer le joueur.
				self._actionPending = false
			end
		else
			-- Aucun QTE à jouer (sécurité) : on relâche le verrou d'action.
			self._actionPending = false
		end
		self:_refreshMenu()
	end)
end

-- Lot 05 — Réponse autoritaire du serveur au QTE offensif (affichage seul). Couvre les
-- deux cas : verdict accepté (résultat/dégâts) et refus explicite (déblocage du menu).
function CombatUI:_onOffensiveOutcome(payload: { [string]: any })
	if type(payload) ~= "table" then
		return
	end

	-- Refus explicite : le tour n'a pas été consommé, on relâche le verrou pour rejouer.
	if payload.accepted == false then
		self._qteActive = false
		self._actionPending = false
		self.state:pushMessage(("QTE rejeté par le serveur (%s)."):format(tostring(payload.reason)))
		self:_refreshMenu()
		return
	end

	local outcome = payload.outcome
	local damage = if type(payload.damage) == "number" then payload.damage else 0
	local message
	if outcome == "Perfect" then
		message = ("Attaque parfaite ! +%d %% (%d dégâts)."):format(PERFECT_BONUS_PERCENT, damage)
	elseif outcome == "Normal" then
		message = ("Attaque normale (%d dégâts)."):format(damage)
	elseif outcome == "Cancelled" then
		message = "Attaque annulée — ressources et tour perdus."
	else
		message = "QTE offensif résolu."
	end
	self.state:pushMessage(message)
end

-- Démarre l'UI : parente le ScreenGui et écoute le serveur.
function CombatUI:start()
	local player = Players.LocalPlayer
	if not player then
		return
	end
	local playerGui = player:WaitForChild("PlayerGui")
	self.gui.Parent = playerGui

	local ok, remote = pcall(function()
		return Remotes.get("CombatStateChanged")
	end)
	if ok and remote and remote:IsA("RemoteEvent") then
		remote.OnClientEvent:Connect(function(payload)
			self:_onServerState(payload)
		end)
	end

	-- Lot 04 — Instantané autoritaire des ressources (Essence, coûts, recharges, durée).
	local okRes, resRemote = pcall(function()
		return Remotes.get("CombatResourcesChanged")
	end)
	if okRes and resRemote and resRemote:IsA("RemoteEvent") then
		resRemote.OnClientEvent:Connect(function(payload)
			if type(payload) == "table" then
				self.state:applyResources(payload)
			end
		end)
	end

	-- Lot 05 — Verdict autoritaire du QTE offensif (affichage du résultat/dégâts).
	local okQte, qteRemote = pcall(function()
		return Remotes.get("OffensiveQteOutcome")
	end)
	if okQte and qteRemote and qteRemote:IsA("RemoteEvent") then
		qteRemote.OnClientEvent:Connect(function(payload)
			self:_onOffensiveOutcome(payload)
		end)
	end

	-- Lot 04 — Chronomètre du tour : décompte local piloté par l'horloge serveur
	-- synchronisée (turnEndsAt). Affiché seulement pendant la phase de choix du joueur.
	self._timerConn = RunService.Heartbeat:Connect(function()
		local data = self.state:get()
		local endsAt = data.turnEndsAt
		if data.canAct and type(endsAt) == "number" then
			self.centerZone:setTimer(endsAt - Workspace:GetServerTimeNow())
		else
			self.centerZone:setTimer(nil)
		end
	end)
end

-- API de test manuel (Studio) : injecter des valeurs d'affichage sans serveur.
-- Exemple : CombatUI:simulate({ hp = 18, maxHp = 30, essence = 4, soulFragments = 2 })
function CombatUI:simulate(partial: { [string]: any })
	self.state:applyDisplay(partial)
end

-- API de test manuel : forcer une phase de combat (active/désactive les boutons).
function CombatUI:simulateState(combatState: string, round: number?)
	self:_onServerState({ state = combatState, round = round or self.state:get().round })
end

return CombatUI
