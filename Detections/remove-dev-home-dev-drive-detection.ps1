if 
(Get-AppxPackage | Where-Object {$_.Name -Like '*DevHome*'}) {
Write-Host "Dev Home Installed!"
exit 1
}
else {
write-host "Dev Home not Installed!"
exit 0
}