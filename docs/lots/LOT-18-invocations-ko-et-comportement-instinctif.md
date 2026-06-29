# Lot 18 — Invocations K.-O. et comportement instinctif

## Statut

BLOQUÉ JUSQU'À VALIDATION DU PROTOTYPE SOLO (dépend du lot 17).

## Dépendances

Lot 17 (phase commune des invocations).

## Objectif

Implémenter le comportement instinctif des invocations quand leur maître est
neutralisé, ainsi que le K.-O. d'invocation et son relèvement, sans mort permanente.

## Résultat attendu

- Un comportement instinctif limité quand le maître est neutralisé.
- Un K.-O. d'invocation et un relèvement conforme aux règles.

## Fichiers et dossiers autorisés

- `src/server/combat/summons/` : instinct, K.-O., relèvement.
- `src/shared/` : configuration et types.
- `docs/lots/README.md` (à la fin : passer le statut à TERMINÉ + renseigner la date ; colonne Hash commit laissée vide).

## Fichiers interdits ou hors périmètre

- Acquisition de créatures, lien bestial complet, monde, bestiaire.

## Règles fonctionnelles détaillées

- **Comportement instinctif** si le maître est neutralisé : les créatures peuvent
  protéger, esquiver ou utiliser une petite action naturelle, mais **ne peuvent plus**
  utiliser d'action complète commandée.
- **K.-O. d'invocation** : une invocation à 0 PV passe K.-O.
- **Relèvement** par l'Invocateur : action universelle, coût **2 Essence**, utilise
  **tout le tour**, retour à **25 % des PV max**, **une fois maximum par invocation
  et par combat**.
- Si elle retombe K.-O., elle reste **indisponible** jusqu'à un soin adapté ou au
  retour au village.
- **Aucune mort permanente** des invocations.
- Le **lien bestial** n'est noté que comme **extension future** (pas implémenté).

## Contraintes techniques

- Autorité serveur sur l'état des invocations.
- Constantes (25 %, coût relèvement) centralisées.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Détecter la neutralisation du maître et basculer en comportement instinctif.
2. Limiter les actions instinctives (protéger, esquiver, petite action naturelle).
3. Implémenter le K.-O. d'invocation à 0 PV.
4. Implémenter le relèvement (2 Essence, tour entier, 25 %, une fois par combat).
5. Gérer l'indisponibilité après une seconde chute.

## Cas limites à gérer

- Relèvement tenté une deuxième fois sur la même invocation : refusé.
- Maître neutralisé puis rétabli : retour au comportement commandé.
- Invocation K.-O. en comportement instinctif : pas d'action complète.

## Critères d'acceptation vérifiables

- Comportement instinctif limité quand le maître est neutralisé.
- Relèvement : 2 Essence, tour entier, 25 % PV, une fois par combat.
- Seconde chute = indisponible jusqu'à soin/village.
- Aucune mort permanente d'invocation.

## Tests manuels à effectuer

- Neutraliser le maître et observer l'instinct.
- Mettre une invocation K.-O. et la relever.
- Tenter un second relèvement (doit échouer).
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucun lien bestial complet, aucune acquisition de créature.
- Ne pas commencer le lot 19.

## Message de commit conseillé

```
feat: add summon ko revive and instinct behavior
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation que le statut du lot 18 est passé à TERMINÉ et la date renseignée dans `docs/lots/README.md` (colonne Hash commit laissée vide ; pas de second commit pour le hash).
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
