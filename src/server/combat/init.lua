--!strict
-- CombatService
-- Lot 02 — Point d'entrée du moteur de combat côté serveur.
-- Branche les déclencheurs de la zone de test (Loup/Bandit) sur le démarrage d'une
-- session, route les actions soumises par le joueur vers sa session, et garantit
-- qu'un joueur n'a qu'un seul combat à la fois.
-- Ne touche pas à la zone de test elle-même (lot 01) : il s'y connecte simplement.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))

local CombatSession = require(script:WaitForChild("CombatSession"))

local CombatService = {}

-- Une session active par joueur (prototype solo).
local sessionsByPlayer: { [Player]: any } = {}

local ZONE_NAME = "CombatTestZone"

-- Démarre un combat pour un joueur contre la créature désignée, s'il est libre.
function CombatService.startCombat(player: Player, creatureKey: string)
	if sessionsByPlayer[player] then
		print(("[CombatService] %s est déjà en combat : démarrage ignoré."):format(player.Name))
		return
	end
	if not player.Character then
		print(("[CombatService] %s n'a pas de personnage : démarrage ignoré."):format(player.Name))
		return
	end

	local session = CombatSession.new(CombatService, player, creatureKey)
	sessionsByPlayer[player] = session
	print(("[CombatService] Combat démarré : %s vs %s."):format(player.Name, creatureKey))
	session:start()
end

-- Rappelé par une session quand elle s'achève (libère la référence du joueur).
function CombatService:_onSessionEnded(session: any)
	local player = session.player
	if player and sessionsByPlayer[player] == session then
		sessionsByPlayer[player] = nil
	end
	print(("[CombatService] Session %s terminée et libérée."):format(session.id))
end

-- Connecte les ClickDetector existants des déclencheurs de la zone de test.
local function wireTriggers()
	local zone = workspace:WaitForChild(ZONE_NAME, 30)
	if not zone then
		warn("[CombatService] Zone de test introuvable : aucun déclencheur câblé.")
		return
	end

	for _, child in zone:GetChildren() do
		local click = child:FindFirstChildOfClass("ClickDetector")
		if click then
			local creatureKey = child.Name
			click.MouseClick:Connect(function(player: Player)
				CombatService.startCombat(player, creatureKey)
			end)
		end
	end
end

-- À appeler une fois côté serveur, après la génération de la zone de test.
function CombatService.init()
	-- Route les actions soumises par le client vers la session du joueur (serveur autoritaire).
	local actionRemote = Remotes.get("PlayerCombatAction")
	if actionRemote:IsA("RemoteEvent") then
		actionRemote.OnServerEvent:Connect(function(player: Player, action: any)
			local session = sessionsByPlayer[player]
			if session then
				session:submitAction(player, action)
			end
		end)
	end

	-- Lot 05 (sécurité) — Demande de démarrage d'un QTE offensif (RemoteFunction). Le
	-- serveur valide le tour et renvoie un défi unique, ou un refus explicite.
	local qteRequest = Remotes.getFunction("RequestOffensiveQte")
	if qteRequest:IsA("RemoteFunction") then
		qteRequest.OnServerInvoke = function(player: Player, action: any)
			local session = sessionsByPlayer[player]
			if session then
				return session:requestOffensiveQte(player, action)
			end
			return { accepted = false, reason = "no-session" }
		end
	end

	-- Lot 05 — Route le résultat d'un QTE offensif vers la session du joueur. Le serveur
	-- valide le défi puis recalcule le verdict avant d'appliquer les conséquences.
	local qteRemote = Remotes.get("PlayerOffensiveQte")
	if qteRemote:IsA("RemoteEvent") then
		qteRemote.OnServerEvent:Connect(function(player: Player, payload: any)
			local session = sessionsByPlayer[player]
			if session then
				session:submitOffensiveQte(player, payload)
			end
		end)
	end

	-- Filet de sécurité : si une session n'a pas déjà géré le départ du joueur,
	-- on s'assure que sa référence est libérée.
	Players.PlayerRemoving:Connect(function(player: Player)
		local session = sessionsByPlayer[player]
		if session then
			session:abort("disconnect")
		end
	end)

	-- Branche les déclencheurs dans une coroutine (WaitForChild non bloquant).
	task.spawn(wireTriggers)

	print("[CombatService] Moteur de combat initialisé (déclencheurs Loup/Bandit prêts).")
end

return CombatService
