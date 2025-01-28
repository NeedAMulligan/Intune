# Removes Power Automate if installed
try{
    Get-AppxPackage | Where-Object {$_.Name -Like '*PowerAutomate*'} | Remove-AppxPackage -ErrorAction stop
    Write-Host "Power Automate successfully removed!"

}
catch{
    Write-Error "Error removing Microsoft Power Automate!"
}