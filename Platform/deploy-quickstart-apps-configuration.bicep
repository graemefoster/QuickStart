targetScope = 'subscription'

@description('Resource name of the platform Sql Server')
param databaseServerName string

@description('The resource group containing the apps / apis to configure.')
param resourceGroupName string

@description('The database name the API uses.')
param databaseName string

@description('The full hostname of the app-service hosting the Web Application')
param appHostname string

@description('The full hostname of the app-service hosting the Web API')
param apiHostname string

@description('The fully qualified domain name of the container app hosting the entry micro-service')
param containerAppFqdn string

@description('The full hostname of the app-service hosting the SPA')
param spaHostname string

@description('The platform resource name of the KeyVault used by the Web App')
param appKeyVaultName string

@description('The AAD application Id representing the Web Application')
param appClientId string

@description('The AAD application Id representing the Web API')
param apiClientId string

@description('The Managed Identity App Id assigned to the API (used to connect to SQL database)')
param apiUserAssignedClientId string

@description('The App Insights Key for the Application')
param apiAppInsightsKey string

@description('The App Insights Key for the API')
param appAppInsightsKey string

@description('The environment being configured')
param environmentName string

@secure()
@description('AAD Client Secret (required for the Web Application to perform a 3 legged oauth flow)')
param appClientSecret string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: deployment().location
}

module PostConfigureApiDeployment './Tier2/configure-api.bicep' = {
  name: 'PostConfigureApiDeployment'
  scope: resourceGroup
  params: {
    databaseServerName: databaseServerName
    databaseName: databaseName
    appHostname: appHostname
    apiHostname: apiHostname
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
    apiHostname: apiHostname
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
    apiHostname: apiHostname
    appAadClientId: appClientId
    spaHostname: spaHostname
    apiAadClientId: apiClientId
    appAppInsightsKey: appAppInsightsKey
    environmentName: environmentName
    containerAppFqdn: containerAppFqdn
  }
}
