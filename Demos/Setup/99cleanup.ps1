
$FolderPath = $Env:USERPROFILE + '\Documents\dbatoolsdemo'
Write-Output "Removing containers"

docker-compose down 

Write-Output "Removing directories and files"
Remove-Item $FolderPath -Recurse -Force
Write-Output "Removed everything"
