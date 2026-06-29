--!strict
-- Initiative
-- Lot 02 — Calcul de l'ordre des tours d'une manche.
-- La Clairvoyance est le facteur principal (ordre décroissant).
-- Les égalités sont départagées de façon déterministe et reproductible par le
-- serveur : à Clairvoyance égale, on trie par identifiant croissant (stable).
-- Aucune dépendance à l'aléatoire : un même ensemble produit toujours le même ordre.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))

type CombatParticipant = Types.CombatParticipant

local Initiative = {}

-- Un combattant est vivant s'il a des PV ; un joueur doit aussi être encore présent.
local function isAlive(p: CombatParticipant): boolean
	if p.hp <= 0 then
		return false
	end
	if p.side == "Player" and p.player ~= nil and p.player.Parent == nil then
		return false
	end
	return true
end
Initiative.isAlive = isAlive

-- Retourne la liste ordonnée des combattants **vivants** qui agiront cette manche.
function Initiative.order(participants: { CombatParticipant }): { CombatParticipant }
	local living: { CombatParticipant } = {}
	for _, p in participants do
		if isAlive(p) then
			table.insert(living, p)
		end
	end

	table.sort(living, function(a, b)
		if a.clairvoyance ~= b.clairvoyance then
			-- Clairvoyance la plus haute agit en premier.
			return a.clairvoyance > b.clairvoyance
		end
		-- Tie-break serveur déterministe : identifiant croissant.
		return a.id < b.id
	end)

	return living
end

return Initiative
