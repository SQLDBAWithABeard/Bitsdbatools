targetScope = 'subscription'
@minLength(1)
@maxLength(90)
@description('The name of the Resource Group')
param rgName string

@minLength(1)
@maxLength(63)
@description('The name of the SQL server - Lowercase letters, numbers, and hyphens.Cant start or end with hyphen.')
param name string

@minLength(1)
@maxLength(128)
@description('Name of the database - Cant use: <>*%&:\\/? or control characters Cant end with period or space')
param dbName string

@description('The location for the SQL Server')
param location string

@description('The name of the AAD login or Group')
param AADLogin string

@description('The SID of the AAD login or Group')
param AADSid string

@description('The type of the AAD login or Group')
param AADType string

@description('The name of the administrator login')
param administratorLogin string

@description('The password for the SQL Server Administratoe')
@secure()
param administratorLoginPassword string

@description('The tags that should be added to the resource')
param tags object = {}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
  tags: tags
}

module sqlserver 'sqlserver.bicep' = {
  scope: resourceGroup
  name: '${name}-deploy'
  params: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    location: location
    name: name
    AADLogin: AADLogin
    AADSid: AADSid
    AADType: AADType
  }
}

module database 'database.bicep' = {
  scope: resourceGroup
  name: '${dbName}-deploy'
  params: {
    location: location
    dbName: '${dbName}AW'
    sqlServerName: name
    sampleName: 'AdventureWorksLT'
  }
  dependsOn: [
    sqlserver
  ]
}