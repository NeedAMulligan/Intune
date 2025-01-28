if 
(Get-AppxPackage | Where-Object {$_.Name -Like '*PowerAutomate*'}) {
Write-Host "Microsoft Power Automate Installed!"
exit 1
}
else {
write-host "Microsoft Power Automate not Installed!"
exit 0
}