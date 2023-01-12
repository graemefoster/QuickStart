targetScope = 'resourceGroup'

param resourcePrefix string
param environmentName string

param apiFqdn string

param appFqdn string
param spaFqdn string
param appSlotFqdn string
param spaSlotFqdn string

param consumerKeyVaultResourceGroup string
param consumerKeyVaultName string
param consumerSecretName string

param location string = resourceGroup().location

//fetch platform information
resource PlatformMetadata 'Microsoft.Resources/deployments@2022-09-01' existing = {
  name: 'quickstart-platform-${resourcePrefix}-${environmentName}'
  scope: subscription()
}

var logAnalyticsWorkspaceId = PlatformMetadata.properties.outputs.logAnalyticsWorkspaceId.value


var apimServiceName = '${resourcePrefix}-${environmentName}-apim'
var productName = 'PetsProduct'
var apimApiName = 'pets'

var cors0 = 'https://${appFqdn}'
var cors1 = 'https://${appSlotFqdn}'
var cors2 =  'https://${spaFqdn}'
var cors3 =  'https://${spaSlotFqdn}'

resource ApimApiAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${apimServiceName}-${apimApiName}-appi'
  location: location
  kind: 'Api'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

resource ApiAppInsights 'Microsoft.ApiManagement/service/loggers@2021-04-01-preview' = {
  name: '${apimServiceName}/${apimApiName}-logger'
  properties: {
    loggerType: 'applicationInsights'
    resourceId: ApimApiAppInsights.id
    credentials: {
      instrumentationKey: ApimApiAppInsights.properties.InstrumentationKey
    }
  }
}

resource Api 'Microsoft.ApiManagement/service/apis@2021-04-01-preview' = {
  name: '${apimServiceName}/${apimApiName}'
  properties: {
    protocols: [
      'https'
    ]
    path: 'Pets'
    apiType: 'http'
    description: 'Pets Api backed by app-service'
    subscriptionRequired: true
    displayName: 'PetsApi'
    serviceUrl: 'https://${apiFqdn}/pets'
  }

  resource CorsPolicy 'policies@2021-04-01-preview' = {
    name: 'policy'
    properties: {
      format: 'xml'
      value: '<policies><inbound><cors><allowed-origins><origin>${cors0}</origin><origin>${cors1}</origin><origin>${cors2}</origin><origin>${cors3}</origin></allowed-origins><allowed-methods><method>GET</method><method>POST</method></allowed-methods><allowed-headers><header>*</header></allowed-headers></cors></inbound><backend><forward-request /></backend><outbound /><on-error /></policies>'
    }
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
  name: '${apimServiceName}/${productName}'
  properties: {
    displayName: 'Access to the Pets Product'
    approvalRequired: true
    subscriptionRequired: true
    state: 'published'
  }

  resource PetsApi 'apis@2021-04-01-preview' = {
    name: apimApiName
  }
}

resource PetsApiSubscription 'Microsoft.ApiManagement/service/subscriptions@2021-04-01-preview' = {
  name: '${apimServiceName}/PetsSubscription'
  properties: {
    displayName: 'Pets Subscription'
    scope: '/products/${PetsApiProduct.id}'
  }
}

module consumerApiKeySecret 'subscription-secret.bicep' = {
  name: '${deployment().name}-secret'
  scope: subscription()
  params: {
    consumerKeyVaultName: consumerKeyVaultName
    consumerKeyVaultResourceGroupName: consumerKeyVaultResourceGroup
    secretName: consumerSecretName
    subscriptionPrimaryKey: PetsApiSubscription.listSecrets().primaryKey
  }
}