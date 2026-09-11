# A3UE - Extended Ranks

Recovered source for Workshop item `3711728487`. Adds 16 player ranks and insignias, promotion notifications, persistent ranks, AI ranks, and rank-aware player UI to Antistasi Ultimate.
This is a fork of [A3AExtender](https://github.com/official-antistasi-community/A3AExtender) made by [Antistasi Official Community Arma 3](https://github.com/official-antistasi-community)

# Requirements
  - Arma 3
  - Arma 3 Tools
    
  Arma 3 and Arma 3 Tools need to be run once from steam.

  ## Useful Things

  - [Advanced Developer Tools](https://steamcommunity.com/sharedfiles/filedetails/?id=2369477168)
  - https://paa.gruppe-adler.de/ (Image > PAA. If converting multiple files, use `ImageToPAA` included in Arma 3 Tools)

  - Ability to debug.
  The ability to debug is acquired with experience. A good thing to remember is:

  `"If you can't un-break the code you broke, it isn't code. It's a bunch of useless characters."` - Silence

# How to build

The recovered source is already prepared. `Install.ps1` and `Tools/Builder/firstTimeSetup.ps1` are retained for reference/reuse; do not rerun setup on this source, because it renames the mod and rewrites its namespace headers.

### .ps1 Method

Run from the project root:

```powershell
.\Build.ps1
```

If the local execution policy blocks scripts, use a process-only invocation:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Build.ps1
```

The original builder discovers the mod and addon folder names. It recreates `build/` and packs `core.pbo` and `functions.pbo` into `build/A3UE/addons`, with launcher/Workshop metadata and an empty `Keys` folder. Every rebuild deletes previous build output, including signatures and copied keys. Sign again after rebuilding.

### Visual Studio Code Method

Use [Arma Dev](https://marketplace.visualstudio.com/items?itemName=ole1986.arma-dev) with the local `.vscode/arma-dev.json`. It includes both addons, version `1.0.0`, `build/` output, and the external signing key. The configuration points at `C:/Program Files (x86)/Steam`, where Arma 3 Tools are installed on this machine; adjust that setting on another machine.

Run `Arma 3: Build`. The extension adds its own `@` prefix, producing `build/@a3ueExtendedRanks/`. It signs using `../SigningKeys/a3ueExtendedRanks.biprivatekey`. Copy the public key and verify signatures as described below. Arma Dev generates its own launcher metadata; use the PowerShell build when packaging the preserved published `mod.cpp` and `meta.cpp`.

The editor configuration is ignored by Git as before. Choose one build method for a release; a PowerShell rebuild clears both methods' output under `build/`.

## Recovered source

- `A3UE/addons/functions/Ranks/fn_getRankData.sqf`: rank IDs, score thresholds, engine rank mapping, and insignia paths.
- `A3UE/addons/core/Stringtable.xml` and `A3UE/addons/core/images/*.paa`: rank names and the 16 recovered game textures.
- `A3UE/addons/functions/cfgFunctions.hpp`: 14 A3A overrides, one SCRT override, and 24 custom functions.
- `A3UE/addons/core/Includes/script_version.hpp`: version reset from the published `10.3.1.0` to `1.0.0.0`.

The virtual namespace remains `x\a3ue_extended_ranks\addons`. Rank thresholds, AI distributions, and the `custom_v2` save schema are unchanged. The recovered undercover status helper was corrected to retain vehicle/compromised-player rejections and return `[allowed, explanation]` to the player tab, including equipment rejection tooltips. Its eligibility rules are unchanged.

The original PAA files are intact; original layered artwork was not in the published mod. Unused example addons and the unreferenced `cba_settings.sqf` and `performance.inc` helpers were removed. All development tools, including DSSignFile and StreetArtist, are retained.

## In-game checks

Load the chosen build folder with Antistasi Ultimate and CBA_A3. After source/build validation, separately test promotions, legacy and current saves, persistent-save completion, reconnect/JIP, respawn, commander transfer, player/AI tags, rank pictures, and undercover button/tooltips. Inspect client and server RPT logs. Config, archive, and signature checks do not establish in-game compatibility.

# Extending the mod

- Note: If dealing with file paths, always use the correct macros UNLESS you can't due to it being in another mod.

  - Macros are essentially a function in how they work - these ones in particular append your parameter to a predefined path.

    - The benefit of this is that you only have to change this path once (if you need to change it at all.)

  - Some relevant macros for paths are `QPATHTOFOLDER`, `QCPATHTO`, etc.

## Functionality

- Antistasi now has events that you can listen to and extend existing functionality.
  A list of all events and their parameters can be found in the in game config under: `A3A >> Events`.
- In addition you can overwrite any of Antistasi's functions to add, change or remove functionality. This includes full systems (be aware that this is more complex and can break on updates).
  Register overrides under `A3A` or `SCRT`, and extension functions under `a3ue_extended_ranks`, in `A3UE/addons/functions/cfgFunctions.hpp`.

# Signing and releasing

The new signing identity is `a3ueExtendedRanks`. Its private and public keys are stored outside the project in `D:\Mods\A3\SigningKeys`. Only the public key is copied to `A3UE/Keys` and release output. This identity replaces the old published key; server administrators must trust the new public key for these builds.

The key is generated once with the preserved tools. Do not regenerate it for each build or overwrite an existing pair. For a fresh setup only, run from the project root:

```powershell
$signingTools = Join-Path (Get-Location).Path 'Tools\DSSignFile'
$keyDirectory = 'D:\Mods\A3\SigningKeys'
$privateKey = Join-Path $keyDirectory 'a3ueExtendedRanks.biprivatekey'
$publicKey = Join-Path $keyDirectory 'a3ueExtendedRanks.bikey'
if ((Test-Path -LiteralPath $privateKey) -or (Test-Path -LiteralPath $publicKey)) {
    throw 'Signing identity already exists. Reuse it; do not regenerate it.'
}
New-Item -ItemType Directory -Path $keyDirectory -Force | Out-Null
Push-Location $keyDirectory
try {
    & (Join-Path $signingTools 'DSCreateKey.exe') a3ueExtendedRanks
    if ($LASTEXITCODE -ne 0) { throw 'Key generation failed.' }
} finally { Pop-Location }
New-Item -ItemType Directory -Path A3UE/Keys -Force | Out-Null
Copy-Item -LiteralPath $publicKey -Destination A3UE/Keys
```

After each PowerShell build, sign and verify from the project root:

```powershell
$modOutput = 'build/A3UE' # For Arma Dev output, use 'build/@a3ueExtendedRanks'.
$privateKey = 'D:\Mods\A3\SigningKeys\a3ueExtendedRanks.biprivatekey'
$publicKey = 'D:\Mods\A3\SigningKeys\a3ueExtendedRanks.bikey'
foreach ($pbo in Get-ChildItem -LiteralPath "$modOutput/addons" -Filter '*.pbo' -File) {
    & .\Tools\DSSignFile\DSSignFile.exe $privateKey $pbo.FullName
    if ($LASTEXITCODE -ne 0) { throw "Signing failed: $($pbo.Name)" }
}
New-Item -ItemType Directory -Path "$modOutput/Keys" -Force | Out-Null
Copy-Item -LiteralPath $publicKey -Destination "$modOutput/Keys" -Force
& .\Tools\DSSignFile\DSCheckSignatures.exe "$modOutput/addons" "$modOutput/Keys"
if ($LASTEXITCODE -ne 0) { throw 'Signature verification failed.' }
```

Arma Dev signs during its build when the configured key exists; the same verification commands apply. Distribute the PBOs, their `.bisign` files, and the public `.bikey`. Never distribute the private key. Preserve Workshop ID `3711728487` when publishing updates to the existing item. Building and signing do not publish anything.

## Small disclaimer:

When you want other Antistasi players to easily find your extension, give it a descriptive name including the abbreviation `A3UE` like for example `A3UE - My Awesome Antistasi Ultimate Extension`.

## Need more advice?

Read the [Developer Advice](https://github.com/Westalgie/A3UExtender/wiki/Developer-Advice) page.
