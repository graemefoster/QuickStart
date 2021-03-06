targetScope = 'subscription'

@description('A prefix to add to all resources to keep them unique')
@minLength(3)
@maxLength(6)
param resourcePrefix string

@description('The resource group that platform components were deployed to. Template assume s Sql Server is in here, and databases must be deployed to the same resource group.')
param platformResourceGroupName string

@description('Resource Id of the App Service Plan hosting the apis / apps')
param serverFarmId string

@description('Resource Id of the Platform Log Analytics Workspace')
param logAnalyticsWorkspaceId string

@description('Resource name of the platform Sql Server')
param databaseServerName string

@description('Used to construct app / api / keyvault names. Suggestions include test, prod, nonprod')
param environmentName string

@description('Resource Id of the Container Environment')
param containerEnvironmentId string

var hasSlot = environmentName != 'test'

resource platformResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: platformResourceGroupName
  location: deployment().location
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${resourcePrefix}-${environmentName}-rg'
  location: deployment().location
}

// Databases need to live in the same resource group as the server. We could push the server into the API RG
// but its quite common to use a sql server pool, and have many databases for different apis / apps contained in it.
// For this Quickstart the approach taken is to keep the server in the platform, and put the databases with it.
module DatabaseDeployment './Tier2/deploy-api-database.bicep' = {
  name: 'DeployDatabase'
  scope: platformResourceGroup
  params: {
    resourcePrefix: resourcePrefix
    databaseServerName: databaseServerName
    environmentName: environmentName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

module WebApiDeployment './Tier2/deploy-api.bicep' = {
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

module WebAppDeployment './Tier2/deploy-app.bicep' = {
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

module StaticAppDeployment './Tier2/deploy-static-app.bicep' = {
  name: 'DeployStaticApp'
  scope: resourceGroup
  params: {
    resourcePrefix: resourcePrefix
    serverFarmId: serverFarmId
    environmentName: environmentName
    deploySlot: hasSlot
  }
}

module ContainerAppDeployment './Tier2/deploy-container-app.bicep' = {
  name: 'DeployContainerApp'
  scope: resourceGroup
  params: {
    containerAppName: 'microservice-${environmentName}'
    //not ideal but I don't have a built image at this point so need something to get it moving
    containerImage: 'ghcr.io/graemefoster/sample-microservice:latest'
    environmentId: containerEnvironmentId
  }
}

output resourceGroupName string = resourceGroup.name
output applicationHostname string = WebAppDeployment.outputs.appHostname
output apiHostname string = WebApiDeployment.outputs.apiHostname
output spaHostname string = StaticAppDeployment.outputs.appHostname
output containerAppFqdn string = ContainerAppDeployment.outputs.containerAppFqdn
output applicationKeyVaultName string = WebAppDeployment.outputs.appKeyVaultName
output databaseName string = DatabaseDeployment.outputs.apiDatabaseName
output databaseConnectionString string = DatabaseDeployment.outputs.apiDatabaseConnectionString
output managedIdentityAppId string = WebApiDeployment.outputs.managedIdentityAppId
output managedIdentityName string = WebApiDeployment.outputs.managedIdentityName
output apiAppInsightsKey string = WebApiDeployment.outputs.appInsightsKey
output appAppInsightsKey string = WebAppDeployment.outputs.appInsightsKey
