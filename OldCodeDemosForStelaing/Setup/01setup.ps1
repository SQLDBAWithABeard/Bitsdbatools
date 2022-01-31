<#
Creates a dbatools demo directory  in the users profile documents 
Saves the default cred for the containers in there
sets that directory as a volume in the docker-compose to be used for backups etc
runs docker compse up -d
run from root of repo
#>

$FolderPath = $Env:USERPROFILE + '\Documents\dbatoolsdemo'

########################################################
Write-Output "Creating Directory $FolderPath"
if (Test-Path $FolderPath) {
    Write-Output "Path $FolderPath exists already"
} else {
    $null = New-Item $FolderPath -ItemType Directory
}

Write-Output "Creating Directory $FolderPath\SQL1"
if (Test-Path "$FolderPath\SQL1") {
    Write-Output "Directory SQL1 exists already"
    Get-ChildItem "$FolderPath\SQL1" -Recurse | Remove-Item -Recurse -Force
} else {
    $null = New-Item "$FolderPath\SQL1"-ItemType Directory
}
Write-Output "Creating File $FolderPath\SQL1\dummyfile.txt"
if (Test-Path "$FolderPath\SQL1\dummyfile.txt") {
    Write-Output "dummyfile.txt exists already"
} else {
    
    $null = New-Item "$FolderPath\SQL1\dummyfile.txt" -ItemType file
}

Write-Output "Creating Directory $FolderPath\SQL2"
if (Test-Path "$FolderPath\SQL2") {
    Write-Output "Directory SQL2 exists already"
    Get-ChildItem "$FolderPath\SQL2" -Recurse | Remove-Item -Recurse -Force
} else {
    $null = New-Item "$FolderPath\SQL2"-ItemType Directory
}
Write-Output "Creating File $FolderPath\SQL2\dummyfile.txt"
if (Test-Path "$FolderPath\SQL2\dummyfile.txt") {
    Write-Output "dummyfile.txt exists already"
} else {
    $null = New-Item "$FolderPath\SQL2\dummyfile.txt" -ItemType file
}

Write-Output "Creating a credential file for the containers - Please don't do this in production"

$sqladminPassword = ConvertTo-SecureString 'dbatools.IO' -AsPlainText -Force 
$cred = New-Object System.Management.Automation.PSCredential ('sqladmin', $sqladminpassword)
$Cred | Export-Clixml -Path $FolderPath\sqladmin.cred
Write-Output "Credential file created"

Write-Output "Setting the docker-compose files values"

$dockercompose = (Get-Content .\Demos\setup\dockercompose.yml -ErrorAction Stop) -replace '__ReplaceME__' , $FolderPath
# $dockercompose
$dockercompose | Set-Content docker-compose.yml
docker compose up -d

& .\Demos\Setup\01setup.tests.ps1
Write-Output "Finished"