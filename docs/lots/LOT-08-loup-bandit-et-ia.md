# Lot 08 — Loup, Bandit et IA

## Statut

EN ATTENTE DU LOT PRÉCÉDENT (dépend des lots 02, 05 et 06).

## Dépendances

Lot 02 (moteur de tours), lot 05 (QTE offensif), lot 06 (QTE défensif/Garde).

## Objectif

Implémenter les deux créatures de test (Loup gris, Bandit égaré) avec leurs
statistiques, leurs capacités, et une IA de choix d'action. Aucune intention
n'est annoncée avant le tour de l'ennemi.

## Résultat attendu

- Deux configurations d'ennemis séparées et data-driven.
- Une IA choisissant les actions selon les règles, avec cooldowns ennemis.
- Une IA déterministe en mode test (option de seed).

## Fichiers et dossiers autorisés

- `src/shared/enemies/` : configurations Loup et Bandit.
- `src/server/combat/ai/` : logique de choix d'action.
- `docs/lots/README.md` (à la fin : passer le statut à TERMINÉ + renseigner la date ; colonne Hash commit laissée vide).

## Fichiers interdits ou hors périmètre

- Parade/riposte/défense ennemie détaillée (lot 09). Génération de monde (lot 20).

## Règles fonctionnelles détaillées

- **Loup gris niveau 1** : PV 16 ; Clairvoyance 7 ; rapide et agressif ; pas de
  parade armée ; peut esquiver selon son anatomie.
  - Morsure : 3 dégâts, aucun cooldown, QTE défensif normal.
  - Bond : 5 dégâts, cooldown 2 tours personnels, QTE plus rapide que Morsure ;
    l'IA préfère Bond lorsqu'il est disponible.
- **Bandit égaré niveau 1** : PV 22 ; Clairvoyance 5 ; peut défendre, garder, parer
  parfaitement, riposter et contre-parer (la logique de parade/riposte vient du lot 09).
  - Coup d'épée : 4 dégâts, aucun cooldown.
  - Frappe lourde : 7 dégâts, cooldown 3 tours personnels, QTE défensif plus rapide,
    aucun avertissement avant son tour.
  - Garde : même principe que la Garde du joueur (70 % d'absorption).
- Aucune intention affichée avant le tour de l'ennemi ; nom visible **uniquement à
  l'exécution** ; animation provisoire reconnaissable.

## Contraintes techniques

- Configurations séparées et data-driven ; toutes les constantes centralisées.
- IA déterministe quand nécessaire pour les tests (option de seed ou mode test).
- Aucune génération aléatoire du monde.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Créer les configurations Loup et Bandit (stats, capacités, cooldowns).
2. Implémenter le choix d'action de l'IA (préférence Bond pour le Loup).
3. Gérer les cooldowns ennemis en tours personnels.
4. Masquer toute intention avant l'exécution ; révéler le nom à l'exécution.
5. Ajouter des animations provisoires reconnaissables.
6. Ajouter une option de seed / mode test pour le déterminisme.

## Cas limites à gérer

- Bond/Frappe lourde en cooldown : repli sur l'attaque sans cooldown.
- Plusieurs ennemis (préparer la structure même si le prototype est solo).
- Mode test activé : séquence d'actions reproductible.

## Critères d'acceptation vérifiables

- Stats exactes (Loup 16/7, Bandit 22/5).
- Capacités et cooldowns conformes.
- L'IA du Loup préfère Bond quand disponible.
- Aucune intention visible avant le tour ; nom révélé à l'exécution.
- Mode test déterministe disponible.

## Tests manuels à effectuer

- Combattre le Loup et observer la préférence Bond.
- Combattre le Bandit et déclencher Frappe lourde.
- Vérifier l'absence d'annonce avant le tour ennemi.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Pas de logique de parade/riposte (lot 09).
- Pas de monde ni de génération aléatoire.
- Ne pas commencer le lot 09.

## Message de commit conseillé

```
feat: add prototype enemies and combat ai
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation que le statut du lot 08 est passé à TERMINÉ et la date renseignée dans `docs/lots/README.md` (colonne Hash commit laissée vide ; pas de second commit pour le hash).
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
