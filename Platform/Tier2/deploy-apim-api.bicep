param resourcePrefix string
param environmentName string
param logAnalyticsWorkspaceId string
param webApiHostname string

var apimServiceName = '${resourcePrefix}-${environmentName}-apim'
var productName = 'PetsProduct'
var apiName = 'pets'

resource ApimApiAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${apimServiceName}-${apiName}-appi'
  location: resourceGroup().location
  kind: 'Api'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

resource ApiAppInsights 'Microsoft.ApiManagement/service/loggers@2021-04-01-preview' = {
  name: '${apimServiceName}/${apiName}-logger'
  properties: {
    loggerType: 'applicationInsights'
    resourceId: ApimApiAppInsights.id
    credentials: {
      instrumentationKey: ApimApiAppInsights.properties.InstrumentationKey
    }
  }
}

resource Api 'Microsoft.ApiManagement/service/apis@2021-04-01-preview' = {
  name: '${apimServiceName}/${apiName}'
  properties: {
    protocols: [
      'https'
    ]
    path: 'Pets'
    apiType: 'http'
    description: 'Pets Api backed by app-service'
    subscriptionRequired: true
    displayName: 'PetsApi'
    serviceUrl: 'https://${webApiHostname}.azurewebsites.net/'
  }

  resource ApiOperation 'operations@2021-04-01-preview' = {
    name: 'GetPets'
    properties: {
      displayName: 'Get Pets'
      method: 'GET'
      urlTemplate: '/Pets'
    }
  }

  resource ApiAppInsightsLogging 'diagnostics@2021-04-01-preview' = {
    name: 'applicationinsights'
    properties: {
      loggerId: ApiAppInsights.id
      httpCorrelationProtocol: 'W3C'
    }
  }
}

resource PetsApiProduct 'Microsoft.ApiManagement/service/products@2021-04-01-preview' = {
  name: '${apimServiceName}/${productName}'
  properties: {
    displayName: 'Access to the Pets Product'
    approvalRequired: true
    subscriptionRequired: true
    state: 'published'
  }

  resource PetsApi 'apis@2021-04-01-preview' = {
    name: apiName
  }
}

resource PetsApiSubscription 'Microsoft.ApiManagement/service/subscriptions@2021-04-01-preview' = {
  name: '${apimServiceName}/PetsSubscription'
  properties: {
    displayName: 'Pets Subscription'
    scope: '/products/${PetsApiProduct.id}'
  }
}

output productSubscriptionKey string = PetsApiSubscription.properties.primaryKey
