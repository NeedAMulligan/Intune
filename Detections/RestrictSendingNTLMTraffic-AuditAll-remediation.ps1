if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0' -Name 'RestrictSendingNTLMTraffic' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
