# Lot 19 — Région forêt et village

## Statut

BLOQUÉ JUSQU'À VALIDATION DU COMBAT ET DE LA CONCEPTION DE LA RÉGION (dépend du lot 11).

## Dépendances

Lot 11 (combat validé). Nécessite aussi une conception de région validée avant lancement.

## Objectif

Construire la première région (forêt de taille moyenne) et son village sécurisé
central avec les bâtiments principaux et les quatre sorties cardinales marquées
« Bientôt disponible ».

## Résultat attendu

- Une forêt dense plutôt qu'immense, à la géographie principale faite à la main.
- Un village sécurisé central avec ses bâtiments et quatre sorties cardinales.

## Fichiers et dossiers autorisés

- `src/server/world/` ou équivalent : mise en place de la région et du village.
- Assets de niveau dans l'emplacement prévu par la structure du projet.
- `src/shared/` : configuration des emplacements/sorties.
- `docs/lots/README.md` (à la fin : passer le statut à TERMINÉ + renseigner la date ; colonne Hash commit laissée vide).

## Fichiers interdits ou hors périmètre

- Rencontres aléatoires (lot 20), âme/banque persistante (lot 21), bestiaire (lot 22).
- Contenu détaillé des quatre autres régions.

## Règles fonctionnelles détaillées

- Forêt de **taille moyenne**, dense plutôt qu'immense.
- **Village sécurisé** au centre.
- Bâtiments : **guilde, forgeron, marchand, alchimiste, maître/bâtiment d'armes**.
- **Quatre sorties cardinales** (haut, bas, gauche, droite).
- Chaque sortie non disponible affiche un panneau **« Bientôt disponible »**.
- Géographie principale **faite à la main**.

## Contraintes techniques

- Emplacements et sorties configurables/centralisés.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Délimiter la zone de la forêt (taille moyenne, dense).
2. Construire le village sécurisé central.
3. Placer les cinq types de bâtiments listés.
4. Créer les quatre sorties cardinales.
5. Ajouter les panneaux « Bientôt disponible » sur les sorties non disponibles.

## Cas limites à gérer

- Limites du village (zone sécurisée) clairement définies.
- Sorties : transition future préparée mais bloquée pour l'instant.

## Critères d'acceptation vérifiables

- La forêt existe, de taille moyenne et dense.
- Le village central contient les cinq bâtiments.
- Les quatre sorties existent et affichent « Bientôt disponible ».

## Tests manuels à effectuer

- Parcourir le village et repérer chaque bâtiment.
- Vérifier les panneaux des quatre sorties.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucune rencontre aléatoire, aucun bestiaire, aucune autre région.
- Ne pas commencer le lot 20.

## Message de commit conseillé

```
feat: create first forest region and village hub
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation que le statut du lot 19 est passé à TERMINÉ et la date renseignée dans `docs/lots/README.md` (colonne Hash commit laissée vide ; pas de second commit pour le hash).
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
