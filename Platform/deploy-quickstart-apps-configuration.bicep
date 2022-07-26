targetScope = 'subscription'

@description('The AAD application Id representing the Web Application')
param appClientId string

@description('The AAD application Id representing the Web API')
param apiClientId string

@secure()
@description('AAD Client Secret (required for the Web Application to perform a 3 legged oauth flow)')
param appClientSecret string

@description('The environment being configured')
param environmentName string

param location string = deployment().location

var platform = loadJsonContent('./outputs-platform.json')
var apps = loadJsonContent('./outputs-apps.json')

var databaseServerName = platform.outputs.databaseServerName.value
var resourceGroupName = apps.outputs.resourceGroupName.value
var databaseName = apps.outputs.databaseName.value
var appHostname = apps.outputs.applicationHostname.value
var apimHostname = platform.outputs.apimHostname.value

var apiName = apps.outputs.apiName.value
var containerAppFqdn = apps.outputs.containerAppFqdn.value
var spaHostname = apps.outputs.spaHostname.value
var appKeyVaultName = apps.outputs.applicationKeyVaultName.value

var apiUserAssignedClientId = apps.outputs.managedIdentityAppId.value
var apiAppInsightsKey = apps.outputs.apiAppInsightsKey.value
var appAppInsightsKey = apps.outputs.appAppInsightsKey.value
var spaAppInsightsKey = apps.outputs.spaAppInsightsKey.value


resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

resource appsKv 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: apps.outputs.applicationKeyVaultName.value
  scope: resourceGroup
}

module PostConfigureApiDeployment './Tier2/configure-api.bicep' = {
  name: 'PostConfigureApiDeployment'
  scope: resourceGroup
  params: {
    databaseServerName: databaseServerName
    databaseName: databaseName
    appHostname: appHostname
    apiName: apiName
    apiAadClientId: apiClientId
    userAssignedClientId: apiUserAssignedClientId
    apiAppInsightsKey: apiAppInsightsKey
    environmentName: environmentName
    spaHostname: spaHostname
  }
}

module PostConfigureAppDeployment './Tier2/configure-app.bicep' = {
  name: 'PostConfigureAppDeployment'
  scope: resourceGroup
  params: {
    apiHostname: apimHostname
    productSubscriptionKey: appsKv.getSecret('productSubscriptionKey')
    appAadClientId: appClientId
    appClientSecret: appClientSecret
    appHostname: appHostname
    appKeyVaultName: appKeyVaultName
    apiAadClientId: apiClientId
    appAppInsightsKey: appAppInsightsKey
    environmentName: environmentName
    containerAppFqdn: containerAppFqdn
  }
}

module PostConfigureSpaDeployment './Tier2/configure-static-app.bicep' = {
  name: 'PostConfigureSpaDeployment'
  scope: resourceGroup
  params: {
    apiHostname: apimHostname
    productSubscriptionKey: appsKv.getSecret('productSubscriptionKey')
    appAadClientId: appClientId
    spaHostname: spaHostname
    apiAadClientId: apiClientId
    appAppInsightsKey: spaAppInsightsKey
    environmentName: environmentName
    containerAppFqdn: containerAppFqdn
  }
}
