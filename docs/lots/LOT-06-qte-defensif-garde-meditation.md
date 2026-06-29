# Lot 06 — QTE défensif, Garde et Méditer

## Statut

EN ATTENTE DU LOT PRÉCÉDENT (dépend des lots 03 et 04).

## Dépendances

Lot 03 (interface) et lot 04 (actions/Essence/cooldowns).

## Objectif

Implémenter la défense universelle (QTE défensif à un curseur), l'action Garde et
l'action Méditer avec son malus, ainsi que les règles d'arrondi des dégâts.

## Résultat attendu

- Un QTE défensif à un curseur avec zones rouge/jaune/hors zone.
- Une Garde absorbant 70 % sans QTE.
- Une Méditer donnant +2 Essence avec malus défensif.
- Un calcul de dégâts en entiers, arrondi vers le haut, minimum 1 si non annulé.

## Fichiers et dossiers autorisés

- `src/client/qte/` : QTE défensif.
- `src/server/combat/` : application des dégâts, Garde, Méditer, malus.
- `src/shared/` : configuration des pourcentages et profils défensifs, types.
- `docs/lots/README.md` (statut + hash, à la fin).

## Fichiers interdits ou hors périmètre

- Parade/riposte avancée (lot 09), kit Épéiste (lot 07), ennemis (lot 08).

## Règles fonctionnelles détaillées

- **QTE défensif** : un seul curseur traverse la barre.
  - Zone rouge : défense normale, **50 % des dégâts absorbés** ; l'attaque touche
    le corps, donc effets secondaires applicables.
  - Zone jaune : parade parfaite, **aucun dégât ni effet secondaire**.
  - Hors zone : **dégâts complets** et effets secondaires applicables.
- **Garde** : utilise tout le tour, **aucun QTE défensif**, absorbe **70 %**, effets
  secondaires applicables (corps touché), dure jusqu'au prochain tour personnel.
- **Méditer** : utilise tout le tour, donne **+2 Essence**, conserve les QTE
  défensifs, applique un malus jusqu'au prochain tour personnel :
  - zone rouge → **30 %** d'absorption ;
  - Garde → **50 %** d'absorption ;
  - parade parfaite jaune → **inchangée**.
- Dégâts partiels en **nombres entiers**, arrondis **vers le haut** (prototype).
- Une attaque non totalement annulée inflige **au minimum 1 dégât**.

## Contraintes techniques

- Application des dégâts autoritaire côté serveur.
- Tous les pourcentages centralisés en configuration.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Implémenter le QTE défensif à un curseur (rendu + entrée).
2. Implémenter le calcul des dégâts selon la zone touchée (50 % / 0 % / 100 %).
3. Implémenter l'arrondi vers le haut et le minimum de 1 dégât.
4. Implémenter Garde (70 %, sans QTE, durée 1 tour personnel).
5. Implémenter Méditer (+2 Essence) et le malus (zone rouge 30 %, Garde 50 %).
6. Brancher les états sur l'UI (durées, malus).

## Cas limites à gérer

- Dégâts résultant en 0 alors que l'attaque n'est pas annulée : forcer 1.
- Méditer puis défense au tour suivant : appliquer le bon malus une seule fois.
- Empilement Garde + malus : Garde à 50 % sous malus.

## Critères d'acceptation vérifiables

- Zone rouge = 50 %, jaune = 0 dégât, hors zone = 100 %.
- Garde = 70 %, sans QTE ; Méditer = +2 Essence avec malus correct.
- Arrondi vers le haut et minimum 1 dégât respectés.
- Durées « jusqu'au prochain tour personnel » correctes.

## Tests manuels à effectuer

- Provoquer une parade parfaite, une défense rouge et un échec hors zone.
- Tester Garde et vérifier 70 %.
- Tester Méditer puis subir une attaque et vérifier les 30 % / 50 %.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Pas de riposte ni de contre-parade (lot 09).
- Pas de kit ni d'ennemi.
- Ne pas commencer le lot 07.

## Message de commit conseillé

```
feat: add defensive qte guard and meditation
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation de la mise à jour du statut + hash du lot 06 dans `docs/lots/README.md`.
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
