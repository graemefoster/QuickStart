targetScope = 'resourceGroup'

param resourcePrefix string
param environmentName string
param location string = resourceGroup().location

//fetch platform information
resource PlatformMetadata 'Microsoft.Resources/deployments@2022-09-01' existing = {
  name: 'platform'
}

var apiRgName = '${resourcePrefix}-api-${environmentName}-rg'
module apiResourceGroup '../rg.bicep' = {
  name: '${deployment().name}-apimrg'
  scope: subscription()
  params: {
    resourceGroupName: apiRgName
    location: location
  }
}

module ApiDeployment './api/main.bicep' = {
  name: '${deployment().name}-api'
  scope: resourceGroup(apiRgName)
  params: {
    environmentName: environmentName
    resourcePrefix: resourcePrefix
    platformResourceGroupName: PlatformMetadata.properties.outputs.platformResourceGroupName.value
    databaseServerName: PlatformMetadata.properties.outputs.databaseServerName.value
    logAnalyticsWorkspaceId: PlatformMetadata.properties.outputs.logAnalyticsWorkspaceId.value
    serverFarmId: PlatformMetadata.properties.outputs.serverFarmId.value
    location: location
  }
}

var microserviceRgName = '${resourcePrefix}-microservice-${environmentName}-rg'
module microserviceResourceGroup '../rg.bicep' = {
  name: '${deployment().name}-microservicerg'
  scope: subscription()
  params: {
    resourceGroupName: microserviceRgName
    location: location
  }
}

module MicroServiceDeployment './microservice/main.bicep' = {
  name: '${deployment().name}-microservice'
  scope: resourceGroup(microserviceRgName)
  params: {
    location: location
    environmentId: PlatformMetadata.properties.outputs.containerEnvironmentId.value
    containerAppName: 'pet-ownership'
    containerImage: 'ghcr.io/graemefoster/sample-microservice:latest'
  }
}

var appRgName = '${resourcePrefix}-app-${environmentName}-rg'
module appResourceGroup '../rg.bicep' = {
  name: '${deployment().name}-apprg'
  scope: subscription()
  params: {
    resourceGroupName: appRgName
    location: location
  }
}

module AppDeployment './app/main.bicep' = {
  name: '${deployment().name}-app'
  scope: resourceGroup(appRgName)
  params: {
    environmentName: environmentName
    resourcePrefix: resourcePrefix
    location: location
    logAnalyticsWorkspaceId: PlatformMetadata.properties.outputs.logAnalyticsWorkspaceId.value
    serverFarmId: PlatformMetadata.properties.outputs.serverFarmId.value
    containerAppFqdn:MicroServiceDeployment.outputs.containerAppFqdn
    apiHostName: PlatformMetadata.properties.outputs.apimHostname.value
  }
}

var spaRgName = '${resourcePrefix}-spa-${environmentName}-rg'
module spaResourceGroup '../rg.bicep' = {
  name: '${deployment().name}-sparg'
  scope: subscription()
  params: {
    resourceGroupName: spaRgName
    location: location
  }
}

module SpaDeployment './spa/main.bicep' = {
  name: '${deployment().name}-spa'
  scope: resourceGroup(appRgName)
  params: {
    environmentName: environmentName
    resourcePrefix: resourcePrefix
    location: location
    logAnalyticsWorkspaceId: PlatformMetadata.properties.outputs.logAnalyticsWorkspaceId.value
    serverFarmId: PlatformMetadata.properties.outputs.serverFarmId.value

  }
}

output appName string = AppDeployment.outputs.appName
output appFqdn string = AppDeployment.outputs.appHostname
output spaFqdn string = SpaDeployment.outputs.appHostname
output apiFqdn string = ApiDeployment.outputs.appHostname
output appSlotFqdn string = AppDeployment.outputs.appSlotHostname
output spaSlotFqdn string = SpaDeployment.outputs.appSlotHostname
output apiSlotFqdn string = ApiDeployment.outputs.appSlotHostname
output microserviceFqdn string = MicroServiceDeployment.outputs.containerAppFqdn

output appResourceGroupName string = appRgName
output appKeyVaultName string = AppDeployment.outputs.appKeyVaultName
output apiKeySecretName string = AppDeployment.outputs.apiKeySecretName
