# Lot 16 — Combat multijoueur et Secourir

## Statut

BLOQUÉ JUSQU'À VALIDATION DU PROTOTYPE SOLO (dépend des lots 12, 14 et 15).

## Dépendances

Lot 12 (combat visible), lot 14 (rassemblement), lot 15 (génération en groupe).

## Objectif

Faire fonctionner le combat à plusieurs : synchronisation des tours, contrôle
limité à son propre personnage, K.-O. et action Secourir, défaite totale du groupe.
Aucun PvP.

## Résultat attendu

- Des tours synchronisés entre plusieurs joueurs et ennemis.
- L'action Secourir conforme aux règles validées.
- Une gestion correcte du K.-O., de la seconde chute et de la défaite totale.

## Fichiers et dossiers autorisés

- `src/server/combat/` : synchronisation multijoueur, Secourir, défaite de groupe.
- `src/client/ui/` : timer individuel, action Secourir.
- `src/shared/` : configuration et types.
- `docs/lots/README.md` (à la fin : passer le statut à TERMINÉ + renseigner la date ; colonne Hash commit laissée vide).

## Fichiers interdits ou hors périmètre

- Invocations (lots 17/18), monde (lots 19/20), âme persistante réelle (lot 21), PvP.

## Règles fonctionnelles détaillées

- Synchronisation des tours ; chaque joueur **ne contrôle que son personnage**.
- **Timer individuel** ; **Garde automatique** à expiration (réutiliser lot 02/04).
- Gérer la **déconnexion temporaire** d'un joueur en combat.
- **K.-O.** : un joueur à 0 PV passe K.-O.
- **Secourir** : coûte **2 Essence**, consomme **tout le tour**, ramène le joueur à
  **15 % des PV max** ; il attend son prochain tour normal ; **une fois par combat**
  ; une seconde chute le met **définitivement hors combat** pour ce combat.
- **Défaite totale du groupe** si tous les joueurs sont hors combat.
- Aucun PvP.

## Contraintes techniques

- Autorité serveur sur les tours et le contrôle des personnages.
- Constantes (15 %, coût Secourir) centralisées.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Étendre le moteur de tours au multijoueur (ordre par Clairvoyance commun).
2. Restreindre le contrôle de chaque joueur à son personnage.
3. Implémenter le timer individuel et la Garde automatique.
4. Gérer la déconnexion temporaire.
5. Implémenter K.-O. et Secourir avec ses limites.
6. Implémenter la défaite totale du groupe.

## Cas limites à gérer

- Joueur déconnecté pendant son tour : Garde automatique / saut propre.
- Tentative de Secourir une seconde fois le même joueur : refusée.
- Tous les joueurs K.-O. simultanément : défaite totale.

## Critères d'acceptation vérifiables

- Les tours multijoueur sont synchronisés et contrôlés serveur.
- Secourir : 2 Essence, tout le tour, retour à 15 %, une fois par combat.
- Seconde chute = hors combat définitif pour ce combat.
- Défaite totale déclenchée correctement.

## Tests manuels à effectuer

- Combat à deux joueurs : faire tomber l'un et le secourir.
- Provoquer une seconde chute et vérifier l'exclusion.
- Provoquer une défaite totale.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucune invocation, aucun monde, aucun PvP, aucune âme persistante réelle.
- Ne pas commencer le lot 17.

## Message de commit conseillé

```
feat: add multiplayer turns and player revive
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation que le statut du lot 16 est passé à TERMINÉ et la date renseignée dans `docs/lots/README.md` (colonne Hash commit laissée vide ; pas de second commit pour le hash).
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
