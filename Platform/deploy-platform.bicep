param resourcePrefix string
param databaseAdministratorName string
param databaseAdministratorObjectId string

var databaseServerName = '${resourcePrefix}-sqlserver'

resource LogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${resourcePrefix}-{loga}'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    workspaceCapping: {
      dailyQuotaGb: 1
    }
  }
}

resource QuickStartServerFarm 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: '${resourcePrefix}-asp'
  location: resourceGroup().location
  sku: {
    name: 'S1'
  }
}

resource AppKeyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${resourcePrefix}-asp-logs'
  scope: QuickStartServerFarm
  properties: {
    workspaceId: LogAnalyticsWorkspace.id
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 3
          enabled: true
        }
      }
    ]
  }
}

resource SqlDatabaseServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: databaseServerName
  location: resourceGroup().location
  properties: {
    minimalTlsVersion: '1.2'
    administrators: {
      azureADOnlyAuthentication: true
      administratorType: 'ActiveDirectory'
      login: databaseAdministratorName
      principalType: 'Application'
      tenantId: subscription().tenantId
      sid: databaseAdministratorObjectId
    }
  }
}

resource SqlFirewallAllowAzureServices 'Microsoft.Sql/servers/firewallRules@2021-02-01-preview' = {
  parent: SqlDatabaseServer
  name: 'AllowAllAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

output serverFarmId string = QuickStartServerFarm.id
output databaseServerName string = databaseServerName
