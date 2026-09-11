param (
    [string]$modFileName = "mod.cpp",
    [string]$metaFileName = "meta.cpp"
)

#find witch folder is the modfolder
$folders = Get-Childitem "$PSScriptRoot\..\.." -Directory
foreach ($folder in $folders) {
    $folderName = $folder.Name
    $subFolders = Get-Childitem "$PSScriptRoot\..\..\$folderName" -Directory
    $subFolders = $subFolders | Where-Object { $_.Name -eq "addons" }
    if (($subFolders | Measure-Object).Count -gt 0) {
        $addonName = $folderName
        break
    }
}

#replace this with the modfolder name
#$addonName = "A3AE" # this is automated in the code block above
"Meta file name: $metaFileName`n`n"

Push-Location
try {
Set-Location "$PSScriptRoot\..\..\$addonName"

"`n`nSetup temporary directories..."
$projectRoot = (Resolve-Path -LiteralPath "$PSScriptRoot\..\..").Path
$buildRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot "build"))
if ($buildRoot -ne "$projectRoot\build") { throw "Build cleanup target is outside the project." }
if (Test-Path -LiteralPath $buildRoot) {
    $buildItem = Get-Item -LiteralPath $buildRoot -Force
    if ($buildItem.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw "Build cleanup target must not be a link or junction."
    }
    Remove-Item -LiteralPath $buildRoot -Recurse -Force -ErrorAction Stop
}
New-Item -Path "..\build" -ItemType Directory -Force > $null
New-Item -Path "..\build\$addonName" -ItemType Directory -Force > $null
New-Item -Path "..\build\$addonName\addons" -ItemType Directory -Force > $null
New-Item -Path "..\build\$addonName\Keys" -ItemType Directory -Force > $null

$addonLocation = "." # We are here already
$addonOutLocation = "$PSScriptRoot\..\..\build\$addonName"
$addonsOutLocation = "$addonOutLocation\addons"

"`nBuild addons..."
$modules = Get-Childitem "$addonLocation\addons" -Directory
foreach ($module in $modules) {
    $pboName = "$($module.Name).pbo"
    #"Building $pboName...  $addonLocation\addons\$($module.Name)   -> $addonsOutLocation\$pboName"
    "Building $pboName ..."
    .$PSScriptRoot\hemtt armake pack --force $module.fullName "$addonsOutLocation\$pboName"
    if ($LASTEXITCODE -ne 0) {
        throw "Packing $pboName failed with exit code $LASTEXITCODE."
    }
}

"`nCopy mod.cpp..."
Copy-Item "$modFileName" $addonOutLocation
Push-Location
Set-Location $addonOutLocation
Rename-Item $modFileName "mod.cpp"
Pop-Location

"`nCopy meta.cpp..."
Copy-Item "meta\$metaFileName" $addonOutLocation
Push-Location
Set-Location $addonOutLocation
Rename-Item $metaFileName "meta.cpp"
Pop-Location

} finally {
Pop-Location
}

$displayTime = Get-Date -DisplayHint DateTime
"Antistasi builder ran at: $displayTime"
