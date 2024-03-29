targetScope = 'subscription'

param location string = deployment().location

param resourcePrefix string
param environmentName string

//assume outputs exist.
resource AppsMetadata 'Microsoft.Resources/deployments@2022-09-01' existing = {
  name: '${resourcePrefix}-${environmentName}-apps'
}
//assume outputs exist.
resource PlatformMetadata 'Microsoft.Resources/deployments@2022-09-01' existing = {
  name: '${resourcePrefix}-${environmentName}-platform'
}

module config 'Tier3/main.bicep' = {
  name: '${deployment().name}-config'
  scope: subscription()
  params: {
    environmentName: PlatformMetadata.properties.outputs.environmentName.value
    resourcePrefix: PlatformMetadata.properties.outputs.resourcePrefix.value
    apimResourceGroupName: PlatformMetadata.properties.outputs.platformResourceGroupName.value
    logAnalyticsWorkspaceId: PlatformMetadata.properties.outputs.logAnalyticsWorkspaceId.value
    appFqdn: AppsMetadata.properties.outputs.appFqdn.value
    spaFqdn: AppsMetadata.properties.outputs.spaFqdn.value
    appSlotFqdn: AppsMetadata.properties.outputs.appSlotFqdn.value
    spaSlotFqdn: AppsMetadata.properties.outputs.spaSlotFqdn.value
    apiFqdn: AppsMetadata.properties.outputs.apiFqdn.value
    location: location

    appConsumerKeyVaultName: AppsMetadata.properties.outputs.appKeyVaultName.value
    appConsumerSecretName: AppsMetadata.properties.outputs.appApiKeySecretName.value
    appResourceGroupName: AppsMetadata.properties.outputs.appResourceGroupName.value

    spaConsumerKeyVaultName: AppsMetadata.properties.outputs.spaKeyVaultName.value
    spaConsumerSecretName: AppsMetadata.properties.outputs.spaApiKeySecretName.value
    spaResourceGroupName: AppsMetadata.properties.outputs.spaResourceGroupName.value
  }
}
