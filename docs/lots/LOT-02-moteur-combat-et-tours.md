# Lot 02 — Moteur de combat et tours

## Statut

EN ATTENTE DU LOT PRÉCÉDENT (dépend du lot 01).

## Dépendances

Lot 01 (fondation, structure Rojo, configuration centralisée, types).

## Objectif

Implémenter le moteur de combat serveur faisant autorité : création d'une session,
machine à états, ordre des tours basé sur la Clairvoyance, timer de 20 secondes
avec Garde automatique, et nettoyage fiable. Aucune UI avancée ni kit complet.

## Résultat attendu

- Une session de combat serveur démarrable depuis un déclencheur (Loup/Bandit).
- Une machine à états couvrant tout le cycle de vie du combat.
- Un ordre d'initiative recalculé à chaque manche selon la Clairvoyance.
- Un tour par combattant vivant, un timer de 20 s, Garde automatique à expiration.
- Un nettoyage complet (instances, connexions) à la fin du combat.

## Fichiers et dossiers autorisés

- `src/server/combat/` : session, machine à états, gestion des tours.
- `src/shared/` : extensions des types et de la configuration du combat.
- `docs/lots/README.md` (statut + hash, à la fin).

## Fichiers interdits ou hors périmètre

- Tout fichier d'UI (lot 03), de kit Épéiste (lot 07), d'ennemis détaillés (lot 08).
- Tout système de groupe, monde ou sauvegarde.

## Règles fonctionnelles détaillées

- États requis : `Idle`, `Starting`, `ChoosingAction`, `ResolvingAction`,
  `Defending`, `RoundEnd`, `Victory`, `Defeat`, `Escaped`, `Cleanup`.
- Au démarrage : verrouiller le déplacement des participants, faire apparaître
  l'ennemi devant le joueur, créer une zone temporaire de combat.
- L'initiative est recalculée au début de **chaque manche** ; la Clairvoyance est
  le facteur principal ; les égalités sont départagées de façon contrôlée par le serveur.
- Chaque combattant vivant agit une fois par manche.
- Le joueur a **20 secondes** pour choisir ; à expiration, **Garde** est appliquée
  automatiquement.
- Le serveur fait autorité : aucune action n'est validée côté client seul.
- Empêcher les doubles actions (un combattant ne joue qu'une fois par manche).

## Contraintes techniques

- Toute la logique d'état vit côté serveur.
- Constantes (durée du tour, etc.) centralisées dans la configuration.
- Nettoyer systématiquement connexions et instances à la sortie de combat.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Définir la structure d'une session de combat (participants, manche, état courant).
2. Implémenter la machine à états avec transitions explicites.
3. Implémenter le verrouillage de déplacement et l'apparition de l'ennemi + zone.
4. Implémenter le calcul d'initiative par manche (Clairvoyance + tie-break serveur).
5. Implémenter le timer de 20 s et la Garde automatique par défaut.
6. Implémenter les états de fin (Victory, Defeat, Escaped) et le Cleanup.
7. Exposer des hooks/remotes neutres pour que les lots suivants se branchent.

## Cas limites à gérer

- Joueur qui se déconnecte en plein combat : nettoyer proprement la session.
- Égalité d'initiative : ordre déterministe et reproductible côté serveur.
- Fin de combat sur n'importe quel état : Cleanup toujours atteint.

## Critères d'acceptation vérifiables

- Une session démarre, traverse les états et se termine sans fuite d'instance.
- L'ordre des tours change correctement selon la Clairvoyance.
- Le timer de 20 s déclenche bien Garde automatique.
- Aucune double action possible dans une même manche.
- Le déplacement est bloqué pendant le combat et restauré au Cleanup.

## Tests manuels à effectuer

- Démarrer un combat de test et observer la succession des états.
- Laisser expirer le timer et vérifier la Garde automatique.
- Terminer le combat et vérifier le nettoyage.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucune UI, aucun QTE, aucun kit ou ennemi détaillé.
- Ne pas commencer le lot 03.
- Ne pas ajouter de mécanique non demandée.

## Message de commit conseillé

```
feat: add server-authoritative combat turn engine
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation de la mise à jour du statut + hash du lot 02 dans `docs/lots/README.md`.
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
