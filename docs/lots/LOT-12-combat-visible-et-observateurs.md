# Lot 12 — Combat visible et observateurs

## Statut

BLOQUÉ JUSQU'À VALIDATION DU PROTOTYPE SOLO (dépend du lot 11).

## Dépendances

Lot 11 (prototype solo intégré et validé).

## Objectif

Rendre le combat visible aux joueurs proches et permettre l'observation, tout en
empêchant strictement toute intervention extérieure. Aucun système de groupe ici.

## Résultat attendu

- Le combat reste à l'endroit du déclenchement, visible par les joueurs proches.
- Une zone temporaire locale sépare participants et observateurs.
- Les observateurs ne peuvent jamais intervenir ; aucun inconnu ne peut rejoindre.

## Fichiers et dossiers autorisés

- `src/server/combat/` : visibilité, séparation participants/observateurs, réseau.
- `src/client/` : rendu observateur (lecture seule).
- `src/shared/` : configuration de la zone et de la visibilité.
- `docs/lots/README.md` (statut + hash, à la fin).

## Fichiers interdits ou hors périmètre

- Système de groupe (lot 13), invitations (lot 14), génération en groupe (lot 15).

## Règles fonctionnelles détaillées

- Le combat se déroule là où la rencontre se déclenche, sans téléportation.
- Une zone de combat temporaire est créée localement.
- Les autres joueurs proches peuvent observer.
- Les joueurs extérieurs au combat ne peuvent pas intervenir ; aucun inconnu ne
  peut rejoindre.
- Séparation claire entre participants (interactifs) et observateurs (lecture seule).
- Nettoyage réseau à la fin du combat.

## Contraintes techniques

- Autorité serveur sur qui est participant vs observateur.
- Constantes de zone/visibilité centralisées.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Exposer l'état du combat aux clients proches en lecture seule.
2. Créer la zone temporaire locale et la séparation participants/observateurs.
3. Bloquer toute action des observateurs.
4. Empêcher tout joueur non invité de rejoindre.
5. Nettoyer les réplications réseau à la fin.

## Cas limites à gérer

- Observateur qui s'approche/s'éloigne pendant le combat.
- Observateur tentant d'envoyer une action : rejet serveur.
- Fin de combat : les observateurs perdent l'accès proprement.

## Critères d'acceptation vérifiables

- Un joueur proche voit le combat sans pouvoir agir.
- Aucun inconnu ne peut rejoindre.
- La zone temporaire est créée puis nettoyée.

## Tests manuels à effectuer

- Lancer un combat et observer depuis un second client.
- Tenter une action en tant qu'observateur (doit échouer).
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucun système de groupe ni d'invitation.
- Ne pas commencer le lot 13.

## Message de commit conseillé

```
feat: support visible world combat and spectators
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation de la mise à jour du statut + hash du lot 12 dans `docs/lots/README.md`.
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
