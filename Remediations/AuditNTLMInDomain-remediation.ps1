if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' -Name 'auditntlmindomain' -Value 7 -PropertyType DWord -Force -ea SilentlyContinue;