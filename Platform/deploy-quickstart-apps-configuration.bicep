targetScope = 'subscription'

param databaseServerName string

param apiResourceGroupName string
param appResourceGroupName string

param testDatabaseName string
param productionDatabaseName string

param testAppHostname string
param productionAppHostname string

param testApiHostname string
param productionApiHostname string

param testAppKeyVaultName string
param productionAppKeyVaultName string

param testAppClientId string
param productionAppClientId string

param testApiClientId string
param productionApiClientId string

@secure()
param testAppClientSecret string

@secure()
param productionAppClientSecret string


resource apiResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: apiResourceGroupName
  location: deployment().location
}

resource appResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: appResourceGroupName
  location: deployment().location
}

module PostConfigureApiDeployment './configure-api.bicep' = {
  name: 'PostConfigureApiDeployment'
  scope: apiResourceGroup
  params: {
    databaseServerName: databaseServerName
    testDatabaseName: testDatabaseName
    productionDatabaseName: productionDatabaseName
    productionAppHostname: productionAppHostname
    testAppHostname: testAppHostname
    productionApiHostname: productionApiHostname
    testApiHostname: testApiHostname
    productionApiAadClientId: productionApiClientId
    testApiAadClientId: testApiClientId
  }
}

module PostConfigureAppDeployment './configure-app.bicep' = {
  name: 'PostConfigureAppDeployment'
  scope: appResourceGroup
  params: {
    productionAppHostname: productionAppHostname
    testAppHostname: testAppHostname
    productionApiHostname: productionApiHostname
    testApiHostname: testApiHostname
    productionAppKeyVaultName: productionAppKeyVaultName
    testAppKeyVaultName: testAppKeyVaultName
    productionAppAadClientId: productionAppClientId
    testAppAadClientId: testAppClientId
    testAppClientSecret: testAppClientSecret
    productionAppClientSecret: productionAppClientSecret
  }
}
