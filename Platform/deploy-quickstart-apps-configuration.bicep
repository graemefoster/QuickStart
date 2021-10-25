targetScope = 'subscription'

param databaseServerName string

param resourceGroupName string
param databaseName string
param appHostname string
param apiHostname string
param appKeyVaultName string
param appClientId string
param apiClientId string
param apiUserAssignedClientId string

@secure()
param appClientSecret string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: deployment().location
}

module PostConfigureApiDeployment './configure-api.bicep' = {
  name: 'PostConfigureApiDeployment'
  scope: resourceGroup
  params: {
    databaseServerName: databaseServerName
    databaseName: databaseName
    appHostname: appHostname
    apiHostname: apiHostname
    apiAadClientId: apiClientId
    userAssignedClientId: apiUserAssignedClientId
  }
}

module PostConfigureAppDeployment './configure-app.bicep' = {
  name: 'PostConfigureAppDeployment'
  scope: resourceGroup
  params: {
    apiHostname: apiHostname
    appAadClientId:appClientId
    appClientSecret:appClientSecret
    appHostname:appHostname
    appKeyVaultName:appKeyVaultName
    apiAadClientId:apiClientId
  }
}
