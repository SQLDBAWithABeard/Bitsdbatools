@minLength(1)
@maxLength(63)
@description('The name of the SQL server - Lowercase letters, numbers, and hyphens.Cant start or end with hyphen.')
param sqlServerName string

@minLength(1)
@maxLength(128)
@description('Name of the database - Cant use: <>*%&:\\/? or control characters Cant end with period or space')
param dbName string


@description('The location for the SQL Server')
param location string

@allowed([
  'AdventureWorksLT'
  'WideWorldImportersFull'
  'WideWorldImportersStd'
])
@description('The sample name')
param sampleName string


resource sqldatabase 'Microsoft.Sql/servers/databases@2021-05-01-preview' = {
  name: '${sqlServerName}/${dbName}'
  location: location
  properties: {
    sampleName: sampleName
  }
}

output dbname string = sqldatabase.name
