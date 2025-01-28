# Force audit policy subcategory settings to override audit policy category settings: Enabled
$SCENoApplyLegacyAuditPolicy = Get-ItemPropertyValue -Path HKLM:\System\CurrentControlSet\Control\Lsa -Name SCENoApplyLegacyAuditPolicy

# Allow LocalSystem NULL session fallback: Disabled
$allownullsessionfallback = Get-ItemPropertyValue -Path HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0 -Name allownullsessionfallback


if ($SCENoApplyLegacyAuditPolicy -eq 1 -and $autodisconnect -eq 15 -and $allownullsessionfallback -eq 0 -and $ForceKeyProtection -eq 2) {
  secedit /export /cfg secedit.cfg
  $secedit = Get-Content secedit.cfg
  $settings = @(
    "LockoutBadCount = 5", # Account lockout threshold: 5
    "ResetLockoutCount = 15", # Reset account lockout counter after: 15 minutes
    "RequireSignOrSeal=4,1", # Digitally encrypt or sign secure channel data: Enabled
    "SealSecureChannel=4,1", # Digitally encrypt secure channel data: Enabled
    "SignSecureChannel=4,1", # Digitally sign secure channel data: Enabled
    "DisablePasswordChange=4,0", # Disable machine account password changes: Disabled
    "RequireStrongKey=4,1", # Require strong (Windows 2000 or later) session key: Enabled
    'CachedLogonsCount=1,"1"', # Number of previous logons to cache: 1
    "LSAAnonymousNameLookup = 0", # Allow anonymous SID/Name translation: Disabled
    "EveryoneIncludesAnonymous=4,0", # Let Everyone permissions apply to anonymous users: Disabled
    "ForceLogoffWhenHourExpire = 1", # Force logoff when logon hours expire: Enabled
    "ObCaseInsensitive=4,1", # Require case insensitivity for non-Windows subsystems: Enabled
    "ProtectionMode=4,1" # Strengthen default permissions of internal system objects: Enabled
    # FIPS app configuration overhead is too high
    # "FIPSAlgorithmPolicy\Enabled=4,1", # Use FIPS compliant algorithms for encryption, hashing, and signing: Enabled
  )

  if ($settings | where { $secedit -like "*$_*" }) {
    exit 0
  }
}

exit 1