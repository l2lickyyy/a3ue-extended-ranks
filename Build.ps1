[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$PrivateKeyPath
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$workspace = [IO.Path]::GetFullPath($PSScriptRoot)
$source = Join-Path $workspace 'a3ue_extended_ranks'
$output = Join-Path $workspace 'build\a3ue_extended_ranks'
$authority = 'a3ueExtendedRanks'
$privateKey = (Resolve-Path -LiteralPath $PrivateKeyPath).Path
if (!(Test-Path -LiteralPath $privateKey -PathType Leaf) -or [IO.Path]::GetExtension($privateKey) -cne '.biprivatekey') { throw 'Supply an existing .biprivatekey file.' }
$publicKey = [IO.Path]::ChangeExtension($privateKey, '.bikey')
if (!(Test-Path -LiteralPath $publicKey -PathType Leaf)) { throw "Public key missing: $publicKey" }
if ([IO.Path]::GetFileNameWithoutExtension($privateKey) -cne $authority) { throw "Expected signing authority $authority" }
if ($privateKey.StartsWith($workspace + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Keep the private key outside the repository.' }

$versionHeader = Get-Content -LiteralPath (Join-Path $source 'addons\core\Includes\script_version.hpp') -Raw
$versionParts = foreach ($part in @('MAJOR', 'MINOR', 'PATCHLVL')) {
    $definition = [regex]::Match($versionHeader, "(?m)^#define\s+$part\s+(\d+)\s*$")
    if (!$definition.Success) { throw "Missing release version component: $part" }
    $definition.Groups[1].Value
}
$version = $versionParts -join '.'

function Invoke-Checked {
    param([string]$Executable, [string[]]$Arguments)
    & $Executable @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Executable failed with exit code $LASTEXITCODE" }
}
Push-Location $workspace
try {
    # Only this fixed output directory can be replaced.
    if (!$output.StartsWith((Join-Path $workspace 'build') + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid build directory.' }
    foreach ($buildPath in @((Join-Path $workspace 'build'), $output)) {
        if ((Test-Path -LiteralPath $buildPath) -and ((Get-Item -LiteralPath $buildPath).Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            throw "Refusing build cleanup through a reparse point: $buildPath"
        }
    }
    # Reject links inside the output before recursive cleanup as well.
    $pending = New-Object 'System.Collections.Generic.Stack[string]'
    if (Test-Path -LiteralPath $output) { $pending.Push($output) }
    while ($pending.Count -gt 0) {
        foreach ($entry in (Get-ChildItem -LiteralPath $pending.Pop() -Force)) {
            if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Refusing cleanup of linked build entry: $($entry.FullName)" }
            if ($entry.PSIsContainer) { $pending.Push($entry.FullName) }
        }
    }
    foreach ($recordName in @('release-manifest.json', 'validation.md')) {
        $recordPath = Join-Path $workspace "build\$recordName"
        if (Test-Path -LiteralPath $recordPath) {
            if ((Get-Item -LiteralPath $recordPath).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Refusing a linked build record: $recordPath" }
            Remove-Item -LiteralPath $recordPath
        }
    }
    if (Test-Path -LiteralPath $output) { Remove-Item -LiteralPath $output -Recurse }
    New-Item -ItemType Directory -Path (Join-Path $output 'addons'), (Join-Path $output 'keys') | Out-Null
    $releaseFiles = @("keys/$authority.bikey", 'mod.cpp', 'meta.cpp')
    foreach ($addon in @('core', 'functions')) {
        $pbo = Join-Path $output "addons\$addon.pbo"
        Invoke-Checked (Join-Path $workspace 'Tools\Builder\hemtt.exe') @('armake', 'pack', (Join-Path $source "addons\$addon"), $pbo)
        Invoke-Checked (Join-Path $workspace 'Tools\DSSignFile\DSSignFile.exe') @($privateKey, $pbo)
        $releaseFiles += "addons/$addon.pbo", "addons/$addon.pbo.$authority.bisign"
    }
    Copy-Item -LiteralPath $publicKey -Destination (Join-Path $output "keys\$authority.bikey")
    Copy-Item -LiteralPath (Join-Path $source 'mod.cpp'), (Join-Path $source 'meta.cpp') -Destination $output
    $hashes = [ordered]@{}
    foreach ($relativePath in ($releaseFiles | Sort-Object)) {
        $hashes[$relativePath] = (Get-FileHash -LiteralPath (Join-Path $output $relativePath) -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    $manifest = [ordered]@{
        version = $version
        workshopId = '3711728487'
        authority = $authority
        testsRun = $false
        verificationRun = $false
        files = $hashes
    }
    $manifestJson = ($manifest | ConvertTo-Json -Depth 4).Replace("`r`n", "`n") + "`n"
    [IO.File]::WriteAllText((Join-Path $workspace 'build\release-manifest.json'), $manifestJson, [Text.UTF8Encoding]::new($false))
    Write-Output "Built and signed ${version}: $output"
    Write-Output 'SHA-256 manifest: build\release-manifest.json. Tests and verification were not run.'
} finally {
    Pop-Location
}
