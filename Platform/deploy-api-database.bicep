param resourceSuffix string
param databaseServerName string

var testDatabaseName = '${resourceSuffix}-test-sqldb'
var productionDatabaseName = '${resourceSuffix}-sqldb'

resource SqlDatabaseTest 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: '${databaseServerName}/${testDatabaseName}'
  location: resourceGroup().location
}

resource SqlDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: '${databaseServerName}/${productionDatabaseName}'
  location: resourceGroup().location
}

output productionApiDatabaseName string = productionDatabaseName
output testApiDatabaseName string = testDatabaseName
