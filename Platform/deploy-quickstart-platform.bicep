targetScope = 'subscription'

param resourceSuffix string
param databaseAdministratorName string
param databaseAdministratorObjectId string

var platformRgName = '${resourceSuffix}-platform-rg'

resource platformResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: platformRgName
  location: deployment().location
}

module PlatformDeployment './core/deploy-platform.bicep' = {
  name: 'DeployPlatform'
  scope: platformResourceGroup
  params: {
    resourceSuffix: resourceSuffix
    databaseAdministratorName: databaseAdministratorName
    databaseAdministratorObjectId: databaseAdministratorObjectId
  }
}

output platformResourceGroupName string = platformRgName
output serverFarmId string = PlatformDeployment.outputs.serverFarmId
output databaseServerName string = PlatformDeployment.outputs.databaseServerName

