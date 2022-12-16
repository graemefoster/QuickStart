targetScope = 'subscription'

param apimResourceGroupName string
param appResourceGroupName string
param apiFqdn string
param appFqdn string
param spaFqdn string
param appSlotFqdn string
param spaSlotFqdn string
param environmentName string
param resourcePrefix string

param consumerKeyVaultName string
param consumerSecretName string

param location string = deployment().location

param appName string
param appClientId string

param apiClientId string

module ApimConfiguration './Apim/main.bicep' = {
  name: '${deployment().name}-apim'
  scope: resourceGroup(apimResourceGroupName)
  params: {
    apiFqdn: apiFqdn
    appFqdn: appFqdn
    appSlotFqdn: appSlotFqdn
    spaFqdn: spaFqdn
    spaSlotFqdn: spaSlotFqdn
    environmentName: environmentName
    resourcePrefix: resourcePrefix
    location: location
    consumerKeyVaultName: consumerKeyVaultName
    consumerKeyVaultResourceGroup: appResourceGroupName
    consumerSecretName: consumerSecretName
  }
}

module AppConfiguration './App/main.bicep' = {
  name: '${deployment().name}-app'
  scope: resourceGroup(appResourceGroupName)
  params: {
    appClientId: appClientId
    apiClientId: apiClientId
    appName: appName
  }
}
