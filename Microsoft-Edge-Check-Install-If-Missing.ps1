<#
.SYNOPSIS
    Ensures Microsoft Edge is installed and meets a minimum version requirement.
    
.DESCRIPTION
    1. Checks for msedge.exe.
    2. Compares the local version against a defined Minimum Version.
    3. If missing or outdated, uses WinGet to Install/Upgrade silently.
    4. Logs all activity to C:\temp.

.NOTES
    Intune Settings:
    - Run as SYSTEM: Yes
    - Run as 64-bit: Yes
#>

# --------------------------------------------------------------------------
# VARIABLES
# --------------------------------------------------------------------------
$PackageId      = "Microsoft.Edge"
$MinVersion     = "120.0.0.0"  # Update this string to your required baseline
$LogDirectory   = "C:\temp"
$Timestamp      = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFileName    = "Intune_Edge_Sync_$Timestamp.log"
$LogPath        = Join-Path -Path $LogDirectory -ChildPath $LogFileName
$EdgeExePath    = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"

# --------------------------------------------------------------------------
# EXIT CODES
# --------------------------------------------------------------------------
# 0  - Success (Installed and Compliant)
# 1  - Installation/Upgrade Failed
# 2  - Script Error
# --------------------------------------------------------------------------

# Ensure Log Directory exists
if (!(Test-Path $LogDirectory)) { New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null }

Start-Transcript -Path $LogPath -Append

function Write-IntuneLog {
    param([string]$Message, [string]$Type = "INFO")
    $Stamp = Get-Date -Format "HH:mm:ss"
    Write-Output "[$Stamp] [$Type] $Message"
}

try {
    Write-IntuneLog "Starting Microsoft Edge Version Sync (Min Required: $MinVersion)"
    
    $NeedsAction = $false

    # 1. Check Existence and Version
    if (Test-Path $EdgeExePath) {
        $CurrentVersion = [version](Get-Item $EdgeExePath).VersionInfo.FileVersion
        Write-IntuneLog "Current Edge Version detected: $CurrentVersion"

        if ($CurrentVersion -lt [version]$MinVersion) {
            Write-IntuneLog "Version is below baseline. Upgrade required."
            $NeedsAction = $true
        } else {
            Write-IntuneLog "Edge is compliant. No action needed."
            exit 0
        }
    } else {
        Write-IntuneLog "Microsoft Edge not found. Installation required."
        $NeedsAction = $true
    }

    # 2. Perform Install/Upgrade
    if ($NeedsAction) {
        Write-IntuneLog "Refreshing WinGet sources for SYSTEM context..."
        & winget source reset --force | Out-Null
        
        # Use 'upgrade' with --install-if-not-found to cover both scenarios
        Write-IntuneLog "Executing WinGet Upgrade/Install for $PackageId..."
        $Args = "upgrade --id $PackageId --source winget --accept-package-agreements --accept-source-agreements --silent --force"
        $Process = Start-Process -FilePath "winget.exe" -ArgumentList $Args -Wait -PassThru -NoNewWindow

        if ($Process.ExitCode -eq 0 -or $Process.ExitCode -eq 0x8A15002B) { 
            # 0x8A15002B often means 'No update available' which we treat as success
            Write-IntuneLog "WinGet operation completed successfully."
            exit 0
        } else {
            Write-IntuneLog "WinGet failed with Exit Code: $($Process.ExitCode)" "ERROR"
            exit 1
        }
    }
}
catch {
    Write-IntuneLog "Critical Error: $($_.Exception.Message)" "ERROR"
    exit 2
}
finally {
    Stop-Transcript
}