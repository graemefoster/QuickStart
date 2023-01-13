targetScope = 'resourceGroup'

param resourcePrefix string
param serverFarmId string
param environmentName string
param logAnalyticsWorkspaceId string
param containerAppFqdn string
param apiHostname string
param apiAadClientId string
param appAadClientId string
param aadTenantId string
param location string = resourceGroup().location
param uniqueness string

var appHostname = '${resourcePrefix}-${uniqueness}-${environmentName}-spa'
var appKeyVaultName = '${resourcePrefix}-spa-${environmentName}-kv'
var deploySlot = environmentName != 'test'
var subscriptionSecretName = 'ApiSubscriptionKey'

resource AppKeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: appKeyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
  }
}

resource KeyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'aspDiagnostics'
  scope: AppKeyVault
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          days: 3
          enabled: true
        }
      }
    ]
  }
}


resource WebAppAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${appHostname}-appi'
  location: location
  kind: 'Web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

var settings = [
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: WebAppAppInsights.properties.InstrumentationKey
  }
  {
    name: 'ApiSettings__MicroServiceUrl'
    value: 'https://${containerAppFqdn}'
  }
  {
    name: 'ApiSettings__SubscriptionKey'
    value: '@Microsoft.KeyVault(VaultName=${AppKeyVault.name};SecretName=${subscriptionSecretName})'
  }
  {
    name: 'ApiSettings__URL'
    value: 'https://${apiHostname}'
  }
  {
    name: 'ApiSettings__Scope'
    value: 'api://${apiAadClientId}/Pets.Manage'
  }
  {
    name: 'AzureAD__ClientId'
    value: appAadClientId
  }
  {
    name: 'AzureAD__TenantId'
    value: aadTenantId
  }
]

resource WebApp 'Microsoft.Web/sites@2021-01-15' = {
  name: appHostname
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      nodeVersion: 'node|16-lts'
      appSettings: settings
    }
  }
}

resource WebAppGreen 'Microsoft.Web/sites/slots@2021-01-15' = if (deploySlot) {
  parent: WebApp
  name: 'green'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      nodeVersion: 'node|16-lts'
      appSettings: settings
    }
  }
}

output appName string = WebApp.name
output appHostname string = WebApp.properties.hostNames[0]
output appSlotHostname string = deploySlot ? WebAppGreen.properties.hostNames[0] : ''
output appInsightsKey string = reference(WebAppAppInsights.id).InstrumentationKey
output appKeyVaultName string = appKeyVaultName
output apiKeySecretName string = subscriptionSecretName
