# Décisions de conception du jeu

## Vision générale

- Jeu Roblox développé en Luau.
- RPG principalement PvE avec exploration libre et combats au tour par tour actif.
- Le joueur choisit une action ; certaines attaques et défenses utilisent des QTE.
- Priorité aux combats difficiles, à la découverte, aux expéditions risquées et à la progression d'une guilde.
- Le jeu doit rester entièrement viable en solo et en duo, tout en fonctionnant aussi à trois ou quatre joueurs.
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
- Banque : dépôt et retrait d'or (voir section Banque).
- Les fonctions détaillées de chaque bâtiment seront définies plus tard.

## Exploration et rencontres

- Le joueur explore librement la forêt ; les ennemis ordinaires ne sont pas forcément visibles.
- Hors des limites du village, une rencontre peut se déclencher et lancer un combat, en moyenne toutes les 45 à 90 secondes, avec une période de sécurité après chaque combat.
- Première région : un joueur niveau 1 rencontre surtout des ennemis niveau 1 ; les niveau 2 sont plus rares et déjà dangereux.
- À partir de la deuxième région, les niveaux rencontrés peuvent être beaucoup plus variés.
- Une rencontre beaucoup trop puissante doit être rare et reconnaissable comme une menace exceptionnelle.
- Les boss principaux ne sont jamais des rencontres aléatoires : ils se trouvent dans une zone précise ou sont invoqués volontairement.
- Les mini-boss peuvent apparaître aléatoirement à partir de la deuxième région ; aucun dans la première.

## Combat dans le monde

- Le combat se déroule directement à l'endroit où se trouve le joueur, sans téléportation vers une arène séparée.
- Les autres joueurs proches peuvent voir le combat.
- Une zone de combat temporaire empêche les joueurs extérieurs d'intervenir ; ceux qui ne participent pas peuvent seulement observer.

## Groupes

- Un groupe peut contenir jusqu'à 4 joueurs.
- Le jeu reste pensé pour rester viable en solo et en duo ; les rencontres doivent aussi fonctionner à trois ou quatre.
- Le groupe dispose d'un petit onglet dédié, probablement à gauche de l'écran.

### Phase de rassemblement

- Quand un combat se déclenche, seuls les membres du groupe suffisamment proches et éligibles reçoivent automatiquement une invitation.
- La phase de rassemblement dure au maximum 10 secondes.
- Accepter téléporte le joueur vers un emplacement sécurisé à gauche ou à droite de celui qui a déclenché le combat.
- Refuser, ou ne pas répondre avant la fin du délai, empêche définitivement de rejoindre ce combat.
- Si aucun membre n'est éligible, ou si tous les membres éligibles répondent avant la fin du délai, le combat commence immédiatement.
- Un joueur trop éloigné, dans une autre région, déjà en combat, mort ou en transition ne reçoit pas l'invitation.
- Les joueurs qui n'ont pas rejoint peuvent observer le combat, mais pas intervenir.

### Génération des rencontres en groupe

- La rencontre est générée avant le début du combat.
- Une table différente est utilisée selon le nombre de membres proches et éligibles : solo, duo, trio ou groupe de quatre.
- Cette table détermine le nombre d'ennemis, leurs types, leurs niveaux et les probabilités de rencontres rares.
- Une fois créée, la rencontre ne se rééquilibre plus : si un invité refuse ou ne répond pas, la difficulté initiale est conservée.
- Les membres éloignés ou inéligibles ne sont jamais comptés.

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

### Ordre des tours et QTE

- L'ordre des tours est déterminé principalement par la statistique Clairvoyance.
- Une attaque simple utilise normalement un seul QTE ; certaines compétences spéciales, attaques multiples ou techniques de boss peuvent utiliser une courte séquence de QTE.
- Chaque attaque ennemie est défendue séparément.
- Le QTE ne devient pas automatiquement plus difficile parce que plusieurs ennemis ont ciblé le même joueur pendant la manche : toute difficulté supplémentaire doit provenir d'une compétence, d'un effet ou d'une attaque coordonnée précise.

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

## Phase des invocations

- Les invocations n'ont pas chacune un tour complet indépendant et ne sont pas ajoutées séparément dans l'ordre de Clairvoyance.
- Après le tour de l'Invocateur, toutes ses créatures passent dans une phase d'invocation commune.
- Une invocation principale peut réaliser une action complète.
- Les autres invocations réalisent seulement une action secondaire limitée : protéger, soutenir, préparer, se repositionner ou utiliser un petit effet.
- Certaines compétences avancées pourront permettre des attaques coordonnées (plus tard).

### Invocateur neutralisé

- Si l'Invocateur est étourdi, inconscient ou incapable de donner des ordres, ses créatures passent en comportement instinctif.
- Elles ne peuvent plus utiliser d'action complète commandée, mais peuvent protéger leur maître, esquiver ou utiliser une petite action naturelle.
- Réservé pour plus tard : un lien bestial exceptionnel pouvant provoquer un état Enragé. Aucun système complet de lien bestial pour le moment.

### Invocation K.-O.

- Une invocation à 0 PV passe K.-O. et reste hors d'action.
- L'Invocateur dispose d'une action universelle pour la relever : elle coûte 2 Essence et consomme le tour entier.
- L'invocation revient avec 25 % de ses PV maximum.
- Une même invocation ne peut être relevée qu'une seule fois par combat ; si elle retombe K.-O., elle reste indisponible jusqu'à un soin adapté ou au retour au village.
- Les invocations ne meurent jamais définitivement.

## Joueur K.-O. et Secourir

- Un joueur à 0 PV passe K.-O.
- Un allié vivant peut utiliser l'action universelle Secourir : elle coûte 2 Essence et consomme tout son tour.
- Le joueur revient avec 15 % de ses PV maximum et attend son prochain tour normal avant d'agir.
- Chaque joueur ne peut être relevé qu'une seule fois par combat ; s'il retombe à 0 PV pendant le même combat, il reste définitivement hors combat jusqu'à la fin.
- En solo, atteindre 0 PV provoque directement la défaite.
- Un simple K.-O. relevé ne détruit pas un fragment d'âme.

## Système d'âme

- L'interface en bas à gauche affiche une icône d'âme divisée en trois fragments.
- Le personnage possède trois morts véritables possibles : une défaite confirmée détruit un fragment d'âme.
- Un K.-O. relevé pendant un combat n'est pas une mort véritable.
- Lorsque le troisième et dernier fragment disparaît, le personnage est supprimé définitivement : maîtrise des domaines, équipement, inventaire et progression personnelle sont perdus.
- Aucun mémorial des personnages morts ne doit être créé.
- À détailler plus tard : règles précises distinguant une défaite normale d'une mort véritable ; protection technique contre les morts causées par un bug serveur ou une déconnexion involontaire.

## Objets

- Le menu Objet donne accès aux consommables disponibles.
- Maximum deux potions par combat ; les règles des autres objets seront définies plus tard.

## Interface permanente

En bas à gauche : nom du personnage, niveau de maîtrise le plus élevé (max 12), barre verte de points de vie, Essence actuelle sur 6, or, cristaux bleus, icône d'âme (trois fragments).

### Cristaux bleus

- Servent à progresser dans les niveaux de domaine ; obtenus en vainquant des ennemis.
- Une créature du même niveau donne une quantité modérée ; un niveau supérieur (créature ou boss) donne un bonus de 50 %.
- Les coûts et quantités exacts restent à équilibrer.

## Banque

- Le village possède un bâtiment Banque permettant de déposer et retirer son or.
- L'or conservé sur le personnage n'est pas protégé ; l'or déposé à la Banque est conservé après les premières morts du personnage.
- La Banque ne peut être utilisée qu'en revenant physiquement au village.
- Lors de la mort définitive du personnage, le contenu de la Banque classique est également perdu.

### Banque d'âme — plus tard

- Un accès spécial à la Banque d'âme pourra être débloqué pour un prix très élevé.
- Elle possède un seul emplacement et permet de conserver durablement un seul objet après la mort définitive ; le personnage suivant peut le récupérer.
- Tant que l'objet est stocké, le personnage actuel ne peut pas l'utiliser.
- Le prix exact, les objets autorisés et les conditions de remplacement restent à définir.

## PvP — plus tard

- Le PvP n'est pas une priorité.
- Une liste de joueurs pourra être affichée/masquée en haut à droite, indiquant seulement le nom Roblox et le niveau de maîtrise le plus élevé.
- Cliquer sur un joueur permettra plus tard de l'inviter dans un groupe ou de lui proposer un duel.

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
- Règles distinguant une défaite normale d'une mort véritable, et protection contre les morts par bug ou déconnexion.
- Lien bestial / état Enragé pour l'Invocateur.
- Banque d'âme : prix, objets autorisés, conditions de remplacement.
