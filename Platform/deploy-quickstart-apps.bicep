targetScope = 'subscription'

param location string = deployment().location
param resourcePrefix string
param environmentName string
param appClientId string
param apiClientId string

@secure()
param appClientSecret string

//fetch platform information. Assumption that this is in a well known location
resource PlatformMetadata 'Microsoft.Resources/deployments@2022-09-01' existing = {
  name: '${resourcePrefix}-${environmentName}'
}

module inr './Tier2/main.bicep' = {
  name: '${deployment().name}-apps'
  params: {
    environmentName: PlatformMetadata.properties.outputs.environmentName.value
    resourcePrefix: PlatformMetadata.properties.outputs.resourcePrefix.value
    platformResourceGroupName: PlatformMetadata.properties.outputs.platformResourceGroupName.value
    singleResourceGroupDeployment: PlatformMetadata.properties.outputs.singleResourceGroupDeployment.value
    apimHostname: PlatformMetadata.properties.outputs.apimHostname.value
    containerEnvironmentId: PlatformMetadata.properties.outputs.containerEnvironmentId.value
    databaseServerName: PlatformMetadata.properties.outputs.databaseServerName.value
    logAnalyticsWorkspaceId: PlatformMetadata.properties.outputs.logAnalyticsWorkspaceId.value
    serverFarmId: PlatformMetadata.properties.outputs.serverFarmId.value
    location: location
    uniqueness: PlatformMetadata.properties.outputs.uniqueness.value
    appClientId: appClientId
    apiClientId: apiClientId
    appClientSecret: appClientSecret
  }
}

output appName string = inr.outputs.appName
output appFqdn string = inr.outputs.appFqdn
output spaFqdn string = inr.outputs.spaFqdn
output apiFqdn string = inr.outputs.apiFqdn
output appSlotFqdn string = inr.outputs.appSlotFqdn
output spaSlotFqdn string = inr.outputs.spaSlotFqdn
output apiSlotFqdn string = inr.outputs.apiSlotFqdn
output microserviceFqdn string = inr.outputs.microserviceFqdn
output appResourceGroupName string = inr.outputs.appResourceGroupName
output appKeyVaultName string = inr.outputs.appKeyVaultName
output apiKeySecretName string = inr.outputs.apiKeySecretName

