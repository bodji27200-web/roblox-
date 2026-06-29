# Décisions de conception du jeu

> Ce document rassemble les décisions de game design **validées**. Les idées
> réservées sont marquées « — plus tard » ou regroupées en fin de document.
> Les valeurs marquées « (provisoire) » sont destinées au prototype et seront
> rééquilibrées.

## Vision générale

- Jeu Roblox développé en Luau.
- RPG principalement PvE avec exploration libre et combats au tour par tour actif.
- Le joueur choisit une action ; certaines attaques et défenses utilisent des QTE.
- Priorité aux combats difficiles, à la découverte, aux expéditions risquées et à la progression d'une guilde.
- Le jeu doit rester entièrement viable en solo et en duo, tout en fonctionnant aussi à trois ou quatre joueurs.
- Le PvP sera ajouté beaucoup plus tard comme fonctionnalité secondaire.
- Le jeu ne doit pas devenir une copie de Deepwoken ; l'inspiration du combat vient du plaisir ressenti dans Arcane Lineage, sans copier ses systèmes.

## Prototype initial

- Le premier domaine développé est l'**Épéiste**.
- Le premier prototype est **solo**, mais le code doit être organisé pour accueillir le multijoueur plus tard.
- L'interface est fonctionnelle et placée comme l'interface future, sans rechercher une qualité visuelle définitive.
- Les premières créatures de test sont le **Loup gris** et le **Bandit égaré**.
- Le système d'âme est seulement **simulé** dans le prototype.
- Aucun DataStore et aucune suppression réelle de personnage pendant les tests ; un bouton développeur permet de restaurer les fragments d'âme.

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

- Le joueur explore librement la forêt ; les ennemis ordinaires ne sont pas forcément visibles avant le déclenchement.
- Hors des limites du village, une rencontre peut se déclencher et lancer un combat, en moyenne toutes les 45 à 90 secondes, avec une période de sécurité après chaque combat.
- Première région : un joueur niveau 1 rencontre surtout des ennemis niveau 1 ; les niveau 2 sont plus rares et déjà dangereux.
- À partir de la deuxième région, les niveaux rencontrés peuvent être beaucoup plus variés.
- Une rencontre beaucoup trop puissante doit être rare et reconnaissable comme une menace exceptionnelle.
- Les boss principaux ne sont jamais des rencontres aléatoires : ils se trouvent dans une zone précise ou sont invoqués volontairement.
- Les mini-boss peuvent apparaître aléatoirement à partir de la deuxième région ; aucun dans la première.

## Combat dans le monde

- Le combat se déroule directement à l'endroit où la rencontre se déclenche, sans téléportation vers une arène séparée.
- Une zone de combat temporaire est créée localement.
- Les autres joueurs proches peuvent observer ; les joueurs extérieurs au combat ne peuvent jamais intervenir.
- Le déplacement libre des participants est bloqué pendant le combat.

## Groupes

- Un groupe peut contenir jusqu'à 4 joueurs.
- Le jeu reste pensé pour être pleinement viable en solo et en duo ; les rencontres peuvent aussi être adaptées aux groupes de trois ou quatre.
- Le groupe dispose d'un petit onglet dédié, probablement à gauche de l'écran.

### Invitation et phase de rassemblement

- Quand un combat se déclenche, seuls les membres du groupe proches et éligibles reçoivent automatiquement une invitation.
- La phase de rassemblement dure au maximum 10 secondes.
- Accepter téléporte le joueur vers un emplacement de combat sécurisé, à gauche ou à droite de celui qui a déclenché le combat.
- Refuser, ou ne pas répondre avant la fin du délai, empêche définitivement de rejoindre ce combat.
- Si aucun membre n'est éligible, ou si tous les membres éligibles répondent avant la fin du délai, le combat commence immédiatement.
- Un joueur trop éloigné, dans une autre région, déjà en combat, mort ou en transition n'est pas éligible et ne reçoit pas l'invitation.
- Les joueurs qui n'ont pas rejoint peuvent observer le combat, mais jamais intervenir.

### Génération des rencontres en groupe

- La rencontre est générée avant le début du combat.
- Une table différente est utilisée selon le nombre de membres proches et éligibles : solo, duo, trio ou groupe de quatre.
- Cette table détermine le nombre d'ennemis, leurs types, leurs niveaux et les probabilités de rencontres rares.
- Une fois créée, la rencontre ne se rééquilibre plus : si un invité refuse ou ne répond pas, la difficulté initiale est conservée.
- Les membres éloignés ou inéligibles ne sont jamais comptés.

## Bestiaire

- Une créature est enregistrée après avoir été rencontrée.
- Les informations se complètent progressivement par l'observation, les combats, les victoires et l'étude (habitat, résistances, objets associés, etc.).
- Aucune fiche n'est remplie automatiquement dès le premier regard.
- Certaines créatures peuvent devenir des invocations permanentes (lien futur avec l'Invocateur).

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

Menu principal à droite : Attaque, Objet, Garde, Méditer, S'échapper.

### Manches et Clairvoyance

- Chaque combattant vivant agit une fois par manche.
- L'ordre d'initiative est recalculé au début de chaque manche.
- La **Clairvoyance** est le facteur principal de l'initiative.
- Les égalités sont départagées de façon contrôlée par le serveur.
- Le joueur dispose de **20 secondes** pour choisir son action ; après expiration, **Garde** est utilisée automatiquement.
- Une attaque ennemie n'est jamais annoncée pendant le tour précédent : son nom et son animation ne sont visibles qu'au moment de son exécution.
- Chaque attaque ennemie possède son propre QTE défensif ; une nouvelle attaque ne devient pas automatiquement plus difficile simplement parce que le joueur a déjà été ciblé pendant la manche. Toute difficulté supplémentaire doit provenir d'une compétence, d'un effet ou d'une attaque coordonnée précise.

## Essence

- Ressource pour lancer les compétences ; maximum **6**, jamais dépassé.
- Au début du combat : **0**.
- Affichée en bas à gauche (six segments bleus, texte comme 2/6).
- Gain naturel : **+1 Essence au début de chaque tour personnel**.
- Attaque de base réussie ou normale : **+1 Essence** supplémentaire ; une attaque de base entièrement annulée par un échec de QTE ne donne pas cette Essence.
- Méditer : **+2 Essence**.
- Une parade parfaite, une riposte ou une contre-parade ne donne aucune Essence.

## Cooldowns

- Les cooldowns sont comptés selon les **tours personnels** de l'utilisateur de la compétence.
- Les tours des alliés et des ennemis ne réduisent pas les cooldowns.
- Une compétence avec deux tours de recharge reste indisponible pendant les deux prochains tours personnels et revient au troisième.

## Attaque et compétences

- Cliquer sur Attaque ouvre la liste des compétences équipées.
- Chaque compétence affiche : nom, icône, coût en Essence, temps de recharge (sablier) et durée d'effet (chronomètre) si nécessaire.
- Une compétence trop chère ne peut pas être utilisée (validation serveur).
- Après sélection, elle lance son animation et éventuellement son QTE.
- Le nombre de compétences équipées reste ouvert.

## QTE offensif

- Barre horizontale avec une zone rouge et une zone jaune plus petite.
- Plusieurs curseurs se succèdent de gauche à droite avec un petit espacement ; le joueur clique pour arrêter chaque curseur.
- Chaque curseur arrêté reste visible (marqueur figé) à sa position jusqu'au résultat final.
- Le nombre de curseurs dépend de la compétence.
- Résultats :
  - tous les curseurs en zone jaune : **attaque parfaite**, bonus provisoire de **+20 % de dégâts** ;
  - aucun curseur hors zone et au maximum un curseur rouge : **attaque normale** ;
  - deux curseurs rouges ou plus : **attaque annulée** ;
  - un seul curseur complètement hors de la zone rouge : **attaque annulée immédiatement**.
- En cas d'annulation, les ressources et le tour restent consommés ; jouer une courte animation de déséquilibre ou d'échec.
- Les vitesses, espacements et tailles de zones doivent être configurables (profils par compétence).

## Défense universelle (QTE défensif)

Quand un ennemi attaque, un QTE défensif apparaît : **un seul curseur** traverse une longue barre, sa vitesse dépendant notamment du niveau de maîtrise de l'attaquant.

- **Zone rouge** : défense normale, **50 % des dégâts absorbés**. L'attaque touche le corps : les effets secondaires peuvent s'appliquer.
- **Zone jaune** : parade parfaite, aucun dégât et aucun effet secondaire.
- **Hors zone** : dégâts complets et effets secondaires applicables.
- Les dégâts partiels restent des nombres entiers ; pour le prototype, arrondir les dégâts restants **vers le haut**.
- Une attaque non totalement annulée inflige au minimum **1 dégât**.

## Action Garde

- Garde utilise tout le tour ; aucun QTE défensif pendant l'effet.
- Absorbe automatiquement **70 % des dégâts**.
- Les effets secondaires peuvent s'appliquer puisque le corps est touché.
- Dure jusqu'au prochain tour personnel.

## Méditer

- Utilise tout le tour ; donne **+2 Essence**.
- Le personnage conserve ses QTE défensifs.
- Applique un malus jusqu'au prochain tour personnel. Pendant ce malus :
  - la zone rouge n'absorbe plus que **30 %** des dégâts ;
  - Garde n'absorbe plus que **50 %** ;
  - la parade parfaite (jaune) reste inchangée.

## Parade parfaite, riposte et contre-parade

- Une parade parfaite peut déclencher une riposte si le défenseur en possède la capacité.
- La riposte utilise les dégâts de l'attaque de base (pour le prototype).
- L'attaquant reçoit un QTE spécial beaucoup plus difficile :
  - réussite : la riposte est complètement annulée ;
  - échec : la riposte inflige ses dégâts.
- Une contre-parade réussie termine l'échange et ne déclenche jamais une nouvelle riposte : il ne doit jamais exister de boucle infinie de ripostes.
- Aucun gain d'Essence dans cette séquence.
- Ennemis et joueurs suivent les mêmes principes lorsque leur anatomie et leurs capacités le permettent.

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
- L'Invocateur dispose d'une action universelle pour la relever : elle coûte **2 Essence** et consomme le tour entier.
- L'invocation revient avec **25 % de ses PV maximum**.
- Une même invocation ne peut être relevée qu'une seule fois par combat ; si elle retombe K.-O., elle reste indisponible jusqu'à un soin adapté ou au retour au village.
- Les invocations ne meurent jamais définitivement.

## Joueur K.-O. et Secourir

- Un joueur à 0 PV passe K.-O.
- En solo, atteindre 0 PV provoque immédiatement la défaite.
- En groupe, un allié vivant peut utiliser l'action universelle **Secourir** : elle coûte **2 Essence** et consomme tout son tour.
- Le joueur revient avec **15 % de ses PV maximum** et attend son prochain tour normal avant d'agir.
- Chaque joueur ne peut être relevé qu'une seule fois par combat ; s'il retombe à 0 PV pendant le même combat, il reste hors combat jusqu'à la fin.
- Un simple K.-O. relevé ne détruit aucun fragment d'âme.

## Système d'âme

- L'interface en bas à gauche affiche une icône d'âme divisée en **trois fragments**.
- Le personnage possède trois morts véritables possibles : une **défaite solo ou une défaite totale du groupe** détruit un fragment.
- Un K.-O. relevé pendant un combat n'est pas une mort véritable et ne détruit aucun fragment.
- Lorsque le troisième et dernier fragment disparaît, le personnage est supprimé définitivement (dans la version finale).
- Dans le prototype, cette destruction est **uniquement simulée** : aucun DataStore, aucune vraie suppression, et un bouton développeur permet de restaurer les fragments.
- Aucun mémorial des personnages morts ne doit être créé.
- À détailler plus tard : règles précises distinguant une défaite normale d'une mort véritable ; protection technique contre les morts causées par un bug serveur ou une déconnexion involontaire.

## Conséquences des défaites

### Deux premières défaites

- Retour au village.
- Perte de l'or transporté et du butin obtenu pendant l'expédition.
- Équipement conservé.
- L'or déjà sécurisé à la Banque reste conservé.

### Mort définitive

- Perte du personnage : domaines et niveaux de maîtrise, équipement, inventaire et progression personnelle.
- Perte du contenu de la Banque classique.
- Seul un objet stocké dans la Banque d'âme peut survivre.

## Objets

- Le menu Objet donne accès aux consommables disponibles.
- Deux potions au début de chaque combat (prototype) ; deux potions maximum par combat.
- Une potion soigne **7 PV** sans dépasser le maximum et consomme le tour.
- Aucun autre objet nécessaire dans le premier prototype ; les règles des autres objets seront définies plus tard.

## Fuite

- Consomme le tour ; peut être retentée dès le prochain tour personnel après un échec.
- Impossible contre un boss.
- Réussite : combat terminé sans récompense.
- Chance (provisoire) :
  - base de **50 %** ;
  - **±10 points** par point de différence de Clairvoyance, comparé au combattant ennemi vivant possédant la meilleure Clairvoyance ;
  - résultat limité entre **10 % et 90 %**.
- Exemples : Clairvoyance 5 contre Bandit 5 = 50 % ; Clairvoyance 5 contre Loup 7 = 30 %.

## Interface permanente

En bas à gauche : nom du personnage, niveau de maîtrise le plus élevé (max 12), barre verte et valeur de points de vie, Essence actuelle sur 6, or, cristaux bleus, icône d'âme (trois fragments).

### Cristaux bleus

- Servent à progresser dans les niveaux de domaine ; obtenus en vainquant des ennemis.
- Une créature du même niveau donne une quantité modérée ; un niveau supérieur (créature ou boss) donne un bonus de 50 %.
- Les coûts et quantités exacts restent à équilibrer.

## Banque

- Bâtiment physique dans le village, utilisable uniquement en revenant au village.
- Permet de déposer et retirer son or.
- L'or transporté sur le personnage reste exposé ; l'or déposé survit aux deux premières morts.
- Le contenu de la Banque classique disparaît à la mort définitive.

### Banque d'âme — plus tard

- Déblocage très coûteux ; un seul emplacement.
- Permet de conserver durablement un seul objet après la mort définitive ; le personnage suivant peut le récupérer.
- Tant que l'objet est stocké, le personnage actuel ne peut pas l'utiliser.
- Prix exact, objets autorisés et conditions de remplacement restent à définir.

## PvP — plus tard

- Le PvP n'est pas une priorité.
- Une liste de joueurs pourra être affichée/masquée en haut à droite, indiquant seulement le nom Roblox et le niveau de maîtrise le plus élevé.
- Cliquer sur un joueur permettra plus tard de l'inviter dans un groupe ou de lui proposer un duel.

## Kit Épéiste niveau 1 (provisoire)

**Statistiques** : PV maximum 30 ; Clairvoyance 5 ; Essence 0/6 au début.

- **Taille** (attaque de base) : coût 0 Essence, 3 dégâts, deux curseurs offensifs, aucun cooldown, donne +1 Essence si l'action n'est pas annulée.
- **Fente** : coût 2 Essence, 5 dégâts, trois curseurs offensifs, cooldown 2 tours personnels.
- **Entaille croisée** : coût 3 Essence, deux frappes de 3 dégâts, cooldown 3 tours personnels. Chaque frappe utilise une séquence séparée de deux curseurs et est calculée indépendamment ; l'échec de la deuxième ne supprime pas les dégâts de la première.
- **Posture du duelliste** : coût 2 Essence, cooldown 4 tours personnels, dure jusqu'au prochain tour personnel, agrandit de 50 % la zone jaune du prochain QTE défensif, aucun dégât.

## Créatures de test (provisoire)

### Loup gris niveau 1

- PV maximum 16 ; Clairvoyance 7 ; rapide et agressif.
- Ne peut pas effectuer de parade armée ; peut utiliser une esquive adaptée à son anatomie.
- **Morsure** : 3 dégâts, aucun cooldown, QTE défensif normal.
- **Bond** : 5 dégâts, cooldown 2 tours personnels, QTE plus rapide que Morsure ; l'IA préfère Bond lorsqu'il est disponible.

### Bandit égaré niveau 1

- PV maximum 22 ; Clairvoyance 5 ; peut défendre, garder, parer parfaitement, riposter et contre-parer.
- **Coup d'épée** : 4 dégâts, aucun cooldown.
- **Frappe lourde** : 7 dégâts, cooldown 3 tours personnels, QTE défensif plus rapide, aucun avertissement avant son tour.
- **Garde** : même principe que la Garde du joueur (70 % d'absorption).

## Défense contrôlée par l'IA

- Ne pas utiliser un pourcentage global arbitraire identique pour tous : créer des profils de défense configurables.
- Le calcul doit considérer : le niveau ou score de maîtrise ; le type de créature ; les défenses anatomiquement autorisées ; l'état actuel ; la difficulté de l'attaque reçue ; une variation aléatoire contrôlée.
- Toutes les constantes restent dans des modules de configuration.
- Le Loup utilise esquive ou défense naturelle ; le Bandit utilise blocage, parade parfaite, riposte et contre-parade.

## Points encore ouverts

- Effets précis des statistiques de départ (autres que Clairvoyance et PV du prototype).
- Nombre de compétences équipables selon la maîtrise.
- QTE propres à chaque domaine (au-delà de l'Épéiste).
- Règles finales d'équilibrage de la fuite, des cristaux et des récompenses.
- Dégâts et effets définitifs de la riposte.
- Fonctionnement détaillé des bâtiments.
- Progression exacte entre les niveaux 1 et 12.
- Liste complète des créatures de la première région.
- Règles finales des effets secondaires pendant l'action Garde.
- Règles distinguant une défaite normale d'une mort véritable, et protection contre les morts par bug ou déconnexion.
- Lien bestial / état Enragé pour l'Invocateur.
- Banque d'âme : prix, objets autorisés, conditions de remplacement.
