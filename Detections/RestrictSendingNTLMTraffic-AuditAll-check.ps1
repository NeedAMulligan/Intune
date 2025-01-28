try {
	if(-NOT (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0")){ return $false };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0' -Name 'RestrictSendingNTLMTraffic' -ea SilentlyContinue) -eq 1) {  } else { return $false };
}
catch { return $false }
return $true