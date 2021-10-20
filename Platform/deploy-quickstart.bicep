targetScope = 'subscription'

param resourceSuffix string
param databaseAdministratorName string
param databaseAdministratorObjectId string

resource platformResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${resourceSuffix}-platform-rg'
  location: deployment().location
}

resource apiResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${resourceSuffix}-api-rg'
  location: deployment().location
}

resource appResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${resourceSuffix}-app-rg'
  location: deployment().location
}

module PlatformDeployment './deploy-platform.bicep' = {
  name: 'DeployPlatform'
  scope: platformResourceGroup
  params: {
    resourceSuffix: resourceSuffix
    databaseAdministratorName: databaseAdministratorName
    databaseAdministratorObjectId: databaseAdministratorObjectId
  }
}

module WebApiDeployment './deploy-api.bicep' = {
  name: 'DeployApi'
  scope: apiResourceGroup
  params: {
    resourceSuffix: resourceSuffix
    databaseServerName: PlatformDeployment.outputs.databaseServerName
    serverFarmId: PlatformDeployment.outputs.serverFarmId
  }
}

module WebAppDeployment './deploy-app.bicep' = {
  name: 'DeployApp'
  scope: appResourceGroup
  params: {
    resourceSuffix: resourceSuffix
    productionApiHostname: WebApiDeployment.outputs.productionApiHostname
    testApiHostname: WebApiDeployment.outputs.testApiHostname
    serverFarmId: PlatformDeployment.outputs.serverFarmId
  }
}

module PostConfigureApiDeployment './configure-api.bicep' = {
  name: 'PostConfigureApiDeployment'
  scope: apiResourceGroup
  params: {
    resourceSuffix: resourceSuffix
    databaseServerName: PlatformDeployment.outputs.databaseServerName
    productionAppHostname: WebAppDeployment.outputs.productionAppHostname
    testAppHostname: WebAppDeployment.outputs.testAppHostname
  }
}
