# Lot 13 — Système de groupe

## Statut

BLOQUÉ JUSQU'À VALIDATION DU PROTOTYPE SOLO (dépend du lot 11).

## Dépendances

Lot 11 (prototype solo validé).

## Objectif

Créer la fondation du système de groupe (jusqu'à quatre joueurs) : création,
invitation, acceptation, refus, départ, chef de groupe, et un onglet temporaire.
Aucune invitation automatique au combat dans ce lot, aucun PvP.

## Résultat attendu

- Des groupes de 1 à 4 joueurs gérés côté serveur.
- Les opérations de base (créer, inviter, accepter, refuser, quitter).
- Un onglet temporaire d'affichage du groupe à gauche.

## Fichiers et dossiers autorisés

- `src/server/party/` : logique de groupe et validations.
- `src/client/ui/party/` : onglet temporaire.
- `src/shared/` : configuration et types de groupe.
- `docs/lots/README.md` (statut + hash, à la fin).

## Fichiers interdits ou hors périmètre

- Invitations au combat / rassemblement (lot 14), génération en groupe (lot 15),
  combat multijoueur (lot 16), PvP.

## Règles fonctionnelles détaillées

- Groupe de **quatre joueurs maximum**.
- Le jeu reste prioritairement viable en solo et en duo.
- Opérations : créer un groupe, inviter, accepter, refuser, quitter.
- Gérer le **chef de groupe** et sa **déconnexion** (transfert ou dissolution).
- **Aucune** invitation automatique au combat ici.
- Onglet temporaire à gauche de l'écran (UI provisoire).
- Validations serveur sur toutes les opérations.

## Contraintes techniques

- Autorité serveur sur la composition du groupe.
- Constantes (taille max, etc.) centralisées.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Définir la structure de données d'un groupe (membres, chef).
2. Implémenter créer / inviter / accepter / refuser / quitter.
3. Gérer le chef et sa déconnexion.
4. Construire l'onglet temporaire à gauche.
5. Valider toutes les opérations côté serveur.

## Cas limites à gérer

- Inviter un 5e joueur : refusé (max 4).
- Déconnexion du chef : transfert ou dissolution propre.
- Joueur invité déjà dans un groupe : gérer le conflit.

## Critères d'acceptation vérifiables

- Un groupe ne dépasse jamais 4 membres.
- Les cinq opérations fonctionnent et sont validées serveur.
- La déconnexion du chef est gérée proprement.
- L'onglet affiche le groupe.

## Tests manuels à effectuer

- Créer un groupe et inviter jusqu'à 4 joueurs.
- Tester refus, départ et déconnexion du chef.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucune invitation automatique au combat, aucun PvP.
- Ne pas commencer le lot 14.

## Message de commit conseillé

```
feat: add four player party foundation
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation de la mise à jour du statut + hash du lot 13 dans `docs/lots/README.md`.
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
