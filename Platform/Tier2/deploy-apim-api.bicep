param resourcePrefix string
param environmentName string
param logAnalyticsWorkspaceId string

var apimServiceName = '${resourcePrefix}-${environmentName}-apim'

resource Api 'Microsoft.ApiManagement/service/apis@2021-04-01-preview' = {
  name: '${apimServiceName}/SampleApi'
  properties: {
    protocols: [
      'https'
    ]
    path: 'SampleApi'
    apiType: 'http'
    description: 'Sample Api backed by app-service'
    subscriptionRequired: true
    displayName: 'SampleApi'
  }
}

resource ApimApiInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${apimServiceName}-sampleapi-appi'
  location: resourceGroup().location
  kind: 'Api'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

resource ApiAppInsights 'Microsoft.ApiManagement/service/loggers@2021-04-01-preview' = {
  name: '${apimServiceName}/sample-api-logger'
  dependsOn: [
    Api
  ]
  properties: {
    loggerType: 'applicationInsights'
    resourceId: ApimApiInsights.id
  }
}
