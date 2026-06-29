# Lot 10 — Objets, fuite, victoire et défaite

## Statut

EN ATTENTE DU LOT PRÉCÉDENT (dépend des lots 02 et 04).

## Dépendances

Lot 02 (moteur/issues de combat) et lot 04 (Essence/tours).

## Objectif

Implémenter les objets de combat (potions), l'action de fuite avec sa formule,
et les issues du combat (victoire/défaite) avec la simulation des trois fragments
d'âme et un bouton développeur de restauration. Aucun DataStore.

## Résultat attendu

- Deux potions par combat, soin de 7 PV, tour consommé.
- Une fuite répétable avec formule de Clairvoyance et bornes 10–90 %.
- Des issues victoire/défaite propres, avec nettoyage et simulation d'âme.

## Fichiers et dossiers autorisés

- `src/server/combat/` : objets, fuite, issues, simulation d'âme.
- `src/client/ui/` : écran d'issue, bouton développeur (branchement).
- `src/shared/` : configuration (potions, formule de fuite), types.
- `docs/lots/README.md` (statut + hash, à la fin).

## Fichiers interdits ou hors périmètre

- DataStore, vraie suppression de personnage, Banque réelle (lot 21).
- Monde, groupe, invocations.

## Règles fonctionnelles détaillées

- **Objets** : deux potions au début de chaque combat ; une potion soigne **7 PV**
  sans dépasser le maximum et **consomme le tour** ; deux potions maximum par combat ;
  aucun autre objet dans le prototype.
- **Fuite** : consomme le tour ; retentable dès le prochain tour personnel après échec ;
  **impossible contre un boss** ; réussite = combat terminé sans récompense.
  - Chance (provisoire) : base **50 %** ; **±10 points** par point de différence de
    Clairvoyance, comparé au combattant ennemi vivant ayant la meilleure Clairvoyance ;
    résultat borné entre **10 % et 90 %**.
  - Exemples : 5 vs 5 = 50 % ; 5 vs 7 = 30 %.
- **Victoire / Défaite** : gérer les deux issues et le nettoyage du combat.
- **Âme (simulée)** : trois fragments ; une défaite solo (ou totale en groupe plus
  tard) simule la destruction d'un fragment ; écran de destruction **simulée** ;
  **bouton développeur** de restauration ; **aucun DataStore**, aucune vraie suppression.

## Contraintes techniques

- Toutes les valeurs (soin, base/pas/bornes de fuite) centralisées en configuration.
- Le nettoyage du combat doit s'exécuter dans **chaque** issue.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Implémenter les potions (init 2, soin 7, tour consommé, max 2).
2. Implémenter la fuite et sa formule bornée 10–90 %.
3. Implémenter les issues victoire et défaite.
4. Implémenter la simulation des trois fragments et l'écran de destruction simulée.
5. Ajouter le bouton développeur de restauration.
6. Garantir le nettoyage du combat dans toutes les issues.

## Cas limites à gérer

- Potion qui dépasserait le maximum de PV : plafonner.
- Fuite contre un boss : refusée.
- Différence de Clairvoyance extrême : résultat borné à 10 % ou 90 %.
- Défaite solo : simulation de perte d'un fragment, restaurable par le bouton dev.

## Critères d'acceptation vérifiables

- Potions : 2 par combat, soin 7, tour consommé, plafond PV respecté.
- Fuite : formule et bornes correctes ; exemples 5v5=50 %, 5v7=30 %.
- Fuite impossible contre un boss.
- Victoire/défaite nettoient le combat ; aucun DataStore.
- Fragments simulés, restaurables par bouton développeur.

## Tests manuels à effectuer

- Utiliser deux potions et vérifier le soin et la limite.
- Tenter une fuite plusieurs fois et vérifier la probabilité.
- Gagner puis perdre un combat et vérifier le nettoyage + la simulation d'âme.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucun DataStore, aucune vraie suppression, aucune Banque réelle.
- Ne pas commencer le lot 11.

## Message de commit conseillé

```
feat: add combat outcomes items flee and soul simulation
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation de la mise à jour du statut + hash du lot 10 dans `docs/lots/README.md`.
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
