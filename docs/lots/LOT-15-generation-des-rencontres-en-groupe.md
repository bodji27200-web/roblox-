# Lot 15 — Génération des rencontres en groupe

## Statut

BLOQUÉ JUSQU'À VALIDATION DU PROTOTYPE SOLO (dépend des lots 13 et 14).

## Dépendances

Lot 13 (groupe) et lot 14 (invitations/rassemblement).

## Objectif

Générer la rencontre **avant** le combat selon le nombre de membres proches et
éligibles, à l'aide de tables solo/duo/trio/quatre, sans rééquilibrage ultérieur.

## Résultat attendu

- Une génération de rencontre data-driven selon la taille effective du groupe.
- Une rencontre figée après création (aucun rééquilibrage).

## Fichiers et dossiers autorisés

- `src/server/combat/encounter/` : génération préalable.
- `src/shared/encounters/` : tables solo/duo/trio/quatre (temporaires de test).
- `src/shared/` : types et configuration.
- `docs/lots/README.md` (à la fin : passer le statut à TERMINÉ + renseigner la date ; colonne Hash commit laissée vide).

## Fichiers interdits ou hors périmètre

- Combat multijoueur/Secourir (lot 16). Forêt/biomes (lots 19/20).

## Règles fonctionnelles détaillées

- Compter **uniquement** les membres proches et éligibles (jamais les éloignés).
- Utiliser des tables distinctes : **solo, duo, trio, quatre joueurs**.
- La table définit le nombre d'ennemis, leurs types, leurs niveaux et les
  probabilités de rareté.
- La rencontre est générée **avant** le combat.
- **Aucune** modification après création : un refus ou une non-réponse ne réduit pas
  la rencontre.

## Contraintes techniques

- Génération data-driven ; tables **temporaires de test** uniquement (pas de biome complet).
- Constantes centralisées.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Définir le format des tables (ennemis, niveaux, types, rareté).
2. Créer des tables de test pour solo/duo/trio/quatre.
3. Déterminer la taille effective (proches + éligibles) au moment de la génération.
4. Générer la rencontre avant le combat et la figer.
5. Garantir l'absence de rééquilibrage après un refus.

## Cas limites à gérer

- Un membre invité refuse après génération : difficulté inchangée.
- Membres éloignés : jamais comptés.
- Taille 1 (solo) malgré un groupe : utiliser la table solo.

## Critères d'acceptation vérifiables

- La table choisie correspond au nombre de membres proches/éligibles.
- La rencontre est générée avant le combat et ne change plus ensuite.
- Les membres éloignés ne sont jamais comptés.

## Tests manuels à effectuer

- Générer des rencontres pour 1, 2, 3 et 4 joueurs.
- Refuser après génération et vérifier l'absence de rééquilibrage.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucun combat multijoueur complet, aucun biome.
- Ne pas commencer le lot 16.

## Message de commit conseillé

```
feat: add party based encounter generation
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation que le statut du lot 15 est passé à TERMINÉ et la date renseignée dans `docs/lots/README.md` (colonne Hash commit laissée vide ; pas de second commit pour le hash).
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
