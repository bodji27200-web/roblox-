# Lot 07 — Épéiste niveau 1

## Statut

EN ATTENTE DU LOT PRÉCÉDENT (dépend des lots 04, 05 et 06).

## Dépendances

Lot 04 (Essence/cooldowns), lot 05 (QTE offensif), lot 06 (QTE défensif/Garde/Méditer).

## Objectif

Implémenter entièrement le kit Épéiste niveau 1 avec ses statistiques et ses
quatre compétences, en séparant strictement les données de la logique.

## Résultat attendu

- Un personnage Épéiste niveau 1 jouable avec ses statistiques.
- Les quatre compétences : Taille, Fente, Entaille croisée, Posture du duelliste.
- Des données de compétences centralisées et réutilisables.

## Fichiers et dossiers autorisés

- `src/shared/kits/epeiste/` : données des compétences et statistiques.
- `src/server/combat/` : application des effets spécifiques (branchement).
- `docs/lots/README.md` (statut + hash, à la fin).

## Fichiers interdits ou hors périmètre

- Tout autre domaine. Ennemis (lot 08). Riposte avancée (lot 09).

## Règles fonctionnelles détaillées

- **Statistiques** : PV max 30 ; Clairvoyance 5 ; Essence 0/6 au début.
- **Taille** (attaque de base) : 0 Essence, 3 dégâts, 2 curseurs offensifs, aucun
  cooldown, +1 Essence si l'action n'est pas annulée.
- **Fente** : 2 Essence, 5 dégâts, 3 curseurs offensifs, cooldown 2 tours personnels.
- **Entaille croisée** : 3 Essence, deux frappes de 3 dégâts, cooldown 3 tours
  personnels. Chaque frappe utilise une séquence séparée de 2 curseurs et est
  calculée indépendamment ; l'échec de la 2e ne supprime pas les dégâts de la 1re.
- **Posture du duelliste** : 2 Essence, cooldown 4 tours personnels, dure jusqu'au
  prochain tour personnel, agrandit de **50 %** la zone jaune du prochain QTE
  défensif, aucun dégât.
- Animations provisoires simples.

## Contraintes techniques

- Données (coûts, dégâts, curseurs, cooldowns) **séparées** de la logique.
- Toutes les valeurs centralisées et marquées provisoires.
- Réutiliser les systèmes des lots 05/06 (ne pas les réécrire).
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Définir les statistiques de l'Épéiste niveau 1.
2. Créer les données des quatre compétences (profils QTE inclus).
3. Brancher Taille, Fente sur le QTE offensif (lot 05).
4. Implémenter Entaille croisée avec deux séquences indépendantes.
5. Implémenter Posture du duelliste (effet sur le prochain QTE défensif).
6. Ajouter des animations provisoires simples.

## Cas limites à gérer

- Entaille croisée : première frappe réussie, deuxième annulée → dégâts de la
  première conservés.
- Posture du duelliste utilisée puis aucun QTE défensif avant la fin de l'effet :
  l'effet expire au prochain tour personnel.
- Essence insuffisante pour une compétence : refus (règle du lot 04).

## Critères d'acceptation vérifiables

- Statistiques exactes (PV 30, Clairvoyance 5, Essence 0).
- Coûts, dégâts, curseurs et cooldowns conformes pour les quatre compétences.
- Entaille croisée calcule deux frappes indépendantes.
- Posture du duelliste agrandit de 50 % la zone jaune du prochain QTE défensif.
- Données séparées de la logique.

## Tests manuels à effectuer

- Lancer chaque compétence et vérifier coût/dégâts/cooldown.
- Tester Entaille croisée avec un échec sur la deuxième frappe.
- Tester Posture du duelliste puis une défense.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucun autre domaine, aucune compétence supplémentaire.
- Pas d'ennemi.
- Ne pas commencer le lot 08.

## Message de commit conseillé

```
feat: add level one swordsman kit
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation de la mise à jour du statut + hash du lot 07 dans `docs/lots/README.md`.
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
