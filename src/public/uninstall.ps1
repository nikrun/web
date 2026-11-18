param (
    [switch]$Purge,
    [switch]$KeepData,
    [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"

$UserHome = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }
$NikrunHome = if (-not [string]::IsNullOrWhiteSpace($env:NIKRUN_HOME)) {
    [System.IO.Path]::GetFullPath($env:NIKRUN_HOME.Trim())
} else {
    Join-Path $UserHome ".nikrun"
}
$InstallDir = Join-Path $NikrunHome "bin"
$ExePath = Join-Path $InstallDir "nik.exe"
$DeleteExePath = Join-Path $InstallDir "nik.delete.exe"
$LocalUninstallPath = Join-Path $NikrunHome "uninstall.ps1"

Write-Host "Uninstalling Nikrun CLI..."

# 1. Stop running nik processes and remove binary (renaming first breaks IDE LSP restart loops)
if (Test-Path $ExePath) {
    try {
        Remove-Item -Path $DeleteExePath -Force -ErrorAction SilentlyContinue
        Rename-Item -Path $ExePath -NewName "nik.delete.exe" -Force -ErrorAction SilentlyContinue
    } catch {}
}

$CurrentPid = $PID
$Running = Get-Process -Name "nik" -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $CurrentPid }
if ($Running) {
    Write-Host "Stopping running nik instances..."
    $Running | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 600
}

foreach ($BinCandidate in @($ExePath, $DeleteExePath, (Join-Path $InstallDir "nik.exe.old"))) {
    if (Test-Path $BinCandidate) {
        Remove-Item -Path $BinCandidate -Force -ErrorAction SilentlyContinue
    }
}

if (Test-Path $InstallDir) {
    $RemainingInBin = @(Get-ChildItem -Path $InstallDir -Force -ErrorAction SilentlyContinue)
    if ($RemainingInBin.Count -eq 0) {
        Remove-Item -Path $InstallDir -Force -ErrorAction SilentlyContinue
    }
}

# 2. Remove ~/.nikrun/bin from User PATH
$NormalizedInstallDir = $InstallDir.TrimEnd('\')
$RawUserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if (-not [string]::IsNullOrWhiteSpace($RawUserPath)) {
    $FilteredEntries = @(
        $RawUserPath -split ';' | Where-Object {
            (-not [string]::IsNullOrWhiteSpace($_)) -and ($_.Trim().TrimEnd('\') -ine $NormalizedInstallDir)
        }
    )
    $NewUserPath = $FilteredEntries -join ';'
    if ($NewUserPath -ne $RawUserPath) {
        [Environment]::SetEnvironmentVariable("PATH", $NewUserPath, "User")
        Write-Host "Removed $InstallDir from User PATH."
    }
}

# 3. Remove Windows Installed Apps Registry entry
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Nikrun CLI"
if (Test-Path $RegPath) {
    Remove-Item -Path $RegPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Removed Nikrun CLI entry from Windows Installed Apps."
}

# 4. Ask user whether to also remove SDKs, cache, and user config inside ~/.nikrun
if (Test-Path $NikrunHome) {
    $OtherItems = @(
        Get-ChildItem -Path $NikrunHome -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -notin @("uninstall.ps1", "uninstall.sh") }
    )

    $RemoveAll = $false
    if ($OtherItems.Count -eq 0) {
        # Only the local uninstaller script remains — remove directory cleanly without prompting
        $RemoveAll = $true
    } elseif ($Purge) {
        $RemoveAll = $true
    } elseif ($KeepData) {
        $RemoveAll = $false
    } elseif (-not $NonInteractive -and [Environment]::UserInteractive) {
        $ItemNames = ($OtherItems | Select-Object -ExpandProperty Name) -join ", "
        Write-Host ""
        Write-Host "Additional toolchain data found in ${NikrunHome}: $ItemNames" -ForegroundColor Yellow
        $Answer = Read-Host "Also remove installed Free Pascal SDKs, cache, and config in '$NikrunHome'? [y/N]"
        if ($Answer -match '^(y|yes|j|ja)$') {
            $RemoveAll = $true
        }
    }

    if ($RemoveAll) {
        # Note: if running from $LocalUninstallPath itself, PowerShell already loaded the script into memory
        Remove-Item -Path $NikrunHome -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Removed $NikrunHome completely."
    } else {
        if (Test-Path $LocalUninstallPath) {
            Remove-Item -Path $LocalUninstallPath -Force -ErrorAction SilentlyContinue
        }
        Write-Host "Kept SDKs and user data in $NikrunHome."
    }
}

Write-Host ""
Write-Host "Nikrun CLI has been uninstalled. Restart open terminals for PATH changes to take effect." -ForegroundColor Green
