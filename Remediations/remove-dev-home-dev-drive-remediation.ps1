# Removes Dev Home App if installed
try{
    Get-AppxPackage | Where-Object {$_.Name -Like '*DevHome*'} | Remove-AppxPackage -ErrorAction stop
    Write-Host "Dev Home successfully removed!"

}
catch{
    Write-Error "Error removing Dev Home!"
}