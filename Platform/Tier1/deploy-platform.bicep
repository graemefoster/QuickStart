param resourcePrefix string
param apimPublishedEmail string
param databaseAdministratorName string
param databaseAdministratorObjectId string
param environmentName string
param hasSlot bool

var apimName = '${resourcePrefix}-${environmentName}-apim'
var databaseServerName = '${resourcePrefix}-${environmentName}-sqlserver'
var location = resourceGroup().location
var containerAppLocation = 'canadacentral'

resource LogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${resourcePrefix}-${environmentName}-loga'
  location: location
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
  name: '${resourcePrefix}-${environmentName}-asp'
  location: location
  sku: {
    name: hasSlot ? 'S1' : 'F1'
  }
}

resource AppServicePlanDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'aspDiagnostics'
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

resource ContainerAppsAppInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: '${resourcePrefix}-${environmentName}-ctrapps-appi'
  location: location
  kind: 'web'
  properties: { 
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
  }
}

resource ContainerAppsEnvironment 'Microsoft.Web/kubeEnvironments@2021-02-01' = {
  name: '${resourcePrefix}-${environmentName}-ctrapps'
  location: containerAppLocation
  properties: {
    type: 'managed'
    internalLoadBalancerEnabled: false
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: LogAnalyticsWorkspace.properties.customerId
        sharedKey: LogAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    containerAppsConfiguration: {
      daprAIInstrumentationKey: ContainerAppsAppInsights.properties.InstrumentationKey
    }
  }
}


resource SqlDatabaseServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: databaseServerName
  location: location
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

resource Apim 'Microsoft.ApiManagement/service@2021-04-01-preview' = {
  location: location
  name: apimName
  sku: {
    capacity:0
    name: 'Consumption'
  }
  properties: {
    publisherEmail: apimPublishedEmail
    publisherName: 'ApimPublisher'
  }
}

output serverFarmId string = QuickStartServerFarm.id
output databaseServerName string = databaseServerName
output logAnalyticsWorkspaceId string = LogAnalyticsWorkspace.id
output containerEnvironmentId string = ContainerAppsEnvironment.id
output apimId string = Apim.id
