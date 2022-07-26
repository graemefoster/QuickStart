targetScope = 'subscription'

@description('Used to construct app / api / keyvault names. Suggestions include test, prod, nonprod')
param environmentName string

param location string = deployment().location

var environment = loadJsonContent('./outputs-platform.json')
var resourcePrefix = environment.outputs.resourcePrefix.value

var hasSlot = environmentName != 'test'

resource platformResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: environment.outputs.platformResourceGroupName.value
  location: location
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${resourcePrefix}-${environmentName}-rg'
  location: location
}

// Databases need to live in the same resource group as the server. We could push the server into the API RG
// but its quite common to use a sql server pool, and have many databases for different apis / apps contained in it.
// For this Quickstart the approach taken is to keep the server in the platform, and put the databases with it.
module DatabaseDeployment './Tier2/deploy-api-database.bicep' = {
  name: 'DeployDatabase'
  scope: platformResourceGroup
  params: {
    location: location
    resourcePrefix: resourcePrefix
    databaseServerName: environment.outputs.databaseServerName.value
    environmentName: environmentName
    logAnalyticsWorkspaceId: environment.outputs.logAnalyticsWorkspaceId.value
  }
}

module WebApiDeployment './Tier2/deploy-api.bicep' = {
  name: 'DeployApi'
  scope: resourceGroup
  params: {
    location: location
    resourcePrefix: resourcePrefix
    serverFarmId: environment.outputs.serverFarmId.value
    environmentName: environmentName
    logAnalyticsWorkspaceId: environment.outputs.logAnalyticsWorkspaceId.value
    deploySlot: hasSlot
  }
}


module WebAppDeployment './Tier2/deploy-app.bicep' = {
  name: 'DeployApp'
  scope: resourceGroup
  params: {
    location: location
    resourcePrefix: resourcePrefix
    serverFarmId: environment.outputs.serverFarmId.value
    environmentName: environmentName
    logAnalyticsWorkspaceId: environment.outputs.logAnalyticsWorkspaceId.value
    deploySlot: hasSlot
  }
}

module StaticAppDeployment './Tier2/deploy-static-app.bicep' = {
  name: 'DeployStaticApp'
  scope: resourceGroup
  params: {
    location: location
    resourcePrefix: resourcePrefix
    serverFarmId: environment.outputs.serverFarmId.value
    environmentName: environmentName
    logAnalyticsWorkspaceId: environment.outputs.logAnalyticsWorkspaceId.value
    deploySlot: hasSlot
  }
}

module ContainerAppDeployment './Tier2/deploy-container-app.bicep' = {
  name: 'DeployContainerApp'
  scope: resourceGroup
  params: {
    location: location
    containerAppName: 'microservice-${environmentName}'
    //not ideal but I don't have a built image at this point so need something to get it moving
    containerImage: 'ghcr.io/graemefoster/sample-microservice:latest'
    environmentId: environment.outputs.containerEnvironmentId.value
  }
}


module ApimApiDeployment './Tier2/deploy-apim-api.bicep' = {
  name: 'DeployApimApi'
  scope: platformResourceGroup
  params: {
    location: location
    resourcePrefix: resourcePrefix
    environmentName: environmentName
    logAnalyticsWorkspaceId: environment.outputs.logAnalyticsWorkspaceId.value
    apiName: WebApiDeployment.outputs.apiName
    spaHostname: StaticAppDeployment.outputs.appHostname
    appHostname: WebAppDeployment.outputs.appHostname
    keyvaultName: WebAppDeployment.outputs.appKeyVaultName
  }
}


output resourceGroupName string = resourceGroup.name
output applicationHostname string = WebAppDeployment.outputs.appHostname
output apiName string = WebApiDeployment.outputs.apiName
output spaHostname string = StaticAppDeployment.outputs.appHostname
output containerAppFqdn string = ContainerAppDeployment.outputs.containerAppFqdn
output applicationKeyVaultName string = WebAppDeployment.outputs.appKeyVaultName
output databaseName string = DatabaseDeployment.outputs.apiDatabaseName
output databaseConnectionString string = DatabaseDeployment.outputs.apiDatabaseConnectionString
output managedIdentityAppId string = WebApiDeployment.outputs.managedIdentityAppId
output managedIdentityName string = WebApiDeployment.outputs.managedIdentityName
output apiAppInsightsKey string = WebApiDeployment.outputs.appInsightsKey
output appAppInsightsKey string = WebAppDeployment.outputs.appInsightsKey
output spaAppInsightsKey string = StaticAppDeployment.outputs.appInsightsKey
