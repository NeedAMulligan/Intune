# EXIT CODES
# 0    = Success
# 1001 = Failed to create log directory
# 1003 = Partial failure during registry mounting

$ErrorActionPreference = "Stop"
$LogPath = "C:\temp"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile = Join-Path $LogPath "Intune_Remediate_Bing_$($Timestamp).log"

if (!(Test-Path $LogPath)) { try { New-Item -Path $LogPath -ItemType Directory -Force | Out-Null } catch { exit 1001 } }

function Write-Log {
    param([string]$Message)
    $Entry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    Add-Content -Path $LogFile -Value $Entry
}

$RegistryPath = "Software\Policies\Microsoft\Windows\Windows Search"

function Set-BingRegistryKeys {
    param([string]$HivePath)
    $FullRegistryPath = "$HivePath\$RegistryPath"
    if (!(Test-Path "Registry::$FullRegistryPath")) { New-Item -Path "Registry::$FullRegistryPath" -Force | Out-Null }
    Set-ItemProperty -Path "Registry::$FullRegistryPath" -Name "ConnectedSearchUseWeb" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path "Registry::$FullRegistryPath" -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -Force
}

Write-Log "Starting Remediation..."

# 1. Active Users
$LoadedHives = Get-ChildItem -Path "HKU:\" | Where-Object { $_.Name -match "S-1-5-21-[\d\-]+$" }
foreach ($Hive in $LoadedHives) {
    Set-BingRegistryKeys -HivePath "HKEY_USERS\$($Hive.PSChildName)"
    Write-Log "Remediated Active Hive: $($Hive.Name)"
}

# 2. Offline Users
$UserProfiles = Get-ChildItem -Path "C:\Users" -Directory
foreach ($Profile in $UserProfiles) {
    $NtUserPath = Join-Path $Profile.FullName "NTUSER.DAT"
    if (Test-Path $NtUserPath) {
        $TempHiveName = "TempHive_$($Profile.Name)"
        try {
            reg load "HKU\$TempHiveName" "$NtUserPath" | Out-Null
            Set-BingRegistryKeys -HivePath "HKEY_USERS\$TempHiveName"
            [gc]::Collect()
            [gc]::WaitForPendingFinalizers()
            reg unload "HKU\$TempHiveName" | Out-Null
            Write-Log "Remediated Offline Profile: $($Profile.Name)"
        } catch {
            Write-Log "Error processing $($Profile.Name): $($_.Exception.Message)"
        }
    }
}

# 3. Force Refresh
Get-Process -Name "explorer" -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Log "Remediation complete. Explorer restarted."
exit 0