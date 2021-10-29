targetScope = 'subscription'

@description('A prefix to add to all resources to keep them unique')
@minLength(3)
@maxLength(6)
param resourcePrefix string

@description('AAD Service Principal name to set as the database administrator. This principal will be used to deploy databases to the server.')
param databaseAdministratorName string
@description('AAD Object Id of the Service Principal used as the database administrator.')
param databaseAdministratorObjectId string

var platformRgName = '${resourcePrefix}-platform-rg'

resource platformResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: platformRgName
  location: deployment().location
}

module PlatformDeployment './deploy-platform.bicep' = {
  name: 'DeployPlatform'
  scope: platformResourceGroup
  params: {
    resourcePrefix: resourcePrefix
    databaseAdministratorName: databaseAdministratorName
    databaseAdministratorObjectId: databaseAdministratorObjectId
  }
}

output platformResourceGroupName string = platformRgName
output serverFarmId string = PlatformDeployment.outputs.serverFarmId
output databaseServerName string = PlatformDeployment.outputs.databaseServerName
output logAnalyticsWorkspaceId string = PlatformDeployment.outputs.logAnalyticsWorkspaceId
