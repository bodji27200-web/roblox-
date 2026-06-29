--!strict
-- UIConfig
-- Lot 03 — Configuration de l'interface de combat (valeurs d'affichage et tailles).
-- Aucune logique : uniquement des données centralisées et configurables pour l'UI.
-- L'UI lit l'état exposé par le serveur (lot 02) ; ce module ne décrit que l'apparence
-- et les libellés (en français). Les valeurs peuvent être rééquilibrées librement.

local UIConfig = {
	-- Nombre de fragments d'âme affichés dans le HUD (voir docs/design-decisions.md).
	SOUL_FRAGMENTS = 3,

	-- Niveau de maîtrise affiché par défaut (prototype : maîtrise niveau 1).
	DEFAULT_MASTERY_LEVEL = 1,

	-- Palette de couleurs (placeholder, non définitif visuellement).
	Palette = {
		Background = Color3.fromRGB(20, 22, 30),
		Panel = Color3.fromRGB(30, 33, 44),
		PanelBorder = Color3.fromRGB(70, 76, 96),
		Text = Color3.fromRGB(236, 238, 245),
		TextMuted = Color3.fromRGB(160, 166, 184),
		Accent = Color3.fromRGB(120, 170, 255),

		HpFill = Color3.fromRGB(210, 70, 70),
		HpBackground = Color3.fromRGB(60, 30, 30),

		EssenceFilled = Color3.fromRGB(120, 200, 255),
		EssenceEmpty = Color3.fromRGB(55, 62, 80),

		SoulFilled = Color3.fromRGB(200, 170, 255),
		SoulEmpty = Color3.fromRGB(55, 50, 70),

		Gold = Color3.fromRGB(240, 205, 110),
		Crystal = Color3.fromRGB(150, 230, 230),

		ButtonEnabled = Color3.fromRGB(45, 52, 70),
		ButtonDisabled = Color3.fromRGB(34, 37, 47),
		ButtonHover = Color3.fromRGB(60, 70, 95),
		ButtonSelected = Color3.fromRGB(90, 120, 180),

		CurrentTurn = Color3.fromRGB(120, 170, 255),
		EnemyTurn = Color3.fromRGB(210, 110, 110),
	},

	-- Tailles et marges (en pixels « offset » sauf indication ; on combine avec des
	-- échelles relatives pour rester lisible sur toutes les résolutions).
	Layout = {
		Margin = 12,
		CornerRadius = 8,
		BorderThickness = 1,

		-- HUD bas gauche.
		HudWidth = 320,
		HudMinWidth = 240,
		HudHeight = 188,

		-- Menu d'actions à droite.
		MenuWidth = 220,
		MenuMinWidth = 170,
		MenuButtonHeight = 44,
		MenuButtonSpacing = 8,

		-- Ordre des tours en haut.
		TurnOrderHeight = 52,
		TurnChipMinWidth = 96,

		-- Zone centrale.
		CenterWidthScale = 0.42, -- proportion de la largeur de l'écran
		CenterHeightScale = 0.30,
		MaxMessages = 6,
	},

	-- Polices.
	Fonts = {
		Title = Enum.Font.GothamBold,
		Body = Enum.Font.Gotham,
		Value = Enum.Font.GothamMedium,
	},

	-- Libellés français centralisés (facilite la relecture et la cohérence).
	Labels = {
		Mastery = "Maîtrise niv. %d",
		HpValue = "%d / %d",
		EssenceValue = "%d/%d",
		Gold = "Or",
		Crystals = "Cristaux",
		SoulFragments = "Fragments d'âme",
		TurnOrderTitle = "Ordre des tours",
		WaitingState = "En attente de combat…",
		QtePlaceholder = "[ Emplacement QTE ]",
		ChooseAction = "Choisissez votre action.",
		NoCombat = "Aucun combat en cours.",
		-- Lot 04 — Affichage des coûts, du sablier (recharge) et du chronomètre.
		EssenceCost = "%d ✦", -- coût en Essence d'une action
		Cooldown = "⌛ %d", -- recharge restante, en tours personnels
		TurnTimer = "⏱ %ds", -- chronomètre du tour personnel
	},

	-- Les cinq actions du menu de droite. L'id est la valeur envoyée au serveur
	-- (doit rester cohérent avec le moteur du lot 02 : « Garde » et « Fuite »).
	Actions = {
		{ id = "Attaque", label = "Attaque", key = Enum.KeyCode.One },
		{ id = "Objet", label = "Objet", key = Enum.KeyCode.Two },
		{ id = "Garde", label = "Garde", key = Enum.KeyCode.Three },
		{ id = "Méditer", label = "Méditer", key = Enum.KeyCode.Four },
		{ id = "Fuite", label = "S'échapper", key = Enum.KeyCode.Five },
	},
}

return UIConfig
