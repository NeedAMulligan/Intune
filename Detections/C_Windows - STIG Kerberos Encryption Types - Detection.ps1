try {
	if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\kerberos\parameters")){ return $false };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\kerberos\parameters' -Name 'supportedencryptiontypes' -ea SilentlyContinue) -eq 0x2147483640) {  } else { return $false };
}
catch { return $false }
return $true