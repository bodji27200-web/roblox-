# Lot 01 — Fondation du prototype de combat

## Statut

TODO (PRÊT À EXÉCUTER).

## Dépendances

Aucune. C'est le premier lot.

## Objectif

Mettre en place une structure de projet Roblox/Rojo minimale et propre, capable
d'accueillir tout le prototype de combat solo des lots suivants. Aucune logique
de combat n'est implémentée ici : on prépare seulement le terrain (arborescence,
configuration centralisée, types, zone de test, déclencheurs visibles).

## Résultat attendu

- Un projet synchronisable avec Rojo (`default.project.json` valide).
- Une arborescence claire séparant Shared, serveur, client, configuration et remotes.
- Des modules de configuration centralisée vides ou pré-remplis avec des valeurs
  de placeholder issues de `design-decisions.md`.
- Une petite zone de test générée par script, sans assets externes.
- Deux déclencheurs visibles dans la zone de test : « Loup » et « Bandit ».
- Une documentation minimale de lancement (`docs/prototype-combat-setup.md`).

## Fichiers et dossiers autorisés

- `default.project.json` (créer ou adapter).
- `src/shared/` : types, configuration, utilitaires partagés.
- `src/server/` : point d'entrée serveur, génération de la zone de test.
- `src/client/` : point d'entrée client minimal.
- `src/shared/remotes/` ou équivalent : déclaration des RemoteEvents/Functions (vides).
- `docs/prototype-combat-setup.md` (documentation de lancement).
- `docs/lots/README.md` (mise à jour du statut + hash uniquement, à la fin).

## Fichiers interdits ou hors périmètre

- Tout fichier hors de `src/`, `default.project.json` et `docs/`.
- Toute logique de combat, d'UI complète, de monde, de groupe ou de sauvegarde.
- Tout DataStore.

## Règles fonctionnelles détaillées

- L'arborescence est **recommandée**, pas imposée par écrasement : si une
  structure existe déjà, l'adapter au lieu de tout remplacer.
- La configuration centralisée doit regrouper les futures constantes (Essence max,
  durée du tour, etc.) dans des ModuleScripts dédiés.
- Les deux déclencheurs (Loup, Bandit) sont de simples parties cliquables ou des
  zones, sans logique de combat : ils peuvent pour l'instant n'imprimer qu'un log.
- La zone de test est générée par code (parties basiques), sans modèle importé.

## Contraintes techniques

- Luau en mode strict (`--!strict`) lorsque c'est raisonnable.
- Pas de logique monolithique : découper en ModuleScripts.
- Aucune dépendance privée ou payante.
- Centraliser toutes les valeurs configurables dans des modules de configuration.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Vérifier l'existant à la racine et dans `src/` ; ne pas écraser ce qui est utile.
2. Créer/adapter `default.project.json` pour mapper Shared/Server/Client.
3. Créer les dossiers `src/shared`, `src/server`, `src/client` et un sous-dossier
   pour les remotes.
4. Créer un ModuleScript de configuration centralisée (placeholders).
5. Créer un ModuleScript de types de données du combat (structures de base).
6. Écrire le script serveur générant la zone de test et les deux déclencheurs.
7. Écrire le script client minimal (vide ou simple log).
8. Rédiger `docs/prototype-combat-setup.md`.

## Cas limites à gérer

- Projet déjà partiellement initialisé : fusionner sans casser.
- Chemins Rojo invalides : vérifier que la synchronisation ne produit pas d'erreur.

## Critères d'acceptation vérifiables

- `default.project.json` est valide et synchronisable par Rojo.
- Les dossiers Shared/Server/Client existent et sont mappés.
- Au moins un module de configuration et un module de types existent.
- La zone de test contient deux déclencheurs nommés « Loup » et « Bandit ».
- Aucune dépendance privée, aucun DataStore, aucune logique monolithique.
- `docs/prototype-combat-setup.md` explique comment lancer le projet.

## Tests manuels à effectuer

- Vérifier mentalement/visuellement la cohérence des chemins Rojo.
- Confirmer que les déclencheurs sont présents et nommés correctement.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucune mécanique de combat, QTE, Essence, UI complète, monde, groupe, sauvegarde.
- Ne pas commencer le lot 02.
- Ne pas ajouter de mécanique non demandée.

## Message de commit conseillé

```
chore: create combat prototype foundation
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation que le statut du lot 01 a été passé à TERMINÉ dans
  `docs/lots/README.md` et que le hash y est renseigné.
- Le hash du commit poussé sur `main`.
- Ne pas prétendre avoir testé dans Roblox Studio sans y avoir réellement accès :
  indiquer explicitement ce qui n'a pas pu être vérifié.
