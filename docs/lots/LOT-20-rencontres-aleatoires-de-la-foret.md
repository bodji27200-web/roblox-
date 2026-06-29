# Lot 20 — Rencontres aléatoires de la forêt

## Statut

BLOQUÉ JUSQU'À VALIDATION DU COMBAT ET DE LA CONCEPTION DE LA RÉGION (dépend des lots 15 et 19).

## Dépendances

Lot 15 (génération en groupe / tables) et lot 19 (forêt et village).

## Objectif

Implémenter le déclenchement des rencontres aléatoires hors du village, avec la
cadence validée et le branchement vers les tables solo/duo/trio/quatre.

## Résultat attendu

- Des rencontres se déclenchant uniquement hors du village.
- Une cadence variable de 45 à 90 s avec période de sécurité après combat.
- Un branchement vers les tables de génération existantes.

## Fichiers et dossiers autorisés

- `src/server/world/encounters/` : déclenchement et cadence.
- `src/shared/encounters/` : réglages de cadence et probabilités.
- `docs/lots/README.md` (à la fin : passer le statut à TERMINÉ + renseigner la date ; colonne Hash commit laissée vide).

## Fichiers interdits ou hors périmètre

- Définition des tables elles-mêmes (lot 15), bestiaire (lot 22), âme/banque (lot 21).

## Règles fonctionnelles détaillées

- Rencontres **hors du village uniquement**.
- Les ennemis sont **invisibles dans le monde** avant le déclenchement.
- Cadence **moyenne variable de 45 à 90 secondes** ; **période de sécurité** après
  chaque combat.
- Première région : **surtout niveau 1**, niveau 2 **rare**.
- **Aucun mini-boss aléatoire** dans la première région.
- Boss **uniquement** dans une zone précise ou par invocation volontaire (jamais aléatoire).
- Brancher vers les **tables solo/duo/trio/quatre** (lot 15).

## Contraintes techniques

- Cadence et probabilités centralisées en configuration.
- Réutiliser les tables du lot 15 (ne pas les redéfinir).
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Détecter la sortie de la zone sécurisée du village.
2. Implémenter le minuteur de rencontre (45–90 s) et la période de sécurité.
3. Brancher la génération vers les tables solo/duo/trio/quatre.
4. Garantir l'absence de mini-boss aléatoire en première région.
5. S'assurer que les boss ne sont jamais des rencontres aléatoires.

## Cas limites à gérer

- Joueur qui rentre/sort du village : pas de rencontre en zone sécurisée.
- Combat enchaîné : période de sécurité respectée.
- Groupe : compter la taille effective via le lot 15.

## Critères d'acceptation vérifiables

- Aucune rencontre dans le village.
- Cadence 45–90 s avec période de sécurité.
- Niveaux conformes (surtout 1, niveau 2 rare, pas de mini-boss aléatoire).
- Branchement correct vers les tables de génération.

## Tests manuels à effectuer

- Sortir du village et mesurer la cadence des rencontres.
- Vérifier l'absence de rencontre en zone sécurisée.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucune nouvelle table (lot 15), aucun bestiaire, aucune âme/banque réelle.
- Ne pas commencer le lot 21.

## Message de commit conseillé

```
feat: add forest random encounter system
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation que le statut du lot 20 est passé à TERMINÉ et la date renseignée dans `docs/lots/README.md` (colonne Hash commit laissée vide ; pas de second commit pour le hash).
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
