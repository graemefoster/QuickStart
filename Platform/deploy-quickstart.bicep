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

// Databases need to live in the same resource group as the server. We could push the server into the API RG
// but its quite common to use a sql server pool, and have many databases for different apis / apps contained in it.
// For this Quickstart the approach taken is to keep the server in the platform, and put the databases with it.
module DatabaseDeployment './deploy-api-database.bicep' = {
  name: 'DeployDatabase'
  scope: platformResourceGroup
  params: {
    resourceSuffix: resourceSuffix
    databaseServerName: PlatformDeployment.outputs.databaseServerName
  }
}

module WebApiDeployment './deploy-api.bicep' = {
  name: 'DeployApi'
  scope: apiResourceGroup
  params: {
    resourceSuffix: resourceSuffix
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

output testApplicationHostname string = WebAppDeployment.outputs.testAppHostname
output productionApplicationHostname string = WebAppDeployment.outputs.productionAppHostname
output testApiHostname string = WebApiDeployment.outputs.testApiHostname
output productionApiHostname string = WebApiDeployment.outputs.productionApiHostname

