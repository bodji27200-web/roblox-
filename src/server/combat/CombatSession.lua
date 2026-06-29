--!strict
-- CombatSession
-- Lot 02 — Une session de combat serveur autoritaire, au tour par tour.
-- Responsabilités :
--   * porter l'état d'une rencontre (participants, manche courante, machine à états) ;
--   * verrouiller le déplacement, faire apparaître l'ennemi et une zone temporaire ;
--   * dérouler les manches : initiative recalculée, un tour par combattant vivant ;
--   * timer de 20 s côté joueur avec Garde automatique à expiration ;
--   * empêcher toute double action dans une manche ;
--   * atteindre un état terminal (Victory/Defeat/Escaped) puis Cleanup fiable.
-- Le serveur fait autorité : aucune action n'est validée sur la seule foi du client.
-- Pas de dégâts ni de kit ici (lots 04+/07/08) : les actions de tour sont neutres.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Types = require(Shared:WaitForChild("Types"))
-- Lot 05 — Logique partagée du QTE offensif (verdict recalculé côté serveur).
local Qte = require(Shared:WaitForChild("Qte"))

local CombatState = require(script.Parent:WaitForChild("CombatState"))
local Initiative = require(script.Parent:WaitForChild("Initiative"))

local States = CombatState.States

type CombatParticipant = Types.CombatParticipant

local TURN_SECONDS = Config.Combat.TURN_CHOICE_SECONDS
local AUTO_TIMEOUT_ACTION = Config.Combat.AUTO_TIMEOUT_ACTION
local ENEMY_DEFAULT_ACTION = Config.Combat.ENEMY_DEFAULT_ACTION
local GUARD_ACTION = AUTO_TIMEOUT_ACTION -- la Garde est l'action défensive par défaut.
local ESCAPE_ACTION = "Fuite"

-- Lot 04 — Configuration Essence/cooldowns (autoritaire côté serveur).
local Essence = Config.Essence
local ActionRules = Config.ActionRules

-- Lot 05 — Configuration du QTE offensif (profils, dégâts de base) et règles de dégâts.
local QteConfig = Config.Qte
local DAMAGE = Config.Combat.DAMAGE

local CombatSession = {}
CombatSession.__index = CombatSession

local nextSessionId = 0

-- ---------------------------------------------------------------------------
-- Construction
-- ---------------------------------------------------------------------------

-- service : le gestionnaire (CombatService) notifié à la fin de la session.
-- player  : le joueur engagé dans le combat (prototype solo).
-- creatureKey : clé de Config.Creatures (« Loup » / « Bandit »).
function CombatSession.new(service: any, player: Player, creatureKey: string)
	nextSessionId += 1

	local self = setmetatable({}, CombatSession)
	self.id = "combat-" .. tostring(nextSessionId)
	self.service = service
	self.player = player
	self.creatureKey = creatureKey
	self.round = 0
	self._active = true
	self._cleaned = false
	-- Fonction de résolution du tour joueur en attente (nil si aucun tour en attente).
	self._resolveTurn = nil :: ((action: string) -> ())?
	-- Lot 05 — Verdict d'un QTE offensif en attente d'application (posé avant de
	-- résoudre le tour, consommé dans _applyAction). nil si l'action n'a pas de QTE.
	self._pendingOffensive = nil :: { action: string, outcome: string, multiplier: number, cancelled: boolean }?
	-- Lot 05 (sécurité) — Défi QTE en cours (unique, lié à la session et au tour). Posé
	-- par requestOffensiveQte, consommé (usage unique) par submitOffensiveQte. nil sinon.
	self._qteChallenge = nil :: any
	self._qteChallengeSeq = 0
	-- Lot 04 — Horodatage serveur synchronisé de fin du tour joueur (chronomètre UI).
	self._turnEndsAt = nil :: number?
	-- Suivi pour le nettoyage fiable.
	self._connections = {} :: { RBXScriptConnection }
	self._instances = {} :: { Instance }
	self._movementRestore = {} :: { { humanoid: Humanoid, walkSpeed: number, jumpHeight: number, jumpPower: number } }

	self.state = CombatState.new(function(from: string, to: string)
		print(("[CombatSession %s] %s -> %s (manche %d)"):format(self.id, from, to, self.round))
	end)

	self.participants = self:_buildParticipants(player, creatureKey)

	return self
end

-- Construit les combattants : le joueur et l'ennemi décrit en configuration.
function CombatSession:_buildParticipants(player: Player, creatureKey: string): { CombatParticipant }
	local creature = Config.Creatures[creatureKey]

	local playerParticipant: CombatParticipant = {
		id = "player-" .. tostring(player.UserId),
		displayName = player.DisplayName,
		side = "Player",
		-- La Clairvoyance détaillée du joueur arrivera avec le kit (lot 07) ;
		-- valeur neutre de prototype pour le moteur de tours.
		clairvoyance = 6,
		maxHp = 30,
		hp = 30,
		player = player,
		model = nil,
		isGuarding = false,
		hasActedThisRound = false,
		-- Lot 04 — Essence démarrant à la valeur de configuration (0), aucune recharge.
		essence = Essence.START_OF_COMBAT,
		cooldowns = {},
		personalTurns = 0,
	}

	local enemyParticipant: CombatParticipant = {
		id = "enemy-" .. creatureKey,
		displayName = (creature and creature.displayName) or creatureKey,
		side = "Enemy",
		clairvoyance = (creature and creature.clairvoyance) or 5,
		maxHp = (creature and creature.maxHp) or 10,
		hp = (creature and creature.maxHp) or 10,
		player = nil,
		model = nil,
		isGuarding = false,
		hasActedThisRound = false,
		-- Lot 04 — Les ennemis sont aussi des combattants (Essence générique, non affichée).
		essence = Essence.START_OF_COMBAT,
		cooldowns = {},
		personalTurns = 0,
	}

	return { playerParticipant, enemyParticipant }
end

-- ---------------------------------------------------------------------------
-- Suivi des ressources (nettoyage)
-- ---------------------------------------------------------------------------

function CombatSession:_trackConnection(conn: RBXScriptConnection)
	table.insert(self._connections, conn)
end

function CombatSession:_trackInstance(inst: Instance)
	table.insert(self._instances, inst)
end

-- ---------------------------------------------------------------------------
-- Essence et cooldowns (autoritaires côté serveur) — Lot 04
-- ---------------------------------------------------------------------------

-- Ajoute (ou retire si négatif) de l'Essence à un combattant en restant borné
-- entre 0 et le maximum de configuration. Gère le cas « déjà à 6 » sans dépassement.
function CombatSession:_grantEssence(participant: CombatParticipant, amount: number)
	if amount == 0 then
		return
	end
	participant.essence = math.clamp(participant.essence + amount, 0, Essence.MAX)
end

-- Début d'un tour personnel : gain de +1 Essence.
-- Les recharges ne sont PAS décomptées ici mais à la FIN du tour (voir
-- _endPersonalTurn), en ignorant l'action armée pendant ce tour. La valeur stockée
-- reste ainsi le nombre réel de tours restants, ce qui garde l'affichage cohérent.
function CombatSession:_beginPersonalTurn(participant: CombatParticipant)
	participant.personalTurns += 1

	-- +1 Essence au début de chaque tour personnel (plafonné à MAX).
	self:_grantEssence(participant, Essence.GAIN_PER_PERSONAL_TURN)
end

-- Fin d'un tour personnel : décompte les recharges en cours (un tour personnel
-- écoulé), en IGNORANT l'action utilisée ce tour-ci — elle vient d'être armée et ne
-- doit pas perdre un tour immédiatement. Appelé pour CHAQUE combattant à la fin de
-- SON tour : les tours des autres ne réduisent jamais ses recharges (décompte en
-- tours personnels uniquement).
--
-- Avec ce schéma, la recharge stocke sa valeur réelle C : utilisée au tour N, l'action
-- reste indisponible pendant C tours personnels complets (N+1..N+C) et redevient
-- disponible au tour N+C+1. L'UI affiche exactement C, puis C-1, ... 0 (jamais C+1).
function CombatSession:_endPersonalTurn(participant: CombatParticipant, usedAction: string?)
	for actionId, remaining in participant.cooldowns do
		if actionId == usedAction then
			-- Recharge armée pendant CE tour : ne pas la décompter tout de suite.
			continue
		end
		local left = remaining - 1
		if left <= 0 then
			participant.cooldowns[actionId] = nil
		else
			participant.cooldowns[actionId] = left
		end
	end
end

-- Valide qu'une action soumise par le client est utilisable : action connue
-- (déclarée en configuration), Essence suffisante et recharge écoulée. Renvoie
-- (autorisé, raison?) ; la raison sert aux logs. Les cinq actions du menu sont
-- toutes déclarées dans ActionRules ; toute autre valeur est forgée et refusée.
function CombatSession:_canUseAction(participant: CombatParticipant, action: string): (boolean, string?)
	local rule = ActionRules[action]
	if not rule then
		-- Refus strict d'une action inconnue (hors menu autorisé / soumission forgée).
		return false, "unknown"
	end
	if (participant.cooldowns[action] or 0) > 0 then
		return false, "cooldown"
	end
	if participant.essence < rule.essenceCost then
		return false, "essence"
	end
	return true, nil
end

-- Applique les conséquences Essence/recharge d'une action résolue (coût débité,
-- gain accordé, recharge armée). `cancelled` : vrai si l'action a été annulée
-- (QTE offensif du lot 05) — dans ce cas l'attaque de base n'accorde pas d'Essence.
function CombatSession:_applyActionResources(participant: CombatParticipant, action: string, cancelled: boolean)
	local rule = ActionRules[action]
	if not rule then
		return
	end

	-- 1) Débiter le coût (déjà validé : ne descend jamais sous 0 par sécurité).
	participant.essence = math.max(0, participant.essence - rule.essenceCost)

	-- 2) Accorder le gain d'Essence propre à l'action.
	local gain = 0
	if rule.isBaseAttack then
		-- Attaque de base : +1 seulement si l'action n'a pas été annulée.
		if not cancelled then
			gain = Essence.GAIN_BASE_ATTACK
		end
	elseif rule.isMeditate then
		gain = Essence.GAIN_MEDITATE
	end
	self:_grantEssence(participant, gain)

	-- 3) Armer la recharge à sa valeur réelle C (comptée en tours personnels).
	-- Le décompte se fait à la FIN de chaque tour personnel SUIVANT (voir
	-- _endPersonalTurn, qui ignore l'action armée ce tour-ci) : l'action reste
	-- indisponible pendant C tours complets (N+1..N+C) et redevient disponible au
	-- tour N+C+1. Stocker C (et non C+1) garde un nombre de tours restants cohérent
	-- à l'affichage. Ex. recharge 2 : indisponible aux tours N+1 et N+2, disponible
	-- au tour N+3 ; l'UI affiche 2, puis 1, puis 0.
	if rule.cooldownPersonalTurns > 0 then
		participant.cooldowns[action] = rule.cooldownPersonalTurns
	end
end

-- Combattant joueur de la session (côté "Player").
function CombatSession:_playerParticipant(): CombatParticipant?
	for _, p in self.participants do
		if p.side == "Player" then
			return p
		end
	end
	return nil
end

-- Réplique au client l'instantané autoritaire des ressources du joueur :
-- Essence courante/max, chronomètre du tour et, par action, coût/recharge/dispo.
-- L'UI (lot 03) ne fait qu'afficher : aucune décision côté client.
function CombatSession:_firePlayerResources()
	local p = self:_playerParticipant()
	if not p then
		return
	end

	local actions: { [string]: any } = {}
	for actionId, rule in ActionRules do
		local remaining = p.cooldowns[actionId] or 0
		actions[actionId] = {
			cost = rule.essenceCost,
			cooldownRemaining = remaining,
			available = remaining <= 0 and p.essence >= rule.essenceCost,
		}
	end

	local ok, remote = pcall(function()
		return Remotes.get("CombatResourcesChanged")
	end)
	if ok and remote and remote:IsA("RemoteEvent") and self.player and self.player.Parent then
		remote:FireClient(self.player, {
			sessionId = self.id,
			essence = p.essence,
			essenceMax = Essence.MAX,
			turnEndsAt = self._turnEndsAt,
			turnSeconds = TURN_SECONDS,
			actions = actions,
		})
	end
end

-- ---------------------------------------------------------------------------
-- Cycle de vie
-- ---------------------------------------------------------------------------

-- Démarre la session : passe Idle -> Starting, prépare la scène, puis lance la
-- boucle de manches dans une coroutine dédiée.
function CombatSession:start()
	self.state:transition(States.Starting)

	-- Surveille la déconnexion du joueur pendant tout le combat.
	self:_trackConnection(Players.PlayerRemoving:Connect(function(leaving: Player)
		if leaving == self.player then
			self:abort("disconnect")
		end
	end))

	self:_setupScene()
	self:_fireState()
	-- Instantané initial des ressources dès le démarrage du combat : l'UI affiche
	-- l'Essence de départ et la disponibilité des actions depuis des données serveur
	-- fiables, sans attendre le premier tour personnel.
	self:_firePlayerResources()

	-- La boucle tourne dans sa propre coroutine : le timer de tour peut y céder
	-- la main sans bloquer le reste du serveur.
	self._loopThread = task.spawn(function()
		self:_runRounds()
	end)
end

-- Prépare la scène : verrou de déplacement, apparition de l'ennemi, zone temporaire.
function CombatSession:_setupScene()
	local character = self.player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	-- 1) Verrouiller le déplacement du joueur (restauré au Cleanup).
	if humanoid then
		table.insert(self._movementRestore, {
			humanoid = humanoid,
			walkSpeed = humanoid.WalkSpeed,
			jumpHeight = humanoid.JumpHeight,
			jumpPower = humanoid.JumpPower,
		})
		humanoid.WalkSpeed = 0
		humanoid.JumpHeight = 0
		humanoid.JumpPower = 0
	end

	-- Point d'ancrage de la rencontre : devant le joueur si possible, sinon origine.
	local anchorCFrame = rootPart and (rootPart.CFrame * CFrame.new(0, 0, -8)) or CFrame.new(0, 4, 0)

	-- 2) Zone de combat temporaire (repère visuel, non collidable).
	local arena = Instance.new("Part")
	arena.Name = "CombatArena_" .. self.id
	arena.Anchored = true
	arena.CanCollide = false
	arena.CanQuery = false
	arena.Size = Vector3.new(24, 1, 24)
	arena.CFrame = CFrame.new(anchorCFrame.Position - Vector3.new(0, 3, 0))
	arena.Transparency = 0.6
	arena.Color = Color3.fromRGB(40, 60, 90)
	arena.Material = Enum.Material.ForceField
	arena.Parent = workspace
	self:_trackInstance(arena)

	-- 3) Apparition de l'ennemi devant le joueur (placeholder, pas d'asset).
	local enemyParticipant = self:_enemyParticipant()
	local enemyModel = Instance.new("Model")
	enemyModel.Name = "Enemy_" .. self.creatureKey

	local enemyPart = Instance.new("Part")
	enemyPart.Name = "Body"
	enemyPart.Anchored = true
	enemyPart.Size = Vector3.new(3, 5, 3)
	enemyPart.CFrame = anchorCFrame * CFrame.new(0, 2.5, 0)
	enemyPart.Color = Color3.fromRGB(150, 70, 70)
	enemyPart.Material = Enum.Material.SmoothPlastic
	enemyPart.Parent = enemyModel
	enemyModel.PrimaryPart = enemyPart
	enemyModel.Parent = workspace

	if enemyParticipant then
		enemyParticipant.model = enemyModel
	end
	self:_trackInstance(enemyModel)
end

-- Boucle principale : une manche après l'autre, jusqu'à un état terminal.
function CombatSession:_runRounds()
	while self._active do
		self.round += 1

		-- Début de manche : réinitialise les drapeaux de tour et recalcule l'ordre.
		for _, p in self.participants do
			p.hasActedThisRound = false
			p.isGuarding = false
		end
		local order = Initiative.order(self.participants)

		-- Un tour par combattant vivant, dans l'ordre d'initiative.
		for _, participant in order do
			if not self._active then
				break
			end
			-- Anti double-action : sécurité même si l'ordre changeait en cours de route.
			if participant.hasActedThisRound then
				continue
			end
			if not Initiative.isAlive(participant) then
				continue
			end
			self:_takeTurn(participant)
		end

		if not self._active then
			break
		end

		-- Fin de manche : vérifie les conditions de fin.
		self.state:transition(States.RoundEnd)
		self:_fireState()

		local ending = self:_checkEndConditions()
		if ending then
			self:_finish(ending)
			break
		end
		-- Sinon : on repart pour une nouvelle manche (initiative recalculée au début).
	end
end

-- Déroule le tour d'un combattant.
function CombatSession:_takeTurn(participant: CombatParticipant)
	-- Verrou anti double-action posé dès l'entrée du tour.
	participant.hasActedThisRound = true

	-- Lot 04 — Début du tour personnel : gain de +1 Essence (recharges décomptées
	-- en fin de tour, voir _endPersonalTurn).
	self:_beginPersonalTurn(participant)

	local usedAction: string?
	if participant.side == "Player" then
		self.state:transition(States.ChoosingAction)
		-- Lot 05 (sécurité) — Tout défi QTE d'un tour précédent est invalidé à l'entrée
		-- du nouveau tour (un défi reste lié au tour où il a été émis).
		self._qteChallenge = nil
		-- Chronomètre du tour : fin = maintenant + durée (horloge serveur synchronisée).
		self._turnEndsAt = workspace:GetServerTimeNow() + TURN_SECONDS
		self:_fireState()
		-- Réplique l'Essence gagnée, le chronomètre et la disponibilité des actions.
		self:_firePlayerResources()

		local action = self:_awaitPlayerChoice(participant)
		self._turnEndsAt = nil
		if not self._active then
			return
		end
		usedAction = action
		self:_applyAction(participant, action)
		-- Réplique l'Essence/recharges mises à jour après résolution.
		self:_firePlayerResources()
	else
		-- Ennemi : aucune IA au lot 02. Action neutre par défaut.
		usedAction = ENEMY_DEFAULT_ACTION
		self:_applyAction(participant, ENEMY_DEFAULT_ACTION)
	end

	-- Fin du tour personnel : décompte des recharges après la résolution, en
	-- ignorant l'action armée ce tour-ci (affichage et timing cohérents).
	self:_endPersonalTurn(participant, usedAction)
end

-- Attend le choix du joueur pendant TURN_SECONDS. À expiration : Garde automatique.
-- Implémenté en cédant la coroutine de boucle, réveillée soit par submitAction,
-- soit par le délai d'expiration — la première résolution gagne.
function CombatSession:_awaitPlayerChoice(participant: CombatParticipant): string
	local thread = coroutine.running()
	local resolved = false
	local chosen: string = AUTO_TIMEOUT_ACTION

	local function resolve(action: string)
		if resolved then
			return
		end
		resolved = true
		self._resolveTurn = nil
		chosen = action
		if coroutine.status(thread) == "suspended" then
			task.spawn(thread)
		end
	end

	-- Exposé au serveur (remote/déconnexion) pour résoudre ce tour précis.
	self._resolveTurn = resolve

	-- Timer de 20 s : applique la Garde automatiquement si rien n'a été choisi.
	task.delay(TURN_SECONDS, function()
		if not resolved and self._active then
			print(("[CombatSession %s] Timer expiré pour %s : Garde automatique."):format(self.id, participant.displayName))
			resolve(AUTO_TIMEOUT_ACTION)
		end
	end)

	coroutine.yield()
	return chosen
end

-- Applique l'action choisie/par défaut d'un combattant (résolution neutre au lot 02).
function CombatSession:_applyAction(participant: CombatParticipant, action: string)
	if action == ESCAPE_ACTION and participant.side == "Player" then
		-- Fuite : on rejoint directement l'état terminal Escaped.
		self.state:transition(States.Escaped)
		self:_fireState()
		self:_finish("Escaped")
		return
	end

	-- Lot 05 — Action offensive résolue via un QTE : applique le verdict en attente
	-- (bonus parfait, normal, ou annulation avec ressources/tour tout de même consommés).
	local offensive = self._pendingOffensive
	if offensive and offensive.action == action then
		self._pendingOffensive = nil
		self:_resolveOffensive(participant, action, offensive)
		return
	end

	-- Lot 04 — Conséquences Essence/recharge de l'action résolue (coût, gain, cooldown).
	-- `cancelled` reste faux ici : l'annulation provient du QTE offensif (lot 05).
	self:_applyActionResources(participant, action, false)

	if action == GUARD_ACTION then
		self.state:transition(States.Defending)
		participant.isGuarding = true
	else
		-- Action générique : pas de dégâts ni de kit au lot 02 (résolution neutre).
		self.state:transition(States.ResolvingAction)
	end
	self:_fireState()
end

-- ---------------------------------------------------------------------------
-- QTE offensif — Lot 05
-- ---------------------------------------------------------------------------

-- Applique le verdict d'un QTE offensif déjà calculé (autoritaire).
-- Dans TOUS les cas le tour et les ressources sont consommés : c'est `cancelled` qui
-- distingue une annulation (aucun gain d'Essence d'attaque, aucun dégât, animation
-- d'échec côté client) d'une attaque réussie (dégâts bonifiés du bonus parfait configuré).
function CombatSession:_resolveOffensive(participant: CombatParticipant, action: string, offensive: any)
	local cancelled: boolean = offensive.cancelled == true

	-- Ressources/tour consommés même en cas d'annulation (cancelled propagé : pas de
	-- gain d'Essence d'attaque de base si annulée, recharge tout de même armée).
	self:_applyActionResources(participant, action, cancelled)

	-- Dégâts appliqués uniquement si l'attaque n'a pas été annulée (bonus inclus).
	local damage = 0
	if not cancelled then
		damage = self:_applyOffensiveDamage(participant, offensive.multiplier)
	end

	-- Résolution neutre côté machine à états (l'échec se traduit visuellement côté
	-- client via OffensiveQteOutcome ; pas d'état dédié pour ne pas toucher au lot 02).
	self.state:transition(States.ResolvingAction)
	self:_fireState()

	print(("[CombatSession %s] QTE offensif « %s » : %s (x%.2f, %d dégâts)."):format(
		self.id, action, tostring(offensive.outcome), offensive.multiplier, damage
	))

	self:_fireOffensiveOutcome(action, offensive.outcome, offensive.multiplier, damage)
end

-- Inflige les dégâts d'une attaque offensive à la cible adverse, multiplicateur du QTE
-- inclus (1.0 normale, 1.2 parfaite). Dégâts de base provisoires (QteConfig) ; arrondi
-- et plancher repris des règles de dégâts du prototype (CombatConfig.DAMAGE).
function CombatSession:_applyOffensiveDamage(attacker: CombatParticipant, multiplier: number): number
	local target = if attacker.side == "Player" then self:_enemyParticipant() else self:_playerParticipant()
	if not target then
		return 0
	end

	local raw = QteConfig.BASE_ATTACK_DAMAGE * multiplier
	local dmg = if DAMAGE.ROUND_REMAINING_UP then math.ceil(raw) else math.floor(raw)
	-- Une attaque non annulée inflige au minimum le plancher de dégâts du prototype.
	dmg = math.max(dmg, DAMAGE.MIN_DAMAGE_IF_NOT_CANCELLED)

	target.hp = math.max(0, target.hp - dmg)
	return dmg
end

-- Réplique au client le verdict autoritaire du QTE offensif (affichage + animation).
function CombatSession:_fireOffensiveOutcome(action: string, outcome: string, multiplier: number, damage: number)
	local ok, remote = pcall(function()
		return Remotes.get("OffensiveQteOutcome")
	end)
	if ok and remote and remote:IsA("RemoteEvent") and self.player and self.player.Parent then
		remote:FireClient(self.player, {
			sessionId = self.id,
			action = action,
			accepted = true,
			outcome = outcome,
			multiplier = multiplier,
			damage = damage,
		})
	end
end

-- Conditions de fin basées sur les PV. Au lot 02 aucun dégât n'est infligé : le
-- combat se termine donc par fuite ou déconnexion. La logique reste branchée pour
-- les lots suivants (dégâts au lot 04, ennemis au lot 08).
function CombatSession:_checkEndConditions(): string?
	local playersAlive, enemiesAlive = false, false
	for _, p in self.participants do
		if Initiative.isAlive(p) then
			if p.side == "Player" then
				playersAlive = true
			else
				enemiesAlive = true
			end
		end
	end
	if not enemiesAlive then
		return States.Victory
	end
	if not playersAlive then
		return States.Defeat
	end
	return nil
end

-- Passe à l'état terminal demandé (si nécessaire) puis lance le nettoyage.
function CombatSession:_finish(result: string)
	if not self._active then
		return
	end
	if self.state:get() ~= result then
		self.state:transition(result)
		self:_fireState()
	end
	self._active = false
	self:_cleanup()
end

-- Interruption inconditionnelle (déconnexion, arrêt serveur) : Cleanup garanti
-- depuis n'importe quel état actif, sans passer par un état terminal.
function CombatSession:abort(reason: string)
	if self._cleaned then
		return
	end
	print(("[CombatSession %s] Interruption (%s)."):format(self.id, reason))
	self._active = false
	-- Débloque la coroutine si elle attendait un choix.
	if self._resolveTurn then
		local resolve = self._resolveTurn
		self._resolveTurn = nil
		resolve(AUTO_TIMEOUT_ACTION)
	end
	self:_cleanup()
end

-- Nettoyage fiable : restaure le déplacement, déconnecte tout, détruit les instances.
-- Idempotent : un seul nettoyage effectif quel que soit le chemin de sortie.
function CombatSession:_cleanup()
	if self._cleaned then
		return
	end
	self._cleaned = true
	self._active = false
	self._resolveTurn = nil

	-- Atteindre Cleanup depuis l'état courant (toujours autorisé pour les états actifs
	-- et terminaux).
	local current = self.state:get()
	if current ~= States.Cleanup and current ~= States.Idle then
		self.state:transition(States.Cleanup)
	end

	-- 1) Restaurer le déplacement du joueur.
	for _, entry in self._movementRestore do
		local humanoid = entry.humanoid
		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed = entry.walkSpeed
			humanoid.JumpHeight = entry.jumpHeight
			humanoid.JumpPower = entry.jumpPower
		end
	end
	table.clear(self._movementRestore)

	-- 2) Déconnecter toutes les connexions suivies.
	for _, conn in self._connections do
		conn:Disconnect()
	end
	table.clear(self._connections)

	-- 3) Détruire toutes les instances créées (ennemi, zone).
	for _, inst in self._instances do
		if inst then
			inst:Destroy()
		end
	end
	table.clear(self._instances)

	-- Retour à l'état de repos.
	self.state:transition(States.Idle)

	-- Notifier le gestionnaire pour qu'il libère sa référence.
	if self.service and self.service._onSessionEnded then
		self.service:_onSessionEnded(self)
	end
end

-- ---------------------------------------------------------------------------
-- Entrées autoritaires (appelées par le serveur / les remotes)
-- ---------------------------------------------------------------------------

-- Soumission d'action par le joueur. Le serveur valide : bon joueur, bon état,
-- tour réellement en attente. Toute soumission invalide est ignorée.
function CombatSession:submitAction(player: Player, action: string): boolean
	if not self._active then
		return false
	end
	if player ~= self.player then
		return false
	end
	if self.state:get() ~= States.ChoosingAction then
		return false
	end
	if type(action) ~= "string" then
		return false
	end
	local resolve = self._resolveTurn
	if not resolve then
		return false
	end

	-- Lot 05 (sécurité) — Une action à QTE offensif ne peut PAS être résolue par la voie
	-- générique : elle doit obligatoirement passer par le flux de défi QTE
	-- (requestOffensiveQte puis submitOffensiveQte). On rejette donc « Attaque » & co.
	-- ici pour empêcher tout contournement du QTE via PlayerCombatAction.
	if Qte.profileForAction(action) then
		print(("[CombatSession %s] Action « %s » refusée : QTE offensif obligatoire."):format(self.id, action))
		return false
	end

	-- Lot 04 — Validation autoritaire du coût/recharge : une action trop chère ou
	-- encore en recharge est refusée. Le tour reste en attente (le joueur peut
	-- rechoisir) ; on réplique l'état des ressources pour rafraîchir l'UI.
	local participant = self:_playerParticipant()
	if participant then
		local allowed, reason = self:_canUseAction(participant, action)
		if not allowed then
			print(("[CombatSession %s] Action « %s » refusée (%s)."):format(self.id, action, tostring(reason)))
			self:_firePlayerResources()
			return false
		end
	end

	resolve(action)
	return true
end

-- Fenêtre d'expiration (secondes) d'un défi QTE pour un profil. Calée sur la durée
-- théorique au réglage de vitesse le PLUS LENT de l'outil dev (pour ne pas rejeter à
-- tort un QTE ralenti pendant un test), plus une marge réseau. Au-delà, un défi rejoué
-- plus tard est rejeté.
function CombatSession:_qteWindowSeconds(profile: any): number
	local count = profile.cursorCount
	local theoretical = (profile.cursorSeconds * count + profile.spacingSeconds * math.max(0, count - 1))
		/ QteConfig.Dev.MIN_SPEED_MULTIPLIER
	return theoretical + QteConfig.Challenge.EXTRA_SECONDS
end

-- Lot 05 (sécurité) — Demande de démarrage d'un QTE offensif (RemoteFunction). Le serveur
-- valide le tour courant et l'action, puis émet un DÉFI unique lié à la session et au tour
-- (challengeId, action, manche, tour personnel, startedAt, expiresAt). Retourne une réponse
-- EXPLICITE (accepted true/false + reason) : le client ne reste jamais bloqué en attente.
function CombatSession:requestOffensiveQte(player: Player, action: any): { [string]: any }
	if not self._active then
		return { accepted = false, reason = "inactive" }
	end
	if player ~= self.player then
		return { accepted = false, reason = "player" }
	end
	if self.state:get() ~= States.ChoosingAction or not self._resolveTurn then
		return { accepted = false, reason = "no-turn" }
	end
	if type(action) ~= "string" then
		return { accepted = false, reason = "action" }
	end

	local profile = Qte.profileForAction(action)
	if not profile then
		return { accepted = false, reason = "no-profile" }
	end

	local participant = self:_playerParticipant()
	if not participant then
		return { accepted = false, reason = "no-participant" }
	end

	local allowed, reason = self:_canUseAction(participant, action)
	if not allowed then
		self:_firePlayerResources()
		return { accepted = false, reason = reason or "unusable" }
	end

	-- Émission d'un défi unique (usage unique, lié au tour courant).
	self._qteChallengeSeq += 1
	local now = workspace:GetServerTimeNow()
	local challenge = {
		id = ("%s-qte-%d"):format(self.id, self._qteChallengeSeq),
		action = action,
		round = self.round,
		personalTurn = participant.personalTurns,
		startedAt = now,
		expiresAt = now + self:_qteWindowSeconds(profile),
	}
	self._qteChallenge = challenge

	print(("[CombatSession %s] Défi QTE « %s » émis (%s)."):format(self.id, action, challenge.id))

	return {
		accepted = true,
		challengeId = challenge.id,
		action = action,
		round = challenge.round,
		startedAt = challenge.startedAt,
		expiresAt = challenge.expiresAt,
	}
end

-- Refus explicite d'une soumission de QTE offensif : prévient le client (pour qu'il
-- débloque son menu) sans résoudre le tour (le joueur peut rejouer dans le même tour).
function CombatSession:_rejectOffensive(action: any, reason: string)
	print(("[CombatSession %s] QTE offensif rejeté (%s)."):format(self.id, tostring(reason)))
	local ok, remote = pcall(function()
		return Remotes.get("OffensiveQteOutcome")
	end)
	if ok and remote and remote:IsA("RemoteEvent") and self.player and self.player.Parent then
		remote:FireClient(self.player, {
			sessionId = self.id,
			action = if type(action) == "string" then action else nil,
			accepted = false,
			reason = tostring(reason),
		})
	end
end

-- Soumission finale du résultat d'un QTE offensif (Lot 05, sécurisé). Le serveur fait
-- autorité de bout en bout :
--   * le défi (challengeId) doit exister, correspondre à l'action et au TOUR courant,
--     ne pas être expiré, et n'avoir jamais servi (usage unique) ;
--   * les positions NaN/infinies/hors [0, 1] sont REJETÉES (aucune correction) ;
--   * la durée physique du QTE est validée raisonnablement (ni instantanée, ni au-delà
--     de la fenêtre du défi) ;
--   * le verdict est RECALCULÉ à partir des seules positions (jamais d'un verdict client).
-- Tout rejet renvoie une réponse explicite au client.
function CombatSession:submitOffensiveQte(player: Player, payload: any): boolean
	if not self._active then
		return false
	end
	if player ~= self.player then
		return false
	end
	if type(payload) ~= "table" then
		return false
	end

	local action = payload.action

	-- Un tour doit être réellement en attente, sinon le défi ne correspond plus.
	if self.state:get() ~= States.ChoosingAction or not self._resolveTurn then
		self:_rejectOffensive(action, "no-turn")
		return false
	end

	-- 1) Défi : présent, identifiant correspondant.
	local challenge = self._qteChallenge
	local challengeId = payload.challengeId
	if type(challengeId) ~= "string" or not challenge or challenge.id ~= challengeId then
		self:_rejectOffensive(action, "challenge")
		return false
	end

	-- 2) Action conforme au défi.
	if type(action) ~= "string" or action ~= challenge.action then
		self:_rejectOffensive(action, "action-mismatch")
		return false
	end

	local profile = Qte.profileForAction(action)
	if not profile then
		self._qteChallenge = nil
		self:_rejectOffensive(action, "no-profile")
		return false
	end

	local participant = self:_playerParticipant()
	if not participant then
		self._qteChallenge = nil
		self:_rejectOffensive(action, "no-participant")
		return false
	end

	-- 3) Le défi doit correspondre au TOUR courant (même manche et même tour personnel).
	if challenge.round ~= self.round or challenge.personalTurn ~= participant.personalTurns then
		self._qteChallenge = nil
		self:_rejectOffensive(action, "stale-turn")
		return false
	end

	-- 4) Expiration et durée physique raisonnable (anti-rejeu / anti-instantané).
	local now = workspace:GetServerTimeNow()
	if now > challenge.expiresAt then
		self._qteChallenge = nil
		self:_rejectOffensive(action, "expired")
		return false
	end
	local serverElapsed = now - challenge.startedAt
	if serverElapsed < QteConfig.Challenge.MIN_PHYSICAL_SECONDS then
		self._qteChallenge = nil
		self:_rejectOffensive(action, "too-fast")
		return false
	end

	-- 5) Validation Essence/recharge (autoritaire).
	local allowed, reason = self:_canUseAction(participant, action)
	if not allowed then
		self._qteChallenge = nil
		self:_firePlayerResources()
		self:_rejectOffensive(action, reason or "unusable")
		return false
	end

	-- 6) Curseurs : nombre exact et positions STRICTEMENT valides (pas de clamp).
	local cursors = payload.cursors
	if type(cursors) ~= "table" or #cursors ~= profile.cursorCount then
		self._qteChallenge = nil
		self:_rejectOffensive(action, "cursor-count")
		return false
	end

	local positions: { number? } = {}
	for i = 1, profile.cursorCount do
		local cursor = cursors[i]
		if type(cursor) ~= "table" then
			self._qteChallenge = nil
			self:_rejectOffensive(action, "cursor-shape")
			return false
		end
		if cursor.stopped == true then
			local pos = cursor.position
			-- Rejet strict : NaN (pos ~= pos), ±infini, ou hors de [0, 1].
			if type(pos) ~= "number"
				or pos ~= pos
				or pos == math.huge
				or pos == -math.huge
				or pos < 0
				or pos > 1
			then
				self._qteChallenge = nil
				self:_rejectOffensive(action, "bad-position")
				return false
			end
			positions[i] = pos
		elseif cursor.stopped == false then
			-- Curseur non arrêté (pas de clic) : compté comme hors zone.
			positions[i] = nil
		else
			self._qteChallenge = nil
			self:_rejectOffensive(action, "cursor-stopped")
			return false
		end
	end

	-- 7) Durée physique annoncée par le client (si fournie) : finie, positive et
	-- cohérente avec le temps réellement observé côté serveur.
	local clientDuration = payload.duration
	if clientDuration ~= nil then
		if type(clientDuration) ~= "number"
			or clientDuration ~= clientDuration
			or clientDuration < 0
			or clientDuration > serverElapsed + QteConfig.Challenge.EXTRA_SECONDS
		then
			self._qteChallenge = nil
			self:_rejectOffensive(action, "bad-duration")
			return false
		end
	end

	-- Défi consommé : usage unique (toute nouvelle soumission du même id sera rejetée).
	self._qteChallenge = nil

	-- Verdict recalculé côté serveur à partir des positions (source autoritaire).
	local result = Qte.computeOutcome(profile, positions)
	self._pendingOffensive = {
		action = action,
		outcome = result.outcome,
		multiplier = result.multiplier,
		cancelled = result.cancelled,
	}

	local resolve = self._resolveTurn
	resolve(action)
	return true
end

-- ---------------------------------------------------------------------------
-- Utilitaires
-- ---------------------------------------------------------------------------

function CombatSession:_enemyParticipant(): CombatParticipant?
	for _, p in self.participants do
		if p.side == "Enemy" then
			return p
		end
	end
	return nil
end

-- Réplique l'état courant au client (hook neutre pour l'UI du lot 03).
function CombatSession:_fireState()
	local ok, remote = pcall(function()
		return Remotes.get("CombatStateChanged")
	end)
	if ok and remote and remote:IsA("RemoteEvent") and self.player and self.player.Parent then
		remote:FireClient(self.player, {
			sessionId = self.id,
			state = self.state:get(),
			round = self.round,
		})
	end
end

return CombatSession
