# 1. Connect
Connect-MgGraph -Scopes "Policy.Read.All"

# 2. Set Export Path - Using a local temp folder first is safer than OneDrive
$ExportPath = "C:\CA_Policy_Backup"
if (!(Test-Path $ExportPath)) { New-Item -ItemType Directory -Path $ExportPath }

# 3. Get Policies
$Policies = Get-MgIdentityConditionalAccessPolicy -All

foreach ($Policy in $Policies) {
    # This regex replaces ANY character that isn't a letter, number, space, or hyphen with an underscore
    $CleanName = $Policy.DisplayName -replace '[^a-zA-Z0-9\s\-]', '_'
    
    # Trim trailing spaces and ensure the filename isn't empty
    $CleanName = $CleanName.Trim()
    if ([string]::IsNullOrWhiteSpace($CleanName)) { $CleanName = "UnnamedPolicy_$($Policy.Id)" }
    
    $FileName = Join-Path -Path $ExportPath -ChildPath "$CleanName.json"
    
    try {
        $Policy | ConvertTo-Json -Depth 10 | Out-File -FilePath $FileName -ErrorAction Stop
        Write-Host "Successfully exported: $($Policy.DisplayName)" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to export: $($Policy.DisplayName). Error: $_"
    }
}

Write-Host "`nExport complete! Files are located at: $ExportPath" -ForegroundColor Cyan