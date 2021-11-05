targetScope = 'subscription'

@description('A prefix to add to all resources to keep them unique')
@minLength(3)
@maxLength(6)
param resourcePrefix string

@description('Resource Id of the Platform Log Analytics Workspace')
param logAnalyticsWorkspaceId string

@description('Used to construct app / api / keyvault names. Suggestions include test, prod, nonprod')
param environmentName string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${resourcePrefix}-${environmentName}-rg'
  location: deployment().location
}

// Databases need to live in the same resource group as the server. We could push the server into the API RG
// but its quite common to use a sql server pool, and have many databases for different apis / apps contained in it.
// For this Quickstart the approach taken is to keep the server in the platform, and put the databases with it.
module DatabaseDeployment './deploy-api-database.bicep' = {
  name: 'DeployDatabase'
  scope: platformResourceGroup
  params: {
    resourcePrefix: resourcePrefix
    databaseServerName: databaseServerName
    environmentName: environmentName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

module WebApiDeployment './deploy-api.bicep' = {
  name: 'DeployApi'
  scope: resourceGroup
  params: {
    resourcePrefix: resourcePrefix
    serverFarmId: serverFarmId
    environmentName : environmentName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    deploySlot: hasSlot
  }
}

module WebAppDeployment './deploy-app.bicep' = {
  name: 'DeployApp'
  scope: resourceGroup
  params: {
    resourcePrefix: resourcePrefix
    serverFarmId: serverFarmId
    environmentName: environmentName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    deploySlot: hasSlot
  }
}

output resourceGroupName string = resourceGroup.name
output applicationHostname string = WebAppDeployment.outputs.appHostname
output apiHostname string = WebApiDeployment.outputs.apiHostname
output applicationKeyVaultName string = WebAppDeployment.outputs.appKeyVaultName
output databaseName string = DatabaseDeployment.outputs.apiDatabaseName
output databaseConnectionString string = DatabaseDeployment.outputs.apiDatabaseConnectionString
output managedIdentityAppId string = WebApiDeployment.outputs.managedIdentityAppId
output managedIdentityName string = WebApiDeployment.outputs.managedIdentityName
output apiAppInsightsKey string = WebApiDeployment.outputs.appInsightsKey
output appAppInsightsKey string = WebAppDeployment.outputs.appInsightsKey
