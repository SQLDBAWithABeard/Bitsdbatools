$ShowAzure = $true
Connect-AzAccount
Set-AzContext -Subscription Pay-As-You-Go

$securePassword = ('dbatools.IO' | ConvertTo-SecureString -AsPlainText -Force)
$continercredential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)

# Validate the deployment with Whatif
$DeploymentConfig = @{
    TemplateFile               = 'Game\demoazure.bicep'
    location                   = 'westeurope'
    locationFromTemplate       = 'westeurope'
    rgName                     = 'SqlBitsGame'
    nameFromTemplate           = 'TheHauntedHouse'
    dbName                     = 'Chapter22'
    administratorLogin         = $continercredential.UserName
    administratorLoginPassword = $continercredential.Password
    WhatIf                     = $true
}
New-AzDeployment @DeploymentConfig

# deploy
$DeploymentConfig = @{
    TemplateFile               = 'Game\demoazure.bicep'
    location                   = 'westeurope'
    locationFromTemplate       = 'westeurope'
    rgName                     = 'SqlBitsGame'
    nameFromTemplate           = 'TheHauntedHouse'
    dbName                     = 'Chapter22'
    administratorLogin         = $continercredential.UserName
    administratorLoginPassword = $continercredential.Password
    AADLogin                   = 'Beard_SQLAdmins'
    AADSid                     = 'f27e046a-0b1e-4c1c-a1da-ccff56f63148'
    AADType                    = 'Group'
}
New-AzDeployment @DeploymentConfig
