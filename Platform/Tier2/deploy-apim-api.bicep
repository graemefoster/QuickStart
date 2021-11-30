param resourcePrefix string
param environmentName string
param logAnalyticsWorkspaceId string
param webApiHostname string

var apimServiceName = '${resourcePrefix}-${environmentName}-apim'
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
    path: 'SampleApi'
    apiType: 'http'
    description: 'Sample Api backed by app-service'
    subscriptionRequired: true
    displayName: 'SampleApi'
    serviceUrl: 'https://${webApiHostname}/'
  }

  resource ApiOperation 'operations@2021-04-01-preview' = {
    name: 'GetPets'
    properties: {
      displayName: 'Get Pets'
      method: 'GET'
      urlTemplate: '/'
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
  name: '${apimServiceName}/PetsProduct'
  properties: {
    displayName: 'Access to the pets product'
    approvalRequired: true
    subscriptionRequired: true
    state: 'published'
  }
}

resource PetsApiSubscription 'Microsoft.ApiManagement/service/subscriptions@2021-04-01-preview' = {
  name: '${apimServiceName}/PetsSubscription'
  properties: {
    displayName: 'Pets Subscription'
    scope: '/products/${PetsApiProduct.id}'
  }
}

