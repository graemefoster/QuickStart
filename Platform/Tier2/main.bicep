targetScope = 'subscription'

param resourcePrefix string
param environmentName string
param location string
param platformResourceGroupName string
param singleResourceGroupDeployment bool
param databaseServerName string
param logAnalyticsWorkspaceId string
param containerEnvironmentId string
param serverFarmId string
param apimHostname string
param uniqueness string
param appClientId string
param apiClientId string

@secure()
param appClientSecret string

var apiRgName = '${resourcePrefix}-${environmentName}-api-rg'

module apiResourceGroup '../rg.bicep' = if (!singleResourceGroupDeployment) {
  name: '${deployment().name}-apimrg'
  scope: subscription()
  params: {
    resourceGroupName: apiRgName
    location: location
  }
}

module ApiDeployment './api/main.bicep' = {
  name: '${deployment().name}-api'
  scope: resourceGroup(singleResourceGroupDeployment ? platformResourceGroupName : apiRgName)
  params: {
    environmentName: environmentName
    resourcePrefix: resourcePrefix
    platformResourceGroupName: platformResourceGroupName
    databaseServerName: databaseServerName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    serverFarmId: serverFarmId
    location: location
    uniqueness: uniqueness
  }
}

var microserviceRgName = '${resourcePrefix}-${environmentName}-microservice-rg'
module microserviceResourceGroup '../rg.bicep' = if (!singleResourceGroupDeployment) {
  name: '${deployment().name}-microservicerg'
  scope: subscription()
  params: {
    resourceGroupName: microserviceRgName
    location: location
  }
}

module MicroServiceDeployment './microservice/main.bicep' = {
  name: '${deployment().name}-microservice'
  scope: resourceGroup(singleResourceGroupDeployment ? platformResourceGroupName : microserviceRgName)
  params: {
    location: location
    environmentId: containerEnvironmentId
    containerAppName: 'pet-ownership'
    containerImage: 'ghcr.io/graemefoster/sample-microservice:latest'
  }
}

var appRgName = '${resourcePrefix}-${environmentName}-app-rg'
module appResourceGroup '../rg.bicep' = if (!singleResourceGroupDeployment) {
  name: '${deployment().name}-apprg'
  scope: subscription()
  params: {
    resourceGroupName: appRgName
    location: location
  }
}

module AppDeployment './app/main.bicep' = {
  name: '${deployment().name}-app'
  scope: resourceGroup(singleResourceGroupDeployment ? platformResourceGroupName : appRgName)
  params: {
    environmentName: environmentName
    resourcePrefix: resourcePrefix
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    serverFarmId: serverFarmId
    containerAppFqdn: MicroServiceDeployment.outputs.containerAppFqdn
    apiHostName: apimHostname
    uniqueness: uniqueness
    apiAadClientId: apiClientId
    appAadClientId: appClientId
    appClientSecret: appClientSecret
  }
}

var spaRgName = '${resourcePrefix}-${environmentName}-spa-rg'
module spaResourceGroup '../rg.bicep' = if (!singleResourceGroupDeployment) {
  name: '${deployment().name}-sparg'
  scope: subscription()
  params: {
    resourceGroupName: spaRgName
    location: location
  }
}

module SpaDeployment './spa/main.bicep' = {
  name: '${deployment().name}-spa'
  scope: resourceGroup(singleResourceGroupDeployment ? platformResourceGroupName : spaRgName)
  params: {
    environmentName: environmentName
    resourcePrefix: resourcePrefix
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    serverFarmId: serverFarmId
    uniqueness: uniqueness
    apiAadClientId: apiClientId
    apiHostname: apimHostname
    appAadClientId: appClientId
    containerAppFqdn: MicroServiceDeployment.outputs.containerAppFqdn
  }
}

output appName string = AppDeployment.outputs.appName
output apiName string = ApiDeployment.outputs.appName
output spaName string = SpaDeployment.outputs.appName

output appFqdn string = AppDeployment.outputs.appHostname
output spaFqdn string = SpaDeployment.outputs.appHostname
output apiFqdn string = ApiDeployment.outputs.appHostname

output appSlotFqdn string = AppDeployment.outputs.appSlotHostname
output spaSlotFqdn string = SpaDeployment.outputs.appSlotHostname
output apiSlotFqdn string = ApiDeployment.outputs.appSlotHostname

output microserviceFqdn string = MicroServiceDeployment.outputs.containerAppFqdn
output containerAppName string = MicroServiceDeployment.outputs.containerAppName
output containerAppResourceGroup string = MicroServiceDeployment.outputs.containerAppResourceGroup

output appResourceGroupName string = singleResourceGroupDeployment ? platformResourceGroupName : appRgName
output appKeyVaultName string = AppDeployment.outputs.appKeyVaultName
output apiKeySecretName string = AppDeployment.outputs.apiKeySecretName

output databaseConnectionString string = ApiDeployment.outputs.databaseConnectionString
output managedIdentityAppId string = ApiDeployment.outputs.managedIdentityAppId
output managedIdentityName string = ApiDeployment.outputs.managedIdentityName
