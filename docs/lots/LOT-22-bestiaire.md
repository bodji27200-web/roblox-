# Lot 22 — Bestiaire

## Statut

BLOQUÉ JUSQU'À VALIDATION DU COMBAT ET DE LA CONCEPTION DE LA RÉGION (dépend des lots 08 et 19).

## Dépendances

Lot 08 (créatures de test) et lot 19 (région/village).

## Objectif

Implémenter un bestiaire qui enregistre les créatures rencontrées et complète leurs
informations **progressivement**, sans jamais tout révéler dès le premier regard.

## Résultat attendu

- Un bestiaire enregistrant les créatures rencontrées.
- Des informations qui se débloquent progressivement selon les actions du joueur.
- Une interface temporaire et des données configurables.

## Fichiers et dossiers autorisés

- `src/server/bestiary/` : enregistrement et progression des connaissances.
- `src/client/ui/bestiary/` : interface temporaire.
- `src/shared/bestiary/` : données configurables des créatures.
- `docs/lots/README.md` (statut + hash, à la fin).

## Fichiers interdits ou hors périmètre

- Acquisition d'invocations, lien bestial, autres régions.

## Règles fonctionnelles détaillées

- Enregistrement d'une créature **après l'avoir rencontrée**.
- Informations qui se complètent **progressivement** via : observation, affrontement,
  victoire, étude.
- Champs : habitat, résistances, objets associés, etc.
- **Lien futur** avec l'Invocateur (noté, non implémenté ici).
- Interface **temporaire**.
- **Aucune** encyclopédie remplie automatiquement dès le premier regard.

## Contraintes techniques

- Données des créatures **configurables** (data-driven).
- Constantes centralisées.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Définir le format de données d'une fiche de créature et ses paliers de connaissance.
2. Enregistrer une créature à la première rencontre (infos minimales).
3. Compléter les informations selon observation/affrontement/victoire/étude.
4. Construire l'interface temporaire du bestiaire.
5. Préparer (sans implémenter) le lien futur avec l'Invocateur.

## Cas limites à gérer

- Créature rencontrée mais jamais vaincue : informations partielles.
- Recompléter une fiche déjà partiellement remplie sans régression.
- Première rencontre : pas de révélation complète.

## Critères d'acceptation vérifiables

- Une créature s'enregistre à la première rencontre.
- Les informations se débloquent progressivement selon les actions.
- Aucune fiche complète dès le premier regard.
- Données configurables et interface temporaire présentes.

## Tests manuels à effectuer

- Rencontrer une créature et vérifier l'enregistrement minimal.
- Combattre puis vaincre et vérifier le déblocage progressif.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucune acquisition d'invocation, aucun lien bestial, aucune autre région.
- Ne pas commencer un autre lot.

## Message de commit conseillé

```
feat: add progressive creature bestiary
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation de la mise à jour du statut + hash du lot 22 dans `docs/lots/README.md`.
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
