# Lot 04 — Essence, actions et cooldowns

## Statut

EN ATTENTE DU LOT PRÉCÉDENT (dépend des lots 02 et 03).

## Dépendances

Lot 02 (moteur de tours) et lot 03 (interface de combat).

## Objectif

Implémenter le système de ressource Essence, le coût des actions, leur validation
serveur, et le système de cooldowns compté en tours personnels. Aucun kit Épéiste
complet ici : on pose les mécaniques génériques.

## Résultat attendu

- Une Essence par combattant gérée côté serveur, bornée à 6, démarrant à 0.
- Des gains d'Essence corrects selon les règles validées.
- Des coûts d'action validés serveur (refus si Essence insuffisante).
- Des cooldowns décomptés uniquement sur les tours personnels.
- L'affichage des coûts, du sablier et de la durée relié à l'UI (lot 03).

## Fichiers et dossiers autorisés

- `src/server/combat/` : gestion Essence, validation, cooldowns.
- `src/shared/` : configuration des coûts/cooldowns génériques, types.
- `src/client/ui/` : affichage des coûts/sablier/durée (branchement uniquement).
- `docs/lots/README.md` (statut + hash, à la fin).

## Fichiers interdits ou hors périmètre

- Kit Épéiste complet (lot 07), QTE (lots 05/06), ennemis (lot 08).

## Règles fonctionnelles détaillées

- Essence : départ **0**, maximum **6** (jamais dépassé).
- **+1 Essence** au début de chaque tour personnel.
- Attaque de base : **+1 Essence** si l'action n'est pas annulée.
- Méditer : **+2 Essence**.
- Coûts validés par le serveur : une compétence trop chère ne peut pas être utilisée.
- Cooldowns comptés selon les **tours personnels** de l'utilisateur ; les tours des
  alliés/ennemis ne les réduisent pas. Une compétence à 2 tours de recharge revient
  au 3e tour personnel.
- Timer de 20 s et Garde automatique (réutiliser le lot 02, ne pas redéfinir).
- Afficher coût en Essence, icône sablier (cooldown) et durée (chronomètre) si besoin.

## Contraintes techniques

- Toute la comptabilité Essence/cooldown est autoritaire côté serveur.
- Toutes les valeurs (gains, max, coûts génériques) centralisées en configuration.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Ajouter l'état Essence par combattant (init à 0).
2. Implémenter le gain +1 au début du tour personnel et le plafond à 6.
3. Implémenter le gain de l'attaque de base (si non annulée) et de Méditer (+2).
4. Implémenter la validation de coût serveur.
5. Implémenter le compteur de cooldowns en tours personnels.
6. Brancher l'affichage coût/sablier/durée à l'UI.

## Cas limites à gérer

- Essence déjà à 6 : pas de dépassement lors d'un gain.
- Action annulée : ne pas accorder l'Essence de l'attaque de base.
- Cooldown au moment exact du retour : disponible au bon tour personnel.

## Critères d'acceptation vérifiables

- L'Essence démarre à 0 et ne dépasse jamais 6.
- Les gains (+1 tour, +1 attaque non annulée, +2 Méditer) sont corrects.
- Une compétence trop chère est refusée par le serveur.
- Un cooldown de 2 tours revient bien au 3e tour personnel.
- L'UI affiche coûts, sablier et durée.

## Tests manuels à effectuer

- Enchaîner des tours et vérifier les gains d'Essence.
- Tenter une action trop chère et vérifier le refus.
- Vérifier le décompte d'un cooldown sur plusieurs tours personnels.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucun kit Épéiste complet ni aucune compétence finale.
- Aucun QTE.
- Ne pas commencer le lot 05.

## Message de commit conseillé

```
feat: add combat resources actions and cooldowns
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation de la mise à jour du statut + hash du lot 04 dans `docs/lots/README.md`.
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
