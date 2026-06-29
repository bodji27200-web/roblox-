# Lot 21 — Âme, Banque et mort définitive

## Statut

BLOQUÉ JUSQU'À VALIDATION DU COMBAT ET DE LA CONCEPTION DE LA RÉGION (dépend des lots 10 et 19).
Reste bloqué jusqu'à des tests sérieux du système.

## Dépendances

Lot 10 (simulation d'âme/issues) et lot 19 (village/Banque physique).

## Objectif

Implémenter le système d'âme **persistant**, la Banque classique et la Banque
d'âme, ainsi que la mort définitive — avec des protections strictes et sans jamais
supprimer de données sans confirmation atomique et journalisation.

## Résultat attendu

- Trois fragments d'âme persistants gérés en sécurité.
- Une Banque classique fonctionnelle et une Banque d'âme à un emplacement.
- Une mort définitive sûre, journalisée, avec outils développeur.

## Fichiers et dossiers autorisés

- `src/server/persistence/` : DataStore sécurisé, âme, banques.
- `src/server/world/bank/` : interaction avec la Banque physique (lot 19).
- `src/shared/` : configuration et types.
- `docs/lots/README.md` (statut + hash, à la fin).

## Fichiers interdits ou hors périmètre

- Bestiaire (lot 22). Modification du moteur de combat de base.

## Règles fonctionnelles détaillées

- **Trois fragments** persistants ; un fragment n'est perdu que lors d'une **défaite
  solo ou d'une défaite totale du groupe**.
- Un simple **K.-O. relevé** ne détruit aucun fragment.
- **Protections** contre les bugs et déconnexions involontaires.
- **Deux premières morts** : retour au village, perte de l'or transporté et du butin
  d'expédition, équipement conservé, or de la Banque conservé.
- **Mort définitive** (3e fragment) : perte du personnage, des domaines/maîtrises, de
  l'équipement, de l'inventaire, de la progression et du contenu de la **Banque
  classique** ; seul un objet de la **Banque d'âme** survit.
- **Banque** : physique dans le village ; dépôt/retrait d'or ; or transporté exposé ;
  or déposé survit aux deux premières morts ; contenu perdu à la mort définitive.
- **Banque d'âme** : déblocage très coûteux ; **un seul emplacement** ; conserve un
  seul objet après la mort définitive ; récupérable par le personnage suivant ; non
  utilisable par le personnage actuel tant qu'il est stocké.

## Contraintes techniques

- **Sécurité DataStore** : ne jamais supprimer les données avant une **confirmation
  atomique** et une **journalisation**.
- **Outils développeur obligatoires** (restauration, inspection).
- Aucune création de **mémorial**.
- Constantes centralisées.
- Ne lire que ce fichier de lot et les fichiers de code strictement nécessaires.
- Ne jamais analyser tout le dépôt.

## Étapes d'implémentation

1. Mettre en place un accès DataStore sécurisé (lecture/écriture atomique, logs).
2. Persister les trois fragments d'âme et les protéger (bugs/déconnexions).
3. Implémenter les conséquences des deux premières morts.
4. Implémenter la mort définitive (suppression atomique + journalisation).
5. Implémenter la Banque classique (dépôt/retrait, persistance, perte à la mort finale).
6. Implémenter la Banque d'âme (un emplacement, survie d'un objet).
7. Ajouter les outils développeur.

## Cas limites à gérer

- Déconnexion involontaire en plein combat : ne pas détruire de fragment.
- Échec d'écriture DataStore : ne jamais supprimer sans confirmation.
- Objet en Banque d'âme : indisponible pour le personnage actuel.

## Critères d'acceptation vérifiables

- Trois fragments persistants ; perte uniquement sur défaite solo/totale.
- Protections contre bugs/déconnexions effectives.
- Banque classique et Banque d'âme conformes.
- Aucune suppression de données sans confirmation atomique + journalisation.
- Outils développeur présents ; aucun mémorial.

## Tests manuels à effectuer

- Simuler les deux premières morts et vérifier les pertes/conservations.
- Simuler une mort définitive et vérifier la suppression journalisée.
- Tester dépôt/retrait à la Banque et la survie d'un objet en Banque d'âme.
- (Roblox Studio requis pour un test réel — voir la note ci-dessous.)

## Ce qui ne doit pas être développé

- Aucun bestiaire, aucun mémorial.
- Ne pas commencer le lot 22.

## Message de commit conseillé

```
feat: add persistent soul bank and permadeath systems
```

## Format de la réponse finale attendue

- Liste des fichiers créés ou modifiés.
- Contradictions éventuelles détectées (sinon « aucune »).
- Confirmation de la mise à jour du statut + hash du lot 21 dans `docs/lots/README.md`.
- Le hash du commit poussé sur `main`.
- Indiquer explicitement ce qui n'a pas pu être testé sans Roblox Studio.
