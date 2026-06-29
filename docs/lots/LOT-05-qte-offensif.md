# Lot 05 — QTE offensif

## Statut

EN ATTENTE DU LOT PRÉCÉDENT (dépend des lots 03 et 04).

## Dépendances

Lot 03 (interface) et lot 04 (actions/Essence/cooldowns).

## Objectif

Implémenter le système de QTE offensif configurable : barre à zones, curseurs
successifs, marqueurs figés, règles de résultat, et conséquences (bonus, échec,
annulation avec consommation des ressources).

## Résultat attendu

- Un QTE offensif réutilisable, paramétrable par compétence.
- Des résultats conformes aux règles validées (parfait / normal / annulé).
- Une consommation du tour et des ressources même en cas d'annulation.
- Un outil développeur pour ralentir/accélérer le QTE.

## Fichiers et dossiers autorisés

- `src/client/qte/` : rendu et entrée du QTE offensif.
- `src/server/combat/` : validation raisonnable du résultat, application des effets.
- `src/shared/` : profils de QTE configurables, types.
- `docs/lots/README.md` (à la fin : passer le statut à TERMINÉ + renseigner la date ; colonne Hash commit laissée vide).

## Fichiers interdits ou hors périmètre

- QTE défensif/Garde/Méditer (lot 06), kit Épéiste (lot 07), ennemis (lot 08).

## Règles fonctionnelles détaillées

- Barre horizontale avec une zone rouge et une zone jaune plus petite.
- Plusieurs curseurs se succèdent de gauche à droite avec un petit espacement ;
  le joueur clique pour arrêter chaque curseur.
- Chaque curseur arrêté reste visible (marqueur figé) jusqu'au résultat final.
- Le nombre de curseurs dépend de la compétence.
- Résultats :
  - tous en jaune : **attaque parfaite**, **+20 % de dégâts** (provisoire) ;
  - aucun hors zone et au plus un rouge : **attaque normale** ;
  - deux rouges ou plus : **attaque annulée** ;
  - un seul curseur complètement hors de la zone rouge : **annulation immédiate**.
- En cas d'annulation : ressources et tour **restent consommés** ; jouer une courte
  animation de déséquilibre/échec.
- Vitesses, espacements et tailles de zones **configurables** (profils par compétence).

## Contraintes techniques

- Entrée côté client, mais validation raisonnable côté serveur (protection basique
  contre des réponses impossibles) ; pas d'anti-cheat gigantesque.
- Tous les paramètres de QTE centralisés dans des profils de configuration.
- Outil développeur pour modifier la vitesse du QTE pendant les tests.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Définir le format d'un profil de QTE offensif (nb curseurs, vitesse, zones, espacement).
2. Implémenter le rendu de la barre et des curseurs côté client.
3. Implémenter l'arrêt par clic et le marquage figé.
4. Implémenter le calcul du résultat selon les règles.
5. Appliquer côté serveur : bonus, normal, ou annulation (ressources/tour consommés).
6. Ajouter l'animation d'échec et l'outil développeur de vitesse.

## Cas limites à gérer

- Joueur qui ne clique pas : curseurs non arrêtés traités comme hors zone.
- Réponse client incohérente (timing impossible) : rejet raisonnable serveur.
- Compétence à un seul curseur : règles toujours cohérentes.

## Critères d'acceptation vérifiables

- Les résultats parfait/normal/annulé respectent exactement les règles.
- Le bonus parfait est de +20 % (provisoire) et provisoire/configurable.
- En annulation, le tour et les ressources sont bien consommés.
- Les paramètres sont configurables par compétence.
- L'outil développeur de vitesse fonctionne.

## Tests manuels à effectuer

- Tester un QTE à 2 et à 3 curseurs.
- Provoquer chaque résultat (parfait, normal, annulation, annulation immédiate).
- Vérifier la consommation des ressources en cas d'annulation.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucun QTE défensif, aucune Garde/Méditer.
- Aucun kit ou ennemi.
- Ne pas commencer le lot 06.

## Message de commit conseillé

```
feat: add configurable offensive qte system
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation que le statut du lot 05 est passé à TERMINÉ et la date renseignée dans `docs/lots/README.md` (colonne Hash commit laissée vide ; pas de second commit pour le hash).
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
