$Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$ValueName = "InactivityLimit"
$ExpectedValue = 1800

$CurrentValue = Get-ItemProperty -Path $Path -Name $ValueName -ErrorAction SilentlyContinue

$results = @{"InactivityLimit" = $null}

if ($CurrentValue."$ValueName" -eq $ExpectedValue) {
    $results["InactivityLimit"] = $ExpectedValue
} else {
    $results["InactivityLimit"] = $CurrentValue."$ValueName"
}

return $results | ConvertTo-Json -Compress
