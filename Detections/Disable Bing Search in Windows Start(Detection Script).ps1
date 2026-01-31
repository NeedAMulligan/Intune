# EXIT CODES: 0 = Compliant | 1 = Non-Compliant (Triggers Remediation)
if (!(Test-Path "HKU:\")) { New-PSDrive -Name HKU -PSProvider Registry -Root HKey_Users | Out-Null }

$NeedsRemediation = $false
$LoadedHives = Get-ChildItem -Path "HKU:\" | Where-Object { $_.Name -match "S-1-5-21-[\d\-]+$" }

foreach ($Hive in $LoadedHives) {
    $Base = "HKU:\$($Hive.PSChildName)"
    
    # Check 1: Policy Keys
    $Pol = Get-ItemProperty -Path "$Base\Software\Policies\Microsoft\Windows\Windows Search" -ErrorAction SilentlyContinue
    # Check 2: User Search Keys
    $Usr = Get-ItemProperty -Path "$Base\Software\Microsoft\Windows\CurrentVersion\Search" -ErrorAction SilentlyContinue
    # Check 3: Search Highlights
    $Hlt = Get-ItemProperty -Path "$Base\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -ErrorAction SilentlyContinue

    $IsNonCompliant = ($Pol.ConnectedSearchUseWeb -ne 0) -or 
                      ($Pol.DisableSearchBoxSuggestions -ne 1) -or 
                      ($Usr.BingSearchEnabled -ne 0) -or 
                      ($Hlt.IsSearchHighlightsEnabled -ne 0)

    if ($IsNonCompliant) {
        $NeedsRemediation = $true
        break
    }
}

if ($NeedsRemediation) { exit 1 } else { exit 0 }
