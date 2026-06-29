# Décisions de conception du jeu

## Vision générale

- Jeu Roblox développé en Luau.
- RPG principalement PvE avec exploration libre et combats au tour par tour actif.
- Le joueur choisit une action ; certaines attaques et défenses utilisent des QTE.
- Priorité aux combats difficiles, à la découverte, aux expéditions risquées et à la progression d'une guilde.
- Le PvP sera ajouté beaucoup plus tard comme fonctionnalité secondaire.
- Le jeu ne doit pas devenir une copie de Deepwoken ; l'inspiration du combat vient du plaisir ressenti dans Arcane Lineage, sans copier ses systèmes.

## Monde

- Cinq régions au total ; la première est une forêt.
- Un village sécurisé au centre de la forêt contient la guilde et les bâtiments principaux.
- Quatre sorties entourent le village (haut, bas, gauche, droite), chacune menant plus tard vers une autre région ; tant qu'une région n'est pas terminée, sa sortie affiche « Bientôt disponible ».
- La première région est de taille moyenne, dense et très travaillée, et sera entièrement terminée avant les suivantes.
- La géographie principale est créée à la main ; certains événements, ressources, rencontres et passages secondaires varient entre expéditions.

## Village et bâtiments

- Guilde : expéditions, progression et informations.
- Forgeron : équipement et amélioration d'armes ou d'armures.
- Marchand : achat et vente d'objets.
- Alchimiste : potions et consommables.
- Bâtiment ou maître d'armes : accès aux armes et aux domaines associés.
- Les fonctions détaillées de chaque bâtiment seront définies plus tard.

## Exploration et rencontres

- Le joueur explore librement la forêt ; les ennemis ordinaires ne sont pas forcément visibles.
- Hors des limites du village, une rencontre peut se déclencher et lancer un combat, en moyenne toutes les 45 à 90 secondes, avec une période de sécurité après chaque combat.
- Première région : un joueur niveau 1 rencontre surtout des ennemis niveau 1 ; les niveau 2 sont plus rares et déjà dangereux.
- À partir de la deuxième région, les niveaux rencontrés peuvent être beaucoup plus variés.
- Une rencontre beaucoup trop puissante doit être rare et reconnaissable comme une menace exceptionnelle.
- Les boss principaux ne sont jamais des rencontres aléatoires : ils se trouvent dans une zone précise ou sont invoqués volontairement.
- Les mini-boss peuvent apparaître aléatoirement à partir de la deuxième région ; aucun dans la première.

## Bestiaire

- Une créature est enregistrée après avoir été rencontrée.
- Les informations se complètent par l'observation, les combats, les victoires et l'étude.
- Certaines créatures peuvent devenir des invocations permanentes.

## Domaines et hybridation

- Pas de classe unique : chaque domaine a ses propres niveaux de maîtrise.
- Le niveau 1 offre déjà une base de gameplay complète et amusante ; le niveau maximal absolu est 12.
- Le joueur choisit deux domaines importants :
  - domaine principal : niveau 7 au départ, puis progression possible jusqu'au niveau 12 ;
  - domaine secondaire : niveau 5 maximum.
- Tous les autres domaines restent limités au niveau 1.
- Le système doit permettre de vrais builds hybrides sans permettre de tout maîtriser.
- Les récompenses de chaque niveau seront définies plus tard ; le nombre de compétences équipables dépendra probablement de la maîtrise (règle exacte ouverte).

## Domaine Invocateur

- Niveaux 1 à 4 : une invocation permanente active maximum.
- Niveaux 5 à 11 : deux invocations permanentes actives maximum.
- Niveau 12 : trois invocations permanentes actives maximum.
- La première invocation permet de commencer le domaine ; les autres créatures doivent être rencontrées et obtenues dans le monde.
- Les invocations utilisent une partie de la puissance ou des ressources globales du personnage.
- Une invocation ne doit jamais être un allié gratuit ajouté à un autre domaine complet.

## Structure du combat

Menu principal à droite : Attaque, Objet, Garde, Méditer, S'échapper. La règle exacte de fuite reste à définir.

## Essence

- Ressource pour lancer les compétences ; maximum 6, affichée en bas à gauche (six segments bleus, texte comme 2/6).
- Récupération automatique de 1 Essence par tour ; l'attaque de base en donne 1 de plus.
- Méditer donne 2 Essence, fait passer le tour et applique pendant un tour un malus de 40 % de défense.
- Même après avoir médité, le joueur peut utiliser le QTE défensif contre les attaques ennemies.
- Une parade parfaite ne donne aucune Essence.

## Attaque et compétences

- Cliquer sur Attaque ouvre la liste des compétences équipées.
- Chaque compétence affiche : nom, icône, coût en Essence, temps de recharge (sablier) et durée d'effet (chronomètre) si nécessaire.
- Après sélection, elle lance son animation et éventuellement son QTE.
- Les QTE propres à chaque domaine et le nombre de compétences équipées restent ouverts.

## Défense universelle

Quand un ennemi attaque, un QTE défensif apparaît : un curseur se déplace sur une longue barre, sa vitesse dépendant notamment du niveau de maîtrise de l'attaquant. Une zone rouge représente la défense normale, une petite zone jaune la parade parfaite.

### Zone rouge

- Réduit les dégâts reçus de 50 % ; l'attaque touche réellement, donc les effets secondaires peuvent s'appliquer.

### Zone jaune : parade parfaite

- Le personnage dévie complètement l'attaque, ne subit aucun dégât et aucun effet secondaire.
- La parade parfaite permet une riposte : l'adversaire reçoit un second QTE spécial, beaucoup plus difficile. S'il le réussit, il annule la riposte ; sinon, il la subit.
- Une contre-parade réussie termine l'échange et ne peut jamais déclencher une nouvelle riposte.
- Aucun gain d'Essence ; les dégâts et effets de la riposte seront équilibrés plus tard.

## Action Garde

- Garde fait passer le tour ; le joueur n'utilise pas le QTE défensif.
- Le personnage absorbe automatiquement 70 % des dégâts reçus.
- Les règles sur les effets secondaires pendant Garde restent à tester.

## Objets

- Le menu Objet donne accès aux consommables disponibles.
- Maximum deux potions par combat ; les règles des autres objets seront définies plus tard.

## Interface permanente

En bas à gauche : nom du personnage, niveau de maîtrise le plus élevé (max 12), barre verte de points de vie, Essence actuelle sur 6, or, cristaux bleus.

### Cristaux bleus

- Servent à progresser dans les niveaux de domaine ; obtenus en vainquant des ennemis.
- Une créature du même niveau donne une quantité modérée ; un niveau supérieur (créature ou boss) donne un bonus de 50 %.
- Les coûts et quantités exacts restent à équilibrer.

## Groupes et PvP — plus tard

- Le PvP n'est pas prioritaire.
- Une liste de joueurs pourra être affichée/masquée en haut à droite, indiquant seulement le nom Roblox et le niveau de maîtrise le plus élevé.
- Cliquer sur un joueur permettra plus tard de l'inviter dans un groupe ou de lui proposer un duel.
- Le groupe aura un petit onglet séparé, probablement à gauche de l'écran.

## Points encore ouverts

- Effets précis des statistiques de départ.
- Nombre de compétences équipables selon la maîtrise.
- QTE propres à chaque domaine.
- Règles exactes de fuite.
- Dégâts et effets de la riposte.
- Fonctionnement détaillé des bâtiments.
- Progression exacte entre les niveaux 1 et 12.
- Liste des créatures de la première région.
- Règles finales des effets secondaires pendant l'action Garde.
