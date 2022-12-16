targetScope = 'resourceGroup'

param location string = resourceGroup().location

//fetch platform information
resource PlatformMetadata 'Microsoft.Resources/deployments@2022-09-01' existing = {
  name: 'platform'
}

module inr './Tier2/main.bicep' = {
  name: '${deployment().name}-inr'
  params: {
    environmentName: PlatformMetadata.properties.outputs.environmentName.value
    resourcePrefix: PlatformMetadata.properties.outputs.resourcePrefix.value
    location: location
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

