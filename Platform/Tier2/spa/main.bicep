param resourcePrefix string
param serverFarmId string
param environmentName string
param logAnalyticsWorkspaceId string
// param containerAppFqdn string
// param productSubscriptionKey string
// param apiHostname string
// param apiAadClientId string
// param appAadClientId string
param location string = resourceGroup().location

var appHostname = '${resourcePrefix}-${uniqueString(resourceGroup().name)}-${environmentName}-spa'
var deploySlot = environmentName != 'test'

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
  // {
  //   name: 'ApiSettings__MicroServiceUrl'
  //   value: 'https://${containerAppFqdn}'
  // }
  // {
  //   name: 'ApiSettings__SubscriptionKey'
  //   value: productSubscriptionKey
  // }
  // {
  //   name: 'ApiSettings__URL'
  //   value: 'https://${apiHostname}'
  // }
  // {
  //   name: 'ApiSettings__Scope'
  //   value: 'api://${apiAadClientId}/Pets.Manage'
  // }
  // {
  //   name: 'AzureAD__ClientId'
  //   value: appAadClientId
  // }
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

output appHostname string = WebApp.properties.hostNames[0]
output appSlotHostname string = deploySlot ? WebAppGreen.properties.hostNames[0] : ''
output appInsightsKey string = reference(WebAppAppInsights.id).InstrumentationKey
