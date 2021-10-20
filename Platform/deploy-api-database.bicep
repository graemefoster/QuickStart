param resourceSuffix string
param databaseServerName string
param environmentName string

var databaseName = '${resourceSuffix}-${environmentName}-sqldb'

resource SqlDatabaseTest 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: '${databaseServerName}/${databaseName}'
  location: resourceGroup().location
}

output apiDatabaseName string = databaseName
output apiDatabaseConnectionString string = 'Server=tcp:${databaseServerName}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${databaseName};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30'
