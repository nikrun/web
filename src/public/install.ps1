param (
    [ValidateSet("stable", "insider")]
    [string]$Channel = $(if ($env:NIKRUN_CHANNEL) { $env:NIKRUN_CHANNEL } else { "stable" }),
    [string]$Version = $(if ($env:NIKRUN_VERSION) { $env:NIKRUN_VERSION } else { "" })
)

$ErrorActionPreference = "Stop"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
} catch {}

$Repo = "nikrun/cli"
$SiteBaseUrl = "https://nikrun.dev"
$RawFallbackBaseUrl = "https://raw.githubusercontent.com/nikrun/web/main/src/public"

# 1. Resolve native Windows host architecture (handles x64 PowerShell running under ARM64 emulation)
$IsArm64 = $false
try {
    $OsArch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
    if ($OsArch -eq "Arm64") {
        $IsArm64 = $true
    }
} catch {}

if (-not $IsArm64) {
    if ($env:PROCESSOR_ARCHITEW6432 -match "ARM64" -or $env:PROCESSOR_ARCHITECTURE -match "ARM64") {
        $IsArm64 = $true
    }
}

$Cpu = if ($IsArm64) { "aarch64" } else { "x86_64" }
$Triplet = "$Cpu-win64"

# 2. Query GitHub Releases API for nikrun/cli
$Headers = @{
    "Accept"     = "application/vnd.github+json"
    "User-Agent" = "nikrun-installer"
}
$AuthToken = if ($env:GITHUB_TOKEN) { $env:GITHUB_TOKEN } elseif ($env:GH_TOKEN) { $env:GH_TOKEN } else { "" }
if ($AuthToken) {
    $Headers["Authorization"] = "Bearer $AuthToken"
}

Write-Host "Resolving Nikrun CLI release ($Channel channel, $Triplet)..."
$Release = $null

try {
    if (-not [string]::IsNullOrWhiteSpace($Version)) {
        $TrimmedVer = $Version.Trim()
        try {
            $Release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/tags/$TrimmedVer" -Headers $Headers -UseBasicParsing
        } catch {
            $NormalizedPrefix = "v" + ($TrimmedVer -replace '^v', '')
            $AllReleases = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases?per_page=100" -Headers $Headers -UseBasicParsing
            $Release = $AllReleases | Where-Object {
                (-not $_.draft) -and (
                    $_.tag_name -eq $TrimmedVer -or
                    $_.tag_name -eq $NormalizedPrefix -or
                    $_.tag_name.StartsWith("$NormalizedPrefix-")
                )
            } | Select-Object -First 1
        }

        if (-not $Release) {
            throw "Release version '$Version' was not found in github.com/$Repo/releases."
        }
    } elseif ($Channel -eq "stable") {
        $Release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" -Headers $Headers -UseBasicParsing
    } else {
        $AllReleases = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases?per_page=50" -Headers $Headers -UseBasicParsing
        $Release = $AllReleases | Where-Object { (-not $_.draft) -and $_.prerelease } | Select-Object -First 1
        if (-not $Release) {
            throw "No insider prerelease found in github.com/$Repo/releases."
        }
    }
} catch {
    Write-Error "Failed to query Nikrun CLI releases from GitHub: $($_.Exception.Message)"
    exit 1
}

$ReleaseTag = $Release.tag_name
$Assets = @($Release.assets)

# 3. Resolve platform archive URL & expected SHA-256 from release manifest.json
$ExpectedSha256 = $null
$AssetName = "nik-$ReleaseTag-$Triplet.zip"
$DownloadUrl = $null

$ManifestAsset = $Assets | Where-Object { $_.name -eq "manifest.json" } | Select-Object -First 1
if ($ManifestAsset) {
    $Manifest = Invoke-RestMethod -Uri $ManifestAsset.browser_download_url -Headers $Headers -UseBasicParsing
    $NikNode = $Manifest.nik
    if ($NikNode -and $NikNode.downloads) {
        $TargetInfo = $NikNode.downloads.$Triplet
        if ($TargetInfo) {
            if ($TargetInfo -is [string]) {
                $AssetName = $TargetInfo
            } else {
                if ($TargetInfo.url) { $AssetName = $TargetInfo.url }
                if ($TargetInfo.sha256) { $ExpectedSha256 = "$($TargetInfo.sha256)".Trim().ToLowerInvariant() }
            }
        }
    }
}

if ($AssetName -match '^https?://') {
    $DownloadUrl = $AssetName
} else {
    $MatchedAsset = $Assets | Where-Object { $_.name -eq $AssetName } | Select-Object -First 1
    if ($MatchedAsset) {
        $DownloadUrl = $MatchedAsset.browser_download_url
    }
}

if (-not $DownloadUrl) {
    Write-Error "No CLI archive found for target '$Triplet' in release '$ReleaseTag'."
    exit 1
}

# 4. Resolve Nikrun Home (~/.nikrun or $env:NIKRUN_HOME, matching nik.paths.pas)
$UserHome = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }
$NikrunHome = if (-not [string]::IsNullOrWhiteSpace($env:NIKRUN_HOME)) {
    [System.IO.Path]::GetFullPath($env:NIKRUN_HOME.Trim())
} else {
    Join-Path $UserHome ".nikrun"
}
$InstallDir = Join-Path $NikrunHome "bin"
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

# 5. Download, verify SHA-256, and extract in isolated temp directory
$TempWorkDir = Join-Path ([System.IO.Path]::GetTempPath()) ("nikrun-install-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $TempWorkDir | Out-Null

try {
    $TempZip = Join-Path $TempWorkDir "nik.zip"
    $ExtractDir = Join-Path $TempWorkDir "extracted"

    Write-Host "Downloading Nikrun CLI $ReleaseTag ($Triplet)..."
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempZip -UseBasicParsing

    if ($ExpectedSha256) {
        $ActualSha256 = (Get-FileHash -Path $TempZip -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($ActualSha256 -ne $ExpectedSha256) {
            throw "SHA-256 checksum mismatch! Expected $ExpectedSha256, got $ActualSha256."
        }
        Write-Host "Verified SHA-256 checksum ($($ActualSha256.Substring(0, 12))...)."
    }

    Expand-Archive -Path $TempZip -DestinationPath $ExtractDir -Force
    $ExtractedExe = Get-ChildItem -Path $ExtractDir -Filter "nik.exe" -Recurse | Select-Object -First 1
    if (-not $ExtractedExe) {
        throw "Archive did not contain nik.exe."
    }

    # Stop running nik.exe instances (e.g. nik lsp in VS Code) to release binary lock
    $CurrentPid = $PID
    Get-Process -Name "nik" -ErrorAction SilentlyContinue |
        Where-Object { $_.Id -ne $CurrentPid } |
        Stop-Process -Force -ErrorAction SilentlyContinue

    $TargetExe = Join-Path $InstallDir "nik.exe"
    $OldExe = Join-Path $InstallDir "nik.exe.old"
    if (Test-Path $TargetExe) {
        Remove-Item -Path $OldExe -Force -ErrorAction SilentlyContinue
        Rename-Item -Path $TargetExe -NewName "nik.exe.old" -Force -ErrorAction SilentlyContinue
    }

    $Moved = $false
    for ($i = 0; $i -lt 5; $i++) {
        try {
            Move-Item -Path $ExtractedExe.FullName -Destination $TargetExe -Force
            $Moved = $true
            break
        } catch {
            Start-Sleep -Milliseconds 500
        }
    }

    if (-not $Moved) {
        throw "Failed to install nik.exe into $InstallDir. Ensure no process is locking nik.exe."
    }

    Remove-Item -Path $OldExe -Force -ErrorAction SilentlyContinue
} finally {
    Remove-Item -Path $TempWorkDir -Recurse -Force -ErrorAction SilentlyContinue
}

# 6. Store local uninstall.ps1 & register in Windows Installed Apps (User-scope HKCU)
$LocalUninstallScript = Join-Path $NikrunHome "uninstall.ps1"
if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot "uninstall.ps1"))) {
    Copy-Item -Path (Join-Path $PSScriptRoot "uninstall.ps1") -Destination $LocalUninstallScript -Force
} else {
    try {
        Invoke-WebRequest -Uri "$SiteBaseUrl/uninstall.ps1" -OutFile $LocalUninstallScript -UseBasicParsing
    } catch {
        try {
            Invoke-WebRequest -Uri "$RawFallbackBaseUrl/uninstall.ps1" -OutFile $LocalUninstallScript -UseBasicParsing
        } catch {
            Write-Warning "Could not save local uninstall.ps1 for offline Windows Settings uninstallation."
        }
    }
}

try {
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Nikrun CLI"
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }

    $TargetExe = Join-Path $InstallDir "nik.exe"
    Set-ItemProperty -Path $RegPath -Name "DisplayName" -Value "Nikrun CLI"
    Set-ItemProperty -Path $RegPath -Name "DisplayVersion" -Value $ReleaseTag
    Set-ItemProperty -Path $RegPath -Name "Publisher" -Value "Nikrun"
    Set-ItemProperty -Path $RegPath -Name "URLInfoAbout" -Value $SiteBaseUrl
    Set-ItemProperty -Path $RegPath -Name "DisplayIcon" -Value "$TargetExe,0"
    Set-ItemProperty -Path $RegPath -Name "InstallLocation" -Value $NikrunHome
    Set-ItemProperty -Path $RegPath -Name "UninstallString" -Value "powershell.exe -ExecutionPolicy Bypass -NoProfile -File `"$LocalUninstallScript`""
    Set-ItemProperty -Path $RegPath -Name "QuietUninstallString" -Value "powershell.exe -ExecutionPolicy Bypass -NoProfile -File `"$LocalUninstallScript`" -NonInteractive"
    Set-ItemProperty -Path $RegPath -Name "NoModify" -Value 1 -Type DWord
    Set-ItemProperty -Path $RegPath -Name "NoRepair" -Value 1 -Type DWord
} catch {
    Write-Warning "Could not register Nikrun CLI under Windows Installed Apps: $($_.Exception.Message)"
}

# 7. Ensure ~/.nikrun/bin is on User PATH & current session PATH (segment-exact, no leading semicolons)
$NormalizedInstallDir = $InstallDir.TrimEnd('\')
$RawUserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$UserPathEntries = @()
if (-not [string]::IsNullOrWhiteSpace($RawUserPath)) {
    $UserPathEntries = @($RawUserPath -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

$AlreadyInUserPath = $false
foreach ($Entry in $UserPathEntries) {
    if ($Entry.Trim().TrimEnd('\') -ieq $NormalizedInstallDir) {
        $AlreadyInUserPath = $true
        break
    }
}

if (-not $AlreadyInUserPath) {
    Write-Host "Adding $InstallDir to User PATH..."
    $UpdatedUserPath = ($UserPathEntries + $InstallDir) -join ';'
    [Environment]::SetEnvironmentVariable("PATH", $UpdatedUserPath, "User")
}

$SessionEntries = @($env:Path -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
$AlreadyInSession = $false
foreach ($Entry in $SessionEntries) {
    if ($Entry.Trim().TrimEnd('\') -ieq $NormalizedInstallDir) {
        $AlreadyInSession = $true
        break
    }
}
if (-not $AlreadyInSession) {
    $env:Path = "$InstallDir;$env:Path"
}

Write-Host ""
if (-not $AlreadyInUserPath) {
    Write-Host "Nikrun CLI ($ReleaseTag) installed to $TargetExe." -ForegroundColor Green
    Write-Host "The 'nik' command is ready in this session (restart other open terminals to pick up PATH)."
} else {
    Write-Host "Nikrun CLI updated to $ReleaseTag ($TargetExe)." -ForegroundColor Green
}
