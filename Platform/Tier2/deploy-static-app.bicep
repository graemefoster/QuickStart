param resourcePrefix string
param serverFarmId string
param environmentName string
param deploySlot bool
param logAnalyticsWorkspaceId string
param location string = resourceGroup().location

var appHostname = '${resourcePrefix}-${uniqueString(resourceGroup().name)}-${environmentName}-spa'


resource WebAppAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${appHostname}-appi'
  location: location
  kind: 'Web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

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
    }
  }
}

resource WebAppGreen 'Microsoft.Web/sites/slots@2021-01-15' = if(deploySlot) {
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
    }
  }
}

output appHostname string = appHostname
output appInsightsKey string = reference(WebAppAppInsights.id).InstrumentationKey
