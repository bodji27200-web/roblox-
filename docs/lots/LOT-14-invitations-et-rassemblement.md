# Lot 14 — Invitations et rassemblement

## Statut

BLOQUÉ JUSQU'À VALIDATION DU PROTOTYPE SOLO (dépend des lots 12 et 13).

## Dépendances

Lot 12 (combat visible/observateurs) et lot 13 (système de groupe).

## Objectif

Implémenter la phase d'invitation au combat et de rassemblement des membres de
groupe proches et éligibles, avec un délai maximum de 10 secondes et une
téléportation sécurisée des membres acceptant.

## Résultat attendu

- Une invitation envoyée uniquement aux membres proches et éligibles.
- Une phase de rassemblement de 10 s maximum, avec démarrage anticipé.
- Une téléportation vers un emplacement de combat sécurisé pour les acceptants.

## Fichiers et dossiers autorisés

- `src/server/combat/gathering/` : invitations, éligibilité, téléportation.
- `src/client/ui/` : invitation à rejoindre (accepter/refuser).
- `src/shared/` : configuration (délai, distance d'éligibilité).
- `docs/lots/README.md` (à la fin : passer le statut à TERMINÉ + renseigner la date ; colonne Hash commit laissée vide).

## Fichiers interdits ou hors périmètre

- Génération des rencontres (lot 15), combat multijoueur/Secourir (lot 16).

## Règles fonctionnelles détaillées

- Seuls les membres du groupe **proches et éligibles** reçoivent l'invitation.
- Critères d'**inéligibilité** : trop éloigné, dans une autre région, déjà en
  combat, mort, ou en transition.
- La phase dure **au maximum 10 secondes**.
- Accepter téléporte le membre vers un **emplacement de combat sécurisé**.
- Refuser, ou ne pas répondre avant la fin, empêche de rejoindre plus tard.
- Si **aucun** membre n'est éligible → le combat démarre immédiatement.
- Si **tous** les éligibles ont répondu avant la fin → démarrage immédiat.
- Les non-participants peuvent observer (lot 12) mais jamais intervenir.
- Protection contre la téléportation à travers une zone verrouillée.

## Contraintes techniques

- Autorité serveur sur l'éligibilité et la téléportation.
- Constantes (10 s, distance) centralisées.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Déterminer les membres proches et éligibles au déclenchement.
2. Envoyer l'invitation et démarrer le timer de 10 s.
3. Gérer acceptation, refus et expiration.
4. Téléporter les acceptants vers un emplacement sécurisé.
5. Implémenter les démarrages anticipés (aucun éligible / tous ont répondu).
6. Protéger contre la téléportation à travers une zone verrouillée.

## Cas limites à gérer

- Membre qui devient inéligible pendant la phase (mort, transition).
- Tous refusent : combat à un seul participant.
- Réponse juste à la limite des 10 s.

## Critères d'acceptation vérifiables

- Seuls les membres proches/éligibles sont invités.
- Le délai de 10 s et les démarrages anticipés fonctionnent.
- Les acceptants sont téléportés en lieu sûr.
- Refus/non-réponse empêchent de rejoindre.

## Tests manuels à effectuer

- Déclencher un combat en groupe et observer la phase d'invitation.
- Tester acceptation, refus et expiration.
- Tester le démarrage immédiat quand tous répondent.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucune génération de rencontre ni combat multijoueur complet.
- Ne pas commencer le lot 15.

## Message de commit conseillé

```
feat: add combat gathering invitations
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation que le statut du lot 14 est passé à TERMINÉ et la date renseignée dans `docs/lots/README.md` (colonne Hash commit laissée vide ; pas de second commit pour le hash).
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
