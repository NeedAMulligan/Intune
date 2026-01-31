# EXIT CODES: 0 = Success | 1001 = Log Fail
$ErrorActionPreference = "Continue" # Ensure we don't stop on native command errors
$LogPath = "C:\temp"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile = Join-Path $LogPath "Intune_Remediate_Bing_Aggressive_$($Timestamp).log"

if (!(Test-Path $LogPath)) { try { New-Item -Path $LogPath -ItemType Directory -Force | Out-Null } catch { exit 1001 } }
function Write-Log { param([string]$Message) Add-Content -Path $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" }

if (!(Test-Path "HKU:\")) { New-PSDrive -Name HKU -PSProvider Registry -Root HKey_Users | Out-Null }

function Set-AggressiveBingFix {
    param([string]$HivePath)
    $RegPrefix = "Registry::$HivePath"
    try {
        # Policy Path
        $P1 = "$RegPrefix\Software\Policies\Microsoft\Windows\Windows Search"
        if (!(Test-Path $P1)) { New-Item -Path $P1 -Force | Out-Null }
        Set-ItemProperty -Path $P1 -Name "ConnectedSearchUseWeb" -Value 0 -Type DWord -Force
        Set-ItemProperty -Path $P1 -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -Force

        # User Search Path
        $P2 = "$RegPrefix\Software\Microsoft\Windows\CurrentVersion\Search"
        if (!(Test-Path $P2)) { New-Item -Path $P2 -Force | Out-Null }
        Set-ItemProperty -Path $P2 -Name "BingSearchEnabled" -Value 0 -Type DWord -Force

        # Search Highlights
        $P3 = "$RegPrefix\Software\Microsoft\Windows\CurrentVersion\SearchSettings"
        if (!(Test-Path $P3)) { New-Item -Path $P3 -Force | Out-Null }
        Set-ItemProperty -Path $P3 -Name "IsSearchHighlightsEnabled" -Value 0 -Type DWord -Force
        
        Write-Log "Applied aggressive fixes to: $HivePath"
    } catch { Write-Log "Error on ${HivePath}: $($_.Exception.Message)" }
}

# 1. Active Users
Get-ChildItem -Path "HKU:\" | Where-Object { $_.Name -match "S-1-5-21-[\d\-]+$" } | ForEach-Object {
    Set-AggressiveBingFix -HivePath "HKEY_USERS\$($_.PSChildName)"
}

# 2. Offline Users
Get-ChildItem -Path "C:\Users" -Directory | ForEach-Object {
    $Dat = Join-Path $_.FullName "NTUSER.DAT"
    if (Test-Path $Dat) {
        $Name = $_.Name
        $Load = reg load "HKU\Temp_$Name" "$Dat" 2>&1 | Out-String
        if ($Load -match "successfully") {
            Set-AggressiveBingFix -HivePath "HKEY_USERS\Temp_$Name"
            [gc]::Collect(); [gc]::WaitForPendingFinalizers()
            reg unload "HKU\Temp_$Name" | Out-Null
        }
    }
}

# 3. Force Refresh
Stop-Process -Name "SearchHost" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
Restart-Service -Name "WSearch" -Force -ErrorAction SilentlyContinue

Write-Log "Aggressive Remediation Finished."
exit 0
