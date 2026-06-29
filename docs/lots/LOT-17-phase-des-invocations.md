# Lot 17 — Phase commune des invocations

## Statut

BLOQUÉ JUSQU'À VALIDATION DU PROTOTYPE SOLO (dépend des lots 02 et 16).
Reste bloqué tant qu'aucune invocation de test n'est validée.

## Dépendances

Lot 02 (moteur de tours) et lot 16 (combat multijoueur).

## Objectif

Préparer l'architecture de la phase commune des invocations : après le tour de
l'Invocateur, ses créatures agissent dans une phase partagée, sans entrée
individuelle dans l'initiative. Architecture extensible, sans acquisition de
créature ni lien bestial.

## Résultat attendu

- Une phase d'invocation commune déclenchée après le tour du maître.
- Une action complète pour l'invocation principale, des actions secondaires pour
  les autres.
- Une architecture extensible et des coûts/puissance globale préparés.

## Fichiers et dossiers autorisés

- `src/server/combat/summons/` : phase commune, ordonnancement.
- `src/shared/` : types et configuration des invocations.
- `docs/lots/README.md` (statut + hash, à la fin).

## Fichiers interdits ou hors périmètre

- K.-O./instinct des invocations (lot 18), acquisition de créatures, lien bestial,
  monde, bestiaire.

## Règles fonctionnelles détaillées

- Les invocations n'ont **pas** chacune un tour complet indépendant et **ne sont pas**
  ajoutées séparément à l'ordre de Clairvoyance.
- Après le tour de l'Invocateur, **toutes** ses créatures passent dans une phase
  d'invocation **commune**.
- Une invocation **principale** réalise une **action complète**.
- Les autres réalisent seulement une **action secondaire limitée** : protéger,
  soutenir, préparer, se repositionner ou utiliser un petit effet.
- Préparer des coûts partagés ou une puissance globale.
- Aucune acquisition de créature, aucun lien bestial maintenant (réservé plus tard).

## Contraintes techniques

- Architecture **extensible** (futurs domaines/créatures).
- Constantes centralisées.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Définir la structure d'une invocation et de la phase commune.
2. Brancher la phase juste après le tour du maître.
3. Implémenter l'action complète de l'invocation principale.
4. Implémenter les actions secondaires limitées des autres.
5. Préparer le mécanisme de coûts/puissance globale.

## Cas limites à gérer

- Maître sans invocation : phase vide ignorée.
- Plusieurs invocations : une seule principale, les autres en secondaire.
- Initiative : les invocations ne s'y insèrent jamais individuellement.

## Critères d'acceptation vérifiables

- La phase commune se déclenche après le maître.
- Une seule invocation principale a une action complète.
- Les autres n'ont que des actions secondaires limitées.
- Aucune invocation n'apparaît séparément dans l'ordre de Clairvoyance.

## Tests manuels à effectuer

- Simuler un Invocateur avec une et deux invocations de test.
- Vérifier l'ordre maître → phase commune.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucun K.-O. d'invocation, aucun instinct (lot 18), aucun lien bestial.
- Ne pas commencer le lot 18.

## Message de commit conseillé

```
feat: add shared summon phase framework
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation de la mise à jour du statut + hash du lot 17 dans `docs/lots/README.md`.
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
