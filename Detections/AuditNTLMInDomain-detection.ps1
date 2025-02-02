try {
	if(-NOT (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters")){ return $false };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' -Name 'auditntlmindomain' -ea SilentlyContinue) -eq 7) {  } else { return $false };
}
catch { return $false }
return $true