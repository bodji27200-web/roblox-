# Lot 11 — Intégration et tests du prototype

## Statut

EN ATTENTE DU LOT PRÉCÉDENT (dépend des lots 01 à 10).

## Dépendances

Lots 01 à 10 (tout le prototype solo).

## Objectif

Intégrer et stabiliser l'ensemble du prototype solo. **Aucune grosse mécanique
nouvelle.** Chercher les erreurs, nettoyer, tester, ajouter un mode debug et une
documentation de test honnête.

## Résultat attendu

- Un prototype solo cohérent et stable de bout en bout.
- Un mode debug activable et une journalisation lisible.
- Un document `docs/prototype-combat-test.md` listant les tests et les limites.

## Fichiers et dossiers autorisés

- `src/` : corrections d'intégration, nettoyage, mode debug (pas de nouvelle mécanique).
- `docs/prototype-combat-test.md` (nouveau).
- `docs/lots/README.md` (à la fin : passer le statut à TERMINÉ + renseigner la date ; colonne Hash commit laissée vide).

## Fichiers interdits ou hors périmètre

- Toute nouvelle mécanique. Forêt, monde, multijoueur, groupe.

## Règles fonctionnelles détaillées

- Intégrer les lots 01 à 10 et corriger les incohérences.
- Rechercher les erreurs Luau et vérifier les chemins Rojo.
- Nettoyer les connexions et instances (pas de fuite).
- Tester : victoire, fuite, défaite ; tous les boutons ; cooldowns ; Essence ; les
  QTE ; les trois fragments simulés.
- Ajouter un **mode debug** activable et une journalisation lisible.
- Rédiger `docs/prototype-combat-test.md` avec une **liste honnête** de ce qui n'est
  pas testable sans Roblox Studio.

## Contraintes techniques

- Ne pas introduire de mécanique non prévue par les lots 01 à 10.
- Centraliser les éventuels nouveaux flags de debug en configuration.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Vérifier la cohérence des chemins Rojo et l'absence d'erreurs Luau.
2. Brancher correctement tous les systèmes entre eux.
3. Nettoyer les connexions/instances aux fins de combat.
4. Ajouter le mode debug et la journalisation.
5. Dérouler la batterie de tests manuels.
6. Rédiger `docs/prototype-combat-test.md`.

## Cas limites à gérer

- Enchaînement de combats successifs sans fuite mémoire.
- Déconnexion en plein combat : nettoyage correct.
- États d'issue rares (fuite ratée puis défaite, etc.).

## Critères d'acceptation vérifiables

- Le prototype se joue de bout en bout sans erreur bloquante.
- Tous les boutons, cooldowns, Essence et QTE fonctionnent ensemble.
- Les trois issues (victoire, fuite, défaite) sont correctes.
- Mode debug et journalisation présents.
- `docs/prototype-combat-test.md` existe et liste les limites de test.

## Tests manuels à effectuer

- Scénario complet contre le Loup puis contre le Bandit.
- Test de chaque bouton du menu.
- Test des cooldowns, de l'Essence et des QTE offensif/défensif.
- Test des trois fragments simulés et du bouton de restauration.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucune nouvelle mécanique, aucune forêt, aucun multijoueur.
- Ne pas commencer le lot 12.

## Message de commit conseillé

```
test: integrate and document solo combat prototype
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation que le statut du lot 11 est passé à TERMINÉ et la date renseignée dans `docs/lots/README.md` (colonne Hash commit laissée vide ; pas de second commit pour le hash).
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio, en
  reprenant la liste de `docs/prototype-combat-test.md`.

> ⚠️ Après ce lot, le prototype solo doit être validé manuellement avant de
> débloquer les lots 12 à 18.
