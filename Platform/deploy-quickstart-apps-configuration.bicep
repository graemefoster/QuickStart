targetScope = 'subscription'

param databaseServerName string

param apiResourceGroupName string
param appResourceGroupName string

param databaseName string
param appHostname string
param apiHostname string
param appKeyVaultName string
param appClientId string
param apiClientId string
param apiUserAssignedClientId string

@secure()
param appClientSecret string

resource apiResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: apiResourceGroupName
  location: deployment().location
}

resource appResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: appResourceGroupName
  location: deployment().location
}

module PostConfigureApiDeployment './api/configure-api.bicep' = {
  name: 'PostConfigureApiDeployment'
  scope: apiResourceGroup
  params: {
    databaseServerName: databaseServerName
    databaseName: databaseName
    appHostname: appHostname
    apiHostname: apiHostname
    apiAadClientId: apiClientId
    userAssignedClientId: apiUserAssignedClientId
  }
}

module PostConfigureAppDeployment './app/configure-app.bicep' = {
  name: 'PostConfigureAppDeployment'
  scope: appResourceGroup
  params: {
    apiHostname: apiHostname
    appAadClientId:appClientId
    appClientSecret:appClientSecret
    appHostname:appHostname
    appKeyVaultName:appKeyVaultName
    apiAadClientId:apiClientId
  }
}
