if 
(Get-AppxPackage | Where-Object {$_.Name -Like '*OutlookForWindows*'}) {
Write-Host "Microsoft Outlook (New) Installed!"
exit 1
}
else {
write-host "Microsoft Outlook (New) not Installed!"
exit 0
}