param resourcePrefix string
param databaseServerName string
param environmentName string
param logAnalyticsWorkspaceId string

var databaseName = '${resourcePrefix}-${environmentName}-sqldb'

resource SqlDatabaseTest 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: '${databaseServerName}/${databaseName}'
  location: resourceGroup().location
}


resource DatabaseDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'databaseDiagnostics'
  scope: SqlDatabaseTest
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    metrics: [
      {
        category: 'Basic'
        enabled: true
        retentionPolicy: {
          days: 3
          enabled: true
        }
      }
    ]
    logs: [
      {
        categoryGroup: 'log'
        enabled: true
        retentionPolicy: {
          days: 3
          enabled: true
        }
      }
    ]
  }
}

output apiDatabaseName string = databaseName
output apiDatabaseConnectionString string = 'Server=tcp:${databaseServerName}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${databaseName};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30'
