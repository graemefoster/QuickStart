targetScope = 'subscription'

param resourceSuffix string
param platformResourceGroupName string
param serverFarmId string
param databaseServerName string
param environmentName string

var hasSlot = !not(equals(environmentName, 'test'))

resource platformResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: platformResourceGroupName
  location: deployment().location
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${resourceSuffix}-${environmentName}-rg'
}

resource prodResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${resourceSuffix}-prod-rg'
  location: deployment().location
}

// Databases need to live in the same resource group as the server. We could push the server into the API RG
// but its quite common to use a sql server pool, and have many databases for different apis / apps contained in it.
// For this Quickstart the approach taken is to keep the server in the platform, and put the databases with it.
module DatabaseDeployment './deploy-api-database.bicep' = {
  name: 'DeployDatabase'
  scope: platformResourceGroupName
  params: {
    resourceSuffix: resourceSuffix
    databaseServerName: databaseServerName
    environmentName: environmentName
  }
}

module WebApiDeployment './deploy-api.bicep' = {
  name: 'DeployApi'
  scope: resourceGroup
  params: {
    resourceSuffix: resourceSuffix
    serverFarmId: serverFarmId
    environmentName : environmentName
    deploySlot: hasSlot
  }
}

module WebAppDeployment './deploy-app.bicep' = {
  name: 'DeployApp'
  scope: resourceGroup
  params: {
    resourceSuffix: resourceSuffix
    serverFarmId: serverFarmId
    environmentName: environmentName,
    deploySlot: hasSlot
  }
}

output apiResourceGroupName string = apiResourceGroup.name
output appResourceGroupName string = appResourceGroup.name
output applicationHostname string = WebAppDeployment.outputs.appHostname
output apiHostname string = WebApiDeployment.outputs.apiHostname
output applicationKeyVaultName string = WebAppDeployment.outputs.appKeyVaultName
output databaseName string = DatabaseDeployment.outputs.apiDatabaseName
output databaseConnectionString string = DatabaseDeployment.outputs.apiDatabaseConnectionString
output managedIdentityAppId string = WebApiDeployment.outputs.managedIdentityAppId
output managedIdentityName string = WebApiDeployment.outputs.managedIdentityName
