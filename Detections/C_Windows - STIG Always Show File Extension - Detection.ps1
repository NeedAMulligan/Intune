try {
	if(-NOT (Test-Path -LiteralPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")){ return $false };
	if((Get-ItemPropertyValue -LiteralPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -ea SilentlyContinue) -eq 0) {  } else { return $false };
}
catch { return $false }
return $true