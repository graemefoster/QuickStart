targetScope = 'subscription'

param resourcePrefix string
param environmentName string
param location string = deployment().location

//fetch platform information
resource PlatformMetadata 'Microsoft.Resources/deployments@2022-09-01' existing = {
  name: 'quickstart-platform-${resourcePrefix}-${environmentName}'
}

resource apiResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${resourcePrefix}-api-${environmentName}-rg'
  location: location
}

module ApiDeployment './Tier2/api/main.bicep' = {
  name: '${deployment().name}-api'
  scope: apiResourceGroup
  params: {
    environmentName: environmentName
    resourcePrefix: resourcePrefix
    platformResourceGroupName: PlatformMetadata.properties.outputs.platformResourceGroupName.value
    location: location
  }
}

resource appResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${resourcePrefix}-app-${environmentName}-rg'
  location: location
}

module AppDeployment './Tier2/app/main.bicep' = {
  name: '${deployment().name}-app'
  scope: appResourceGroup
  params: {
    environmentName: environmentName
    resourcePrefix: resourcePrefix
    location: location
  }
}
