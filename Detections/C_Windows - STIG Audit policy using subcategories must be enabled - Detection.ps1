try {
	if(-NOT (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa")){ return $false };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'scenoapplylegacyauditpolicy' -ea SilentlyContinue) -eq 1) {  } else { return $false };
}
catch { return $false }
return $true