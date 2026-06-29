# Lots de développement — Index et guide d'exécution

> Dernière mise à jour : **2026-06-29**

Ce dossier découpe le développement du jeu en **lots** numérotés. Chaque lot est
un fichier autonome décrivant une tâche précise, à exécuter **une par une**.

## Méthode

- Chaque lot est conçu pour être réalisé dans une **conversation Claude Code distincte**.
- L'agent d'un lot ne lit **que** le fichier du lot concerné (et les fichiers de
  code explicitement nécessaires). Il ne parcourt jamais tout le dépôt.
- Les lots s'exécutent **dans l'ordre**. On ne commence jamais le lot suivant
  dans la même conversation.
- Après réussite d'un lot, l'agent met à jour **uniquement** ce README :
  - passer le statut du lot à **TERMINÉ** et renseigner la **date** ;
  - la colonne **Hash commit** peut rester **vide** pendant ce commit (le hash
    n'existe pas encore au moment de l'écrire) ;
  - faire **un seul commit** correspondant au lot et pousser sur `main` ;
  - communiquer le **hash réel** du commit poussé **dans la réponse finale** ;
  - ne **pas** créer un deuxième commit uniquement pour enregistrer le hash.

## Avertissements

- ⚠️ **Ne jamais exécuter plusieurs lots dans la même conversation.** Un lot = une
  conversation = un commit.
- ⚠️ **Ne jamais lancer un lot dont le statut est BLOQUÉ ou EN ATTENTE.** Attendre
  que sa dépendance soit TERMINÉE et que la condition de déblocage soit remplie.
- ⚠️ **Ne jamais ajouter une mécanique non demandée** ni inventer une règle :
  signaler toute contradiction au lieu de décider silencieusement.

## Définition des statuts

- **TODO** (PRÊT À EXÉCUTER) : prêt, dépendances satisfaites, peut être lancé.
- **EN COURS** : un lot est en cours de réalisation dans une conversation.
- **TERMINÉ** : lot réussi, commité et poussé ; statut et date renseignés (la
  colonne Hash commit peut rester vide, le hash étant donné dans la réponse finale).
- **BLOQUÉ** : ne peut pas démarrer tant qu'une condition n'est pas remplie
  (lot précédent non terminé, prototype solo non validé, etc.).

## Commande type à donner à Claude Code

```
Lis uniquement docs/lots/LOT-XX-....md et exécute exactement ce lot.
Ne lis pas les autres lots. N'analyse pas tout le dépôt.
Ne commence aucun autre lot. Signale toute contradiction.
À la fin : mets à jour le statut (TERMINÉ) et la date dans docs/lots/README.md
(laisse la colonne Hash commit vide), fais un seul commit, pousse sur main,
et donne-moi le hash du commit dans ta réponse. Ne crée pas un second commit
juste pour le hash.
```

## Tableau de progression

| Lot | Titre | Statut | Dépend de | Hash commit | MAJ |
|-----|-------|--------|-----------|-------------|-----|
| 01 | Fondation du prototype de combat | TERMINÉ | — | | 2026-06-29 |
| 02 | Moteur de combat et tours | TERMINÉ | 01 | | 2026-06-29 |
| 03 | Interface de combat | TERMINÉ | 02 | | 2026-06-29 |
| 04 | Essence, actions et cooldowns | TERMINÉ | 02, 03 | | 2026-06-29 |
| 05 | QTE offensif | TERMINÉ | 03, 04 | | 2026-06-29 |
| 06 | QTE défensif, Garde et Méditer | EN ATTENTE DU LOT PRÉCÉDENT | 03, 04 | | 2026-06-29 |
| 07 | Épéiste niveau 1 | EN ATTENTE DU LOT PRÉCÉDENT | 04, 05, 06 | | 2026-06-29 |
| 08 | Loup, Bandit et IA | EN ATTENTE DU LOT PRÉCÉDENT | 02, 05, 06 | | 2026-06-29 |
| 09 | Parades, ripostes et défense ennemie | EN ATTENTE DU LOT PRÉCÉDENT | 06, 08 | | 2026-06-29 |
| 10 | Objets, fuite, victoire et défaite | EN ATTENTE DU LOT PRÉCÉDENT | 02, 04 | | 2026-06-29 |
| 11 | Intégration et tests du prototype | EN ATTENTE DU LOT PRÉCÉDENT | 01–10 | | 2026-06-29 |
| 12 | Combat visible et observateurs | BLOQUÉ JUSQU'À VALIDATION DU PROTOTYPE SOLO | 11 | | 2026-06-29 |
| 13 | Système de groupe | BLOQUÉ JUSQU'À VALIDATION DU PROTOTYPE SOLO | 11 | | 2026-06-29 |
| 14 | Invitations et rassemblement | BLOQUÉ JUSQU'À VALIDATION DU PROTOTYPE SOLO | 12, 13 | | 2026-06-29 |
| 15 | Génération des rencontres en groupe | BLOQUÉ JUSQU'À VALIDATION DU PROTOTYPE SOLO | 13, 14 | | 2026-06-29 |
| 16 | Combat multijoueur et Secourir | BLOQUÉ JUSQU'À VALIDATION DU PROTOTYPE SOLO | 12, 14, 15 | | 2026-06-29 |
| 17 | Phase commune des invocations | BLOQUÉ JUSQU'À VALIDATION DU PROTOTYPE SOLO | 02, 16 | | 2026-06-29 |
| 18 | Invocations K.-O. et instinct | BLOQUÉ JUSQU'À VALIDATION DU PROTOTYPE SOLO | 17 | | 2026-06-29 |
| 19 | Région forêt et village | BLOQUÉ JUSQU'À VALIDATION DU COMBAT ET DE LA CONCEPTION DE LA RÉGION | 11 | | 2026-06-29 |
| 20 | Rencontres aléatoires de la forêt | BLOQUÉ JUSQU'À VALIDATION DU COMBAT ET DE LA CONCEPTION DE LA RÉGION | 15, 19 | | 2026-06-29 |
| 21 | Âme, Banque et mort définitive | BLOQUÉ JUSQU'À VALIDATION DU COMBAT ET DE LA CONCEPTION DE LA RÉGION | 10, 19 | | 2026-06-29 |
| 22 | Bestiaire | BLOQUÉ JUSQU'À VALIDATION DU COMBAT ET DE LA CONCEPTION DE LA RÉGION | 08, 19 | | 2026-06-29 |

## Conditions de déblocage

- Un lot devient exécutable uniquement lorsque **toutes les dépendances indiquées
  dans le tableau** sont TERMINÉES. L'ordre numérique ne remplace pas les
  dépendances explicites.
- **Lots 12 à 18** : restent BLOQUÉS tant que le **prototype solo** (lot 11) n'est
  pas validé.
- **Lots 19 à 22** : restent BLOQUÉS tant que le **combat** et la **conception de
  la région** ne sont pas validés.

## Référence

Toutes les valeurs et règles de game design viennent de
[`../design-decisions.md`](../design-decisions.md). En cas de divergence entre un
lot et ce document, **arrêter et signaler la contradiction**.
