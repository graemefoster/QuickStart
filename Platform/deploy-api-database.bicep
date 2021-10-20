param resourceSuffix string
param databaseServerName string
param environment string

var databaseName = '${resourceSuffix}-${environment}-sqldb'

resource SqlDatabaseTest 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: '${databaseServerName}/${databaseName}'
  location: resourceGroup().location
}

output apiDatabaseName string = databaseName
