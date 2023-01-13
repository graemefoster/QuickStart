targetScope = 'subscription'

@description('A prefix to add to all resources to keep them unique')
@minLength(3)
@maxLength(6)
param resourcePrefix string

@description('AAD Service Principal name to set as the database administrator. This principal will be used to deploy databases to the server.')
param databaseAdministratorName string

@description('AAD Object Id of the Service Principal used as the database administrator.')
param databaseAdministratorObjectId string

@description('Used to construct app / api / keyvault names. Suggestions include test, prod, nonprod')
param environmentName string

@description('Publisher email used for the apim service')
param apimPublisherEmail string

param singleResourceGroup bool = true

param location string = deployment().location

var platformRgName = singleResourceGroup ? '${resourcePrefix}-${environmentName}-rg' :  '${resourcePrefix}-platform-${environmentName}-rg'
var deploymentName = 'platform-${resourcePrefix}-${environmentName}'

resource platformResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: platformRgName
  location: location
}

module PlatformDeployment './Tier1/main.bicep' = {
  name: deploymentName
  scope: platformResourceGroup
  params: {
    location: location
    resourcePrefix: resourcePrefix
    databaseAdministratorName: databaseAdministratorName
    databaseAdministratorObjectId: databaseAdministratorObjectId
    environmentName: environmentName
    apimPublisherEmail: apimPublisherEmail
    platformRgName: platformResourceGroup.name
    singleResourceGroupDeployment: singleResourceGroup
  }
}

output platformResourceGroupName string = platformRgName
output serverFarmId string = PlatformDeployment.outputs.serverFarmId
output databaseServerName string = PlatformDeployment.outputs.databaseServerName
output logAnalyticsWorkspaceId string = PlatformDeployment.outputs.logAnalyticsWorkspaceId
output containerEnvironmentId string = PlatformDeployment.outputs.containerEnvironmentId
output apimHostname string = PlatformDeployment.outputs.apimHostname
output resourcePrefix string = PlatformDeployment.outputs.resourcePrefix
output databaseAdministratorName string = PlatformDeployment.outputs.databaseAdministratorName
output environmentName string = PlatformDeployment.outputs.environmentName
output singleResourceGroupDeployment bool = PlatformDeployment.outputs.singleResourceGroupDeployment
output uniqueness string = PlatformDeployment.outputs.uniqueness
