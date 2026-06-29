# Prototype de combat — Lancement (Lot 01 : fondation)

Ce document explique comment synchroniser et lancer la **fondation** du prototype
de combat. Aucun système de combat n'est encore implémenté à ce stade : on vérifie
seulement que la structure Rojo se synchronise et que la zone de test apparaît.

## Prérequis

- [Roblox Studio](https://create.roblox.com/) installé.
- [Rojo](https://rojo.space/) (CLI 7.x) et/ou le plugin Rojo pour Studio.

Aucune dépendance privée ou payante n'est requise.

## Arborescence

```
default.project.json          # mapping Rojo
src/
  shared/                     # → ReplicatedStorage.Shared
    Config/                   # configuration centralisée (ModuleScripts)
      init.lua                #   agrégateur : Config.Combat / Essence / Epeiste / Creatures
      CombatConfig.lua
      EssenceConfig.lua
      EpeisteConfig.lua
      CreaturesConfig.lua
    Types/                    # types Luau de base du combat
      init.lua
    Remotes/                  # RemoteEvents/Functions réservés (vides)
      init.lua
  server/                     # → ServerScriptService.Server (Script)
    init.server.lua           #   init des remotes + génération de la zone de test
    TestZone.lua              #   construction par code de la zone + déclencheurs
  client/                     # → StarterPlayerScripts.Client (LocalScript)
    init.client.lua           #   client minimal (log uniquement)
```

## Mapping Rojo

`default.project.json` mappe :

- `src/shared` → `ReplicatedStorage.Shared`
- `src/server` → `ServerScriptService.Server`
- `src/client` → `StarterPlayer.StarterPlayerScripts.Client`

## Lancer

1. À la racine du dépôt, démarrer le serveur Rojo :

   ```bash
   rojo serve
   ```

2. Dans Roblox Studio, ouvrir un nouveau lieu (Baseplate), puis via le plugin
   Rojo cliquer sur **Connect**.

3. Lancer une session **Play** (F5).

## Résultat attendu

- Dans le `Workspace`, un modèle `CombatTestZone` contenant un sol et deux parties
  néon nommées **`Loup`** et **`Bandit`**, chacune surmontée d'une étiquette.
- Sortie console serveur :
  `[Server] Fondation du prototype de combat prête (zone de test générée).`
- Sortie console client :
  `[Client] Fondation prête (Essence max = 6, durée du tour = 20s).`
- En cliquant sur un déclencheur, un log serveur s'affiche, par exemple :
  `[TestZone] Déclencheur « Loup » activé par <Joueur> (aucun combat : fondation).`

## Limites de ce lot

- Aucune mécanique de combat, QTE, Essence, UI, monde, groupe ou sauvegarde.
- Aucun DataStore.
- Les déclencheurs ne font qu'imprimer un log : la logique viendra dans les lots suivants.

> Note : cette fondation n'a **pas** pu être testée dans Roblox Studio depuis cet
> environnement (pas d'accès à Studio). La cohérence des chemins Rojo et des scripts
> a été vérifiée par relecture uniquement.
