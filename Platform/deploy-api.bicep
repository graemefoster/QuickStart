param resourcePrefix string
param serverFarmId string
param environmentName string
param logAnalyticsWorkspaceId string
param deploySlot bool

var apiHostname = '${resourcePrefix}-${uniqueString(resourceGroup().name)}-${environmentName}-api'
var apiMsiName = '${resourcePrefix}-${uniqueString(resourceGroup().name)}-${environmentName}-msi'

resource ManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  location:resourceGroup().location
  name: apiMsiName
}

resource WebApi 'Microsoft.Web/sites@2021-01-15' = {
  name: apiHostname
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${ManagedIdentity.id}' : {}
    }
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v5.0'
    }
  }
}

resource WebAppAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${apiHostname}-appi'
  location: resourceGroup().location
  kind: 'Web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

resource WebAppInsightsHealthCheck 'Microsoft.Insights/webtests@2020-10-05-preview' = {
  location: resourceGroup().location
  name: 'webapp-ping-test'
  kind: 'ping'
  properties: {
    Kind: 'ping'
    Frequency: 300
    Name: 'webapp-ping-test'
    Timeout: 10
    Description: 'Ping test on webapp'
    Enabled: true
    SyntheticMonitorId: 'webapp-ping-test'
    Request: {
      FollowRedirects:false
      HttpVerb: 'GET'
      RequestUrl: 'https://${apiHostname}.azurewebsites.net/health'
    }
    Locations: [
      {
        Id: 'emea-au-syd-edge'
      }
      {
        Id: 'apac-sg-sin-azr'
      }
    ]
  }
}

resource WebApiGreen 'Microsoft.Web/sites/slots@2021-01-15' = if(deploySlot) {
  parent: WebApi
  name: 'green'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v5.0'
    }
  }
}

output apiHostname string = apiHostname
output managedIdentityName string = ManagedIdentity.name
output managedIdentityAppId string = ManagedIdentity.properties.clientId
output appInsightsKey string = reference(WebAppAppInsights.id).InstrumentationKey
