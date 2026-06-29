# Lot 09 — Parades, ripostes et défense ennemie

## Statut

EN ATTENTE DU LOT PRÉCÉDENT (dépend des lots 06 et 08).

## Dépendances

Lot 06 (QTE défensif/parade parfaite) et lot 08 (Loup, Bandit, IA).

## Objectif

Implémenter la riposte après parade parfaite, le QTE de contre-parade, la fin
obligatoire de la chaîne, et la défense ennemie pilotée par des profils
configurables (jamais une probabilité globale identique pour tous).

## Résultat attendu

- Une parade parfaite pouvant déclencher une riposte.
- Un QTE de contre-parade plus difficile, avec fin de chaîne garantie.
- Une défense ennemie variée selon des profils configurables.
- Des journaux développeur expliquant le résultat de l'IA.

## Fichiers et dossiers autorisés

- `src/server/combat/` : riposte, contre-parade, application des dégâts.
- `src/client/qte/` : QTE de contre-parade.
- `src/shared/` : profils de défense ennemie configurables, types.
- `docs/lots/README.md` (statut + hash, à la fin).

## Fichiers interdits ou hors périmètre

- Objets/fuite/issues (lot 10). Monde, groupe, invocations.

## Règles fonctionnelles détaillées

- Une parade parfaite peut déclencher une riposte si le défenseur en a la capacité.
- La riposte utilise les dégâts de l'attaque de base (prototype).
- L'attaquant reçoit un **QTE spécial beaucoup plus difficile** :
  - réussite → riposte **complètement annulée** ;
  - échec → la riposte inflige ses dégâts.
- Une contre-parade réussie **termine l'échange** et ne déclenche jamais une nouvelle
  riposte : **aucune boucle infinie**.
- Aucun gain d'Essence dans cette séquence.
- Capacités anatomiques : le Loup utilise esquive (pas de parade armée) ; le Bandit
  utilise blocage, parade parfaite, riposte, contre-parade.
- **Défense ennemie configurable** : pas de pourcentage global identique pour tous.
  Le calcul considère : niveau/score de maîtrise ; type de créature ; défenses
  anatomiquement autorisées ; état actuel ; difficulté de l'attaque reçue ; variation
  aléatoire contrôlée.

## Contraintes techniques

- Toutes les constantes dans des modules de configuration (profils de défense).
- Calcul contrôlé et explicable ; journaux développeur indiquant pourquoi l'IA a
  obtenu son résultat.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Implémenter le déclenchement de riposte après parade parfaite.
2. Implémenter le QTE de contre-parade (plus difficile).
3. Garantir la fin de chaîne après contre-parade (pas de nouvelle riposte).
4. Implémenter les profils de défense ennemie configurables.
5. Brancher les capacités anatomiques (Loup vs Bandit).
6. Ajouter les journaux développeur du raisonnement défensif.

## Cas limites à gérer

- Tentative de relancer une riposte après contre-parade : interdite.
- Loup essayant une parade armée : impossible (esquive uniquement).
- Variation aléatoire : doit rester bornée et reproductible en mode test.

## Critères d'acceptation vérifiables

- Parade parfaite → riposte possible ; contre-parade réussie annule la riposte.
- Aucune boucle infinie de ripostes.
- Aucun gain d'Essence dans la séquence.
- La défense ennemie varie selon les profils, jamais une valeur globale unique.
- Les journaux expliquent le résultat de l'IA.

## Tests manuels à effectuer

- Provoquer une parade parfaite et une riposte, puis réussir/échouer la contre-parade.
- Vérifier l'absence de seconde riposte.
- Observer les journaux de défense ennemie pour le Loup et le Bandit.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucun objet, fuite ou issue de combat (lot 10).
- Ne pas commencer le lot 10.

## Message de commit conseillé

```
feat: add parry riposte and enemy defense rules
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation de la mise à jour du statut + hash du lot 09 dans `docs/lots/README.md`.
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
