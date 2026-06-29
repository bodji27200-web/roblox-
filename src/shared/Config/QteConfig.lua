--!strict
-- QteConfig
-- Lot 05 — Profils configurables du QTE offensif (données seulement, aucune logique).
-- Tout est centralisé ici : nombre de curseurs, vitesse, espacement et géométrie des
-- zones (rouge large, jaune plus petite). Un profil est associé à une action/compétence
-- via `ProfileByAction` ; les kits ultérieurs (Épéiste, lot 07) ajouteront leurs propres
-- profils sans toucher au moteur du QTE.
--
-- Géométrie d'un profil (barre horizontale normalisée [0, 1]) :
--   * `center`          : centre des zones (0..1).
--   * `yellowHalfWidth` : demi-largeur de la zone jaune (parfaite).
--   * `redHalfWidth`    : demi-largeur de la zone rouge (toujours > jaune).
--   * au-delà de la zone rouge : « hors zone » (annulation).
--
-- Le bonus de l'attaque parfaite (+20 %) reste la source unique dans
-- `CombatConfig.PERFECT_ATTACK_DAMAGE_BONUS` : on ne le duplique pas ici.

local QteConfig = {
	-- Dégâts de base provisoires de l'attaque offensive du prototype. Le QTE applique
	-- ensuite le multiplicateur (1.0 normal, 1.2 parfait, 0 si annulée). Provisoire :
	-- les dégâts réels par compétence arriveront avec le kit Épéiste (lot 07).
	BASE_ATTACK_DAMAGE = 4,

	-- Outil développeur : multiplicateur de vitesse appliqué côté client pour
	-- ralentir (<1) ou accélérer (>1) le QTE pendant les tests. La vitesse n'influe
	-- pas sur le résultat (calculé à partir des positions), donc l'outil reste sûr.
	Dev = {
		DEFAULT_SPEED_MULTIPLIER = 1,
		MIN_SPEED_MULTIPLIER = 0.1,
		MAX_SPEED_MULTIPLIER = 5,
	},

	-- Profils de QTE offensif (réutilisables). La zone jaune est toujours plus petite
	-- que la zone rouge ; le curseur traverse la barre en `cursorSeconds` secondes.
	Profiles = {
		-- Attaque de base : deux curseurs, rythme modéré.
		AttaqueStandard = {
			cursorCount = 2,
			center = 0.5,
			yellowHalfWidth = 0.10, -- zone jaune : largeur 0.20
			redHalfWidth = 0.25, -- zone rouge : largeur 0.50 (plus grande que la jaune)
			cursorSeconds = 1.4, -- temps pour traverser toute la barre
			spacingSeconds = 0.25, -- petit espacement entre deux curseurs
		},
		-- Variante à trois curseurs (sert aux tests « 2 et 3 curseurs »).
		AttaqueLongue = {
			cursorCount = 3,
			center = 0.5,
			yellowHalfWidth = 0.09,
			redHalfWidth = 0.24,
			cursorSeconds = 1.2,
			spacingSeconds = 0.25,
		},
	},

	-- Association action -> profil. Pour tester un QTE à 3 curseurs sans toucher au
	-- moteur, il suffit de pointer « Attaque » vers « AttaqueLongue » ici (les deux
	-- côtés, client et serveur, lisent cette même table : aucun risque de désync).
	ProfileByAction = {
		Attaque = "AttaqueStandard",
	},
}

return QteConfig
