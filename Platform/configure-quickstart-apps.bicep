targetScope = 'resourceGroup'

param location string = resourceGroup().location

param appClientId string = '123-123-12312'
param apiClientId string = '5756-56756-56756'


//assume outputs exist.
resource AppsMetadata 'Microsoft.Resources/deployments@2022-09-01' existing = {
  name: 'deploy-quickstart-apps'
}
//assume outputs exist.
resource PlatformMetadata 'Microsoft.Resources/deployments@2022-09-01' existing = {
  name: 'platform'
}

module config 'Tier3/main.bicep' = {
  name: '${deployment().name}-config'
  scope: subscription()
  params: {
    environmentName: PlatformMetadata.properties.outputs.environmentName.value
    resourcePrefix: PlatformMetadata.properties.outputs.resourcePrefix.value
    apimResourceGroupName: PlatformMetadata.properties.outputs.platformResourceGroupName.value
    appFqdn: AppsMetadata.properties.outputs.appFqdn.value
    spaFqdn: AppsMetadata.properties.outputs.spaFqdn.value
    appSlotFqdn: AppsMetadata.properties.outputs.appSlotFqdn.value
    spaSlotFqdn: AppsMetadata.properties.outputs.spaSlotFqdn.value
    apiFqdn: AppsMetadata.properties.outputs.apiFqdn.value
    location: location
    consumerKeyVaultName: AppsMetadata.properties.outputs.appKeyVaultName.value
    consumerSecretName: AppsMetadata.properties.outputs.apiKeySecretName.value
    apiClientId: apiClientId
    appClientId: appClientId
    appResourceGroupName: AppsMetadata.properties.outputs.appResourceGroupName.value
    appName: AppsMetadata.properties.outputs.appName.value
    
  }
}
