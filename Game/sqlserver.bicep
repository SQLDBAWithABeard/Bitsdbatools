@minLength(1)
@maxLength(63)
@description('The name of the SQL server - Lowercase letters, numbers, and hyphens.Cant start or end with hyphen.')
param name string

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

resource sqlserver 'Microsoft.Sql/servers@2021-05-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    administrators: {
      administratorType: 'ActiveDirectory'
      login: AADLogin
      principalType: AADType
      sid: AADSid
    }
  }
}

output sqlservername string = sqlserver.name
