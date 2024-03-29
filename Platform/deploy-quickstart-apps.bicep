targetScope = 'subscription'

param location string = deployment().location
param resourcePrefix string
param environmentName string
param appClientId string
param apiClientId string
param aadTenantId string

@secure()
param appClientSecret string

//fetch platform information. Assumption that this is in a well known location
resource PlatformMetadata 'Microsoft.Resources/deployments@2022-09-01' existing = {
  name: '${resourcePrefix}-${environmentName}-platform'
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
    aadTenantId: aadTenantId
  }
}

output appName string = inr.outputs.appName
output apiName string = inr.outputs.apiName
output spaName string = inr.outputs.spaName
output appFqdn string = inr.outputs.appFqdn
output spaFqdn string = inr.outputs.spaFqdn
output apiFqdn string = inr.outputs.apiFqdn
output appSlotFqdn string = inr.outputs.appSlotFqdn
output spaSlotFqdn string = inr.outputs.spaSlotFqdn
output apiSlotFqdn string = inr.outputs.apiSlotFqdn
output microserviceFqdn string = inr.outputs.microserviceFqdn
output containerAppName string = inr.outputs.containerAppName
output containerAppResourceGroup string = inr.outputs.containerAppResourceGroup
output appResourceGroupName string = inr.outputs.appResourceGroupName
output apiResourceGroupName string = inr.outputs.apiResourceGroupName
output appKeyVaultName string = inr.outputs.appKeyVaultName
output appApiKeySecretName string = inr.outputs.appApiKeySecretName
output spaResourceGroupName string = inr.outputs.spaResourceGroupName
output spaKeyVaultName string = inr.outputs.spaKeyVaultName
output spaApiKeySecretName string = inr.outputs.spaApiKeySecretName
output databaseConnectionString string = inr.outputs.databaseConnectionString
output managedIdentityAppId string = inr.outputs.managedIdentityAppId
output managedIdentityName string = inr.outputs.managedIdentityName
