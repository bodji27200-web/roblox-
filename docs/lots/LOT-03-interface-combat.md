# Lot 03 — Interface de combat

## Statut

EN ATTENTE DU LOT PRÉCÉDENT (dépend du lot 02).

## Dépendances

Lot 02 (moteur de combat et tours).

## Objectif

Créer une interface de combat **fonctionnelle** (non définitive visuellement),
placée comme l'interface future : HUD permanent en bas à gauche, menu d'actions à
droite, ordre des tours en haut, zone centrale pour messages et QTE. Interface
entièrement en français.

## Résultat attendu

- Un HUD permanent et un menu d'actions reliés à l'état du combat (lot 02).
- Des boutons activés/désactivés selon le contexte.
- Une UI lisible sur différentes résolutions, utilisable au clavier/souris avec
  des bases pour la manette.

## Fichiers et dossiers autorisés

- `src/client/ui/` : composants HUD, menu, ordre des tours, zone centrale.
- `src/shared/` : extensions de configuration UI si nécessaire.
- `docs/lots/README.md` (à la fin : passer le statut à TERMINÉ + renseigner la date ; colonne Hash commit laissée vide).

## Fichiers interdits ou hors périmètre

- Logique serveur de combat (lot 02), logique de QTE (lots 05/06), kits, ennemis.
- Toute illustration définitive.

## Règles fonctionnelles détaillées

- **HUD bas gauche permanent** : nom du personnage ; maîtrise niveau 1 ; barre et
  valeur de PV ; six segments d'Essence + texte `x/6` ; trois fragments d'âme ;
  valeurs temporaires d'or et de cristaux.
- **Menu droit** : Attaque, Objet, Garde, Méditer, S'échapper.
- **Ordre des tours** affiché en haut.
- **Zone centrale** : messages de combat et emplacement des QTE (placeholder ici).
- Interface en français.
- État activé/désactivé des boutons selon le contexte (ex. action impossible).
- Adaptation aux différentes résolutions ; entrées clavier, souris et bases manette.

## Contraintes techniques

- L'UI lit l'état exposé par le serveur (lot 02), elle ne décide rien d'autorité.
- Valeurs d'affichage et tailles configurables si pertinent.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Construire le HUD bas gauche avec tous les éléments listés.
2. Construire le menu d'actions à droite (5 boutons).
3. Construire l'affichage de l'ordre des tours en haut.
4. Construire la zone centrale (messages + emplacement QTE).
5. Brancher l'UI sur l'état du combat et gérer activé/désactivé.
6. Vérifier le rendu sur plusieurs résolutions et les entrées.

## Cas limites à gérer

- Résolutions extrêmes (petites/grandes) : éléments toujours visibles.
- État de combat inexistant : HUD neutre, pas d'erreur.
- Essence/PV à 0 ou au maximum : affichage correct.

## Critères d'acceptation vérifiables

- Tous les éléments du HUD listés sont présents et reliés aux données.
- Les cinq boutons d'actions existent et reflètent leur état.
- L'ordre des tours s'affiche en haut.
- L'interface est en français et reste lisible sur plusieurs résolutions.

## Tests manuels à effectuer

- Ouvrir l'UI et vérifier chaque élément.
- Simuler des valeurs (PV, Essence, fragments) et vérifier l'affichage.
- Tester l'activation/désactivation des boutons.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucune logique de QTE, de kit ou d'ennemi.
- Pas d'art final.
- Ne pas commencer le lot 04.

## Message de commit conseillé

```
feat: add functional combat interface
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation que le statut du lot 03 est passé à TERMINÉ et la date renseignée dans `docs/lots/README.md` (colonne Hash commit laissée vide ; pas de second commit pour le hash).
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
