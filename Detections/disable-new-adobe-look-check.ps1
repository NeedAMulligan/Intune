try {
	if(-NOT (Test-Path -LiteralPath "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral")){ return $false };
	if((Get-ItemPropertyValue -LiteralPath 'HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral' -Name 'bEnableAV2' -ea SilentlyContinue) -eq 0) {  } else { return $false };
}
catch { return $false }
return $true