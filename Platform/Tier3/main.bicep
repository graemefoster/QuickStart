targetScope = 'subscription'

param apimResourceGroupName string
param appResourceGroupName string
param spaResourceGroupName string
param apiFqdn string
param appFqdn string
param spaFqdn string
param appSlotFqdn string
param spaSlotFqdn string
param environmentName string
param resourcePrefix string

param appConsumerKeyVaultName string
param appConsumerSecretName string
param spaConsumerKeyVaultName string
param spaConsumerSecretName string

param location string = deployment().location

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
    appConsumerKeyVaultResourceGroup: appResourceGroupName
    appConsumerKeyVaultName: appConsumerKeyVaultName
    appConsumerSecretName: appConsumerSecretName
    spaConsumerKeyVaultResourceGroup: spaResourceGroupName
    spaConsumerKeyVaultName: spaConsumerKeyVaultName
    spaConsumerSecretName: spaConsumerSecretName
  }
}
