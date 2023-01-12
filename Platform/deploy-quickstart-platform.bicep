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

@description('Pass false to break the components into their own resource groups. Using a single Resource group makes it easier to delete everything')
param singleResourceGroup bool = true

param location string = deployment().location

var platformRgName = singleResourceGroup ? '${resourcePrefix}-${environmentName}-rg' : '${resourcePrefix}-platform-${environmentName}-rg'
var platformMetadataName = '${resourcePrefix}-platform-metadata-${environmentName}-rg'

resource platformResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: platformRgName
  location: location
}

resource platformMetadataResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: singleResourceGroup ? platformRgName : platformMetadataName
  location: location
}

module PlatformDeployment './Tier1/main.bicep' = {
  name: 'platform'
  scope: platformMetadataResourceGroup
  params: {
    location: location
    resourcePrefix: resourcePrefix
    databaseAdministratorName: databaseAdministratorName
    databaseAdministratorObjectId: databaseAdministratorObjectId
    environmentName: environmentName
    apimPublisherEmail: apimPublisherEmail
    platformRgName: platformResourceGroup.name
  }
}

output platformMetadataResourceGroup string = PlatformDeployment.outputs.platformMetadataResourceGroupName
