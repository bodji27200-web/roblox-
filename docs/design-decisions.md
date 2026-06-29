# Décisions de conception validées

## Plateforme et développement

- Le jeu est prévu sur **Roblox**, développé en **Luau**.
- Claude Code travaillera par lots précis et limités.
- Roblox Studio et Rojo seront utilisés plus tard sur le PC de la copine de l’utilisateur.
- `CLAUDE.md` restera court et technique ; ce fichier conserve les décisions de game design.

## Structure générale du jeu

- Le jeu est un **RPG au tour par tour actif**, inspiré par ce que l’utilisateur aime dans Arcane Lineage, mais sans copier ses systèmes.
- Le cœur du jeu repose sur :
  - des combats PvE difficiles ;
  - la découverte de créatures, domaines et objets rares ;
  - des expéditions risquées ;
  - une guilde vivante ;
  - le PvP comme fonctionnalité secondaire ajoutée plus tard.
- La boucle principale envisagée est :
  **village/guilde → préparation → exploration d’une région → rencontre aléatoire → combat → découverte/récompense → retour au village**.

## Monde et régions

- Le jeu comprendra **5 régions** au total.
- Chaque région aura une géographie principale créée à la main.
- Certains événements, rencontres, ressources et passages secondaires pourront varier.
- La première région sera une **forêt**.
- Au centre de cette forêt se trouvera le **hub principal**, sous forme de village avec la guilde et les services importants.
- Quatre sorties seront visibles autour du village : gauche, droite, haut et bas.
- Tant que les régions suivantes ne sont pas disponibles, ces sorties afficheront un message du type **« Bientôt disponible »**.
- La première région ne doit être ni minuscule ni gigantesque ; elle doit être assez dense pour servir de première version excellente du jeu.
- Le développement commencera uniquement par cette première région, réalisée avec un niveau de finition élevé avant d’attaquer les suivantes.

## Exploration et rencontres

- Le joueur se déplace librement dans le monde.
- Les ennemis ne sont pas nécessairement visibles sur la carte.
- Une fois hors des limites sécurisées du village, une rencontre peut se déclencher aléatoirement et lancer un combat.
- La fréquence visée est approximativement une rencontre toutes les **1 minute**, mais cette valeur devra être testée et ajustée pour éviter l’agacement.
- Dans la première région :
  - un joueur niveau 1 rencontrera surtout des ennemis de niveau 1 ;
  - des ennemis de niveau 2 pourront apparaître plus rarement ;
  - les écarts de niveau doivent rester limités.
- À partir de la deuxième région :
  - des ennemis de niveaux très variés pourront apparaître ;
  - le joueur pourra parfois tomber sur une menace bien trop forte pour lui ;
  - ces rencontres extrêmes devront rester rares et clairement télégraphiées pour ne pas sembler injustes.

## Boss et mini-boss

- Les boss principaux ne seront pas rencontrés aléatoirement comme des ennemis ordinaires.
- Ils seront :
  - placés dans des zones spécifiques ;
  - ou invoqués volontairement par le joueur via une condition, un rituel, un objet ou un événement.
- Les mini-boss pourront apparaître comme des rencontres normales, mais seulement à partir de la deuxième région.
- La première région doit rester adaptée aux joueurs débutants.

## Bestiaire

- Le jeu possédera un bestiaire.
- Les créatures rencontrées y seront enregistrées progressivement.
- Les informations pourront se compléter selon l’observation, l’affrontement, la victoire et l’étude de la créature.
- Certaines créatures pourront être liées au domaine Invocateur.

## Système de domaines et d’hybridation

- Chaque personnage peut apprendre plusieurs domaines.
- Le niveau 1 d’un domaine donne déjà une base de gameplay complète et jouable.
- Le joueur choisit deux domaines pour former son build :
  - un **domaine principal**, pouvant atteindre d’abord le niveau 7 puis, plus tard, progresser jusqu’au niveau 12 ;
  - un **domaine secondaire**, limité au niveau 5 ;
  - tous les autres domaines restent limités au niveau 1.
- Ce système doit permettre de vrais builds hybrides tout en empêchant un personnage de tout maîtriser au niveau maximal.
- Le niveau 12 est le niveau maximal d’un domaine.

## Domaine Invocateur

- Niveaux 1 à 4 : 1 invocation permanente active maximum.
- Niveaux 5 à 11 : 2 invocations permanentes actives maximum.
- Niveau 12 : 3 invocations permanentes actives maximum.
- Les invocations sont rencontrées et obtenues dans le monde, à l’exception de la première nécessaire pour commencer le domaine.
- Les invocations permanentes utilisent une partie de la puissance ou des ressources globales du personnage afin d’éviter qu’un domaine secondaire d’invocation soit un bonus gratuit.

## PvP et groupes — plus tard

- Le PvP ne sera pas une priorité pendant le développement initial.
- Il sera ajouté comme fonctionnalité complémentaire lorsque le PvE sera solide.
- Une liste de joueurs pourra être affichée en haut à droite et ouverte ou fermée.
- Pour chaque joueur, seules deux informations seront affichées :
  - son nom Roblox ;
  - son niveau de maîtrise le plus élevé.
- Cliquer sur un joueur permettra plus tard :
  - de l’inviter dans un groupe ;
  - de lui proposer un duel PvP.
- Le système de groupe disposera d’un petit onglet dédié, probablement à gauche de l’écran.
