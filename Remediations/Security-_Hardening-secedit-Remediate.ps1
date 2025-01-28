# Force audit policy subcategory settings to override audit policy category settings: Enabled
Set-ItemProperty -Path HKLM:\System\CurrentControlSet\Control\Lsa -Name SCENoApplyLegacyAuditPolicy -Value 1 -Type DWord

# Allow LocalSystem NULL session fallback: Disabled
Set-ItemProperty -Path HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0 -Name allownullsessionfallback -Value 0 -Type DWord

# Force strong key protection for user keys stored on the computer: User must enter a password each time they use a key
Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Cryptography -Name ForceKeyProtection -Value 2 -Type DWord

secedit /export /cfg secedit.cfg
$secedit = Get-Content secedit.cfg
$secedit = $secedit -replace "LockoutDuration.*", "LockoutDuration = 15" <# Account lockout duration: 15 minutes) #> `
-replace "LockoutBadCount.*", "LockoutBadCount = 5" <# Account lockout threshold: 5 #> `
-replace "ResetLockoutCount.*", "ResetLockoutCount = 15" <# Reset account lockout counter after: 15 minutes #> `
-replace "RequireSignOrSeal.*", "RequireSignOrSeal=4,1" <# Digitally encrypt or sign secure channel data: Enabled #> `
-replace "SealSecureChannel.*", "SealSecureChannel=4,1" <# Digitally encrypt secure channel data: Enabled #> `
-replace "SignSecureChannel.*", "SignSecureChannel=4,1" <# Digitally sign secure channel data: Enabled #> `
-replace "RequireStrongKey.*", "RequireStrongKey=4,1" <# Require strong (Windows 2000 or later) session key: Enabled #> `
-replace "CachedLogonsCount.*", 'CachedLogonsCount=1,"1"' <# Number of previous logons to cache: 1 #> `
-replace "LSAAnonymousNameLookup.*", "LSAAnonymousNameLookup = 0" <# Allow anonymous SID/Name translation: Disabled #> `
-replace "EveryoneIncludesAnonymous.*", "EveryoneIncludesAnonymous=4,0" <# Let Everyone permissions apply to anonymous users: Disabled #> `
-replace "ForceLogoffWhenHourExpire.*", "ForceLogoffWhenHourExpire = 1" <# Force logoff when logon hours expire: Enabled #> `
-replace "ObCaseInsensitive.*", "ObCaseInsensitive=4,1" <# Require case insensitivity for non-Windows subsystems: Enabled #> `
-replace "ProtectionMode.*", "ProtectionMode=4,1" <# Strengthen default permissions of internal system objects: Enabled #>
# FIPS app configuration overhead is too high
# -replace "FIPSAlgorithmPolicy\\Enabled.*", "FIPSAlgorithmPolicy\\Enabled=4,1" <# Use FIPS compliant algorithms for encryption, hashing, and signing: Enabled #> `

$secedit | Out-File seceditnew.cfg
secedit /import /db seceditnew.db /cfg seceditnew.cfg
secedit /configure /db seceditnew.db
gpupdate /force