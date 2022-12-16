targetScope = 'resourceGroup'

param resourcePrefix string
param databaseAdministratorName string
param databaseAdministratorObjectId string
param environmentName string
param apimPublisherEmail string
param location string = resourceGroup().location
param platformRgName string

var hasSlot = environmentName != 'test'

module platformRg '../rg.bicep' = {
  name: '${deployment().name}-platformrg'
  scope: subscription()
  params: {
    resourceGroupName: platformRgName
    location: location
  }
}

module PlatformDeployment './inner.bicep' = {
  name: 'DeployPlatform'
  scope: resourceGroup(platformRgName)
  params: {
    location: location
    resourcePrefix: resourcePrefix
    databaseAdministratorName: databaseAdministratorName
    databaseAdministratorObjectId: databaseAdministratorObjectId
    environmentName: environmentName
    hasSlot: hasSlot
    apimPublishedEmail: apimPublisherEmail
  }
}

output platformResourceGroupName string = platformRgName
output platformMetadataResourceGroupName string = resourceGroup().name
output serverFarmId string = PlatformDeployment.outputs.serverFarmId
output databaseServerName string = PlatformDeployment.outputs.databaseServerName
output logAnalyticsWorkspaceId string = PlatformDeployment.outputs.logAnalyticsWorkspaceId
output containerEnvironmentId string = PlatformDeployment.outputs.containerEnvironmentId
output apimHostname string = PlatformDeployment.outputs.apimHostname
output resourcePrefix string = resourcePrefix
output databaseAdministratorName string = databaseAdministratorName
output environmentName string = environmentName
