param resourceSuffix string
param serverFarmId string
param testApiHostname string
param productionApiHostname string

var testAppHostname = '${resourceSuffix}-webapp-${uniqueString(resourceGroup().name)}-test'
var productionAppHostname = '${resourceSuffix}-webapp-${uniqueString(resourceGroup().name)}'

var testAppKeyVaultName = '${resourceSuffix}-app-test-kv'
var productionAppKeyVaultName = '${resourceSuffix}-app-kv'

var secretsUserRoleId = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6'

resource TestAppKeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: testAppKeyVaultName
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
  }
}

resource WebAppTest 'Microsoft.Web/sites@2021-01-15' = {
  name: testAppHostname
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Test'
        }
        {
          name: 'ApiSettings__URL'
          value: 'https://${testApiHostname}.azurewebsites.net'
        }
        {
          name: 'AzureAD__ClientSecret'
          value: '@Microsoft.KeyVault(VaultName=${TestAppKeyVault.name};SecretName=AzureAdClientSecret)'
        }
      ]
      windowsFxVersion: 'DOTNETCORE|5.0'
    }
  }
}

resource TestKeyVaultAuth 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid('${testAppHostname}-read-${testAppKeyVaultName}')
  scope: TestAppKeyVault
  properties: {
    roleDefinitionId: secretsUserRoleId
    principalId: WebAppTest.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource ProductionAppKeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: productionAppKeyVaultName
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
  }
}

resource WebApp 'Microsoft.Web/sites@2021-01-15' = {
  name: productionAppHostname
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'ApiSettings__URL'
          value: 'https://${productionApiHostname}.azurewebsites.net'
        }
        {
          name: 'AzureAD__ClientSecret'
          value: '@Microsoft.KeyVault(VaultName=${ProductionAppKeyVault.name};SecretName=AzureAdClientSecret)'
        }
      ]
      windowsFxVersion: 'DOTNETCORE|5.0'
    }
  }
}

resource ProdKeyVaultAuth 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid('${productionAppHostname}-read-${productionAppKeyVaultName}')
  scope: ProductionAppKeyVault
  properties: {
    roleDefinitionId: secretsUserRoleId
    principalId: WebApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}


resource WebAppGreen 'Microsoft.Web/sites/slots@2021-01-15' = {
  parent: WebApp
  name: 'green'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'ApiSettings__URL'
          value: 'https://${productionApiHostname}.azurewebsites.net'
        }
        {
          name: 'AzureAD__ClientSecret'
          value: '@Microsoft.KeyVault(VaultName=${ProductionAppKeyVault.name};SecretName=AzureAdClientSecret)'
        }
      ]
      windowsFxVersion: 'DOTNETCORE|5.0'
    }
  }
}

resource ProdGreenKeyVaultAuth 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid('${productionAppHostname}.green-read-${productionAppKeyVaultName}')
  scope: ProductionAppKeyVault
  properties: {
    roleDefinitionId: secretsUserRoleId
    principalId: WebAppGreen.identity.principalId
    principalType: 'ServicePrincipal'
  }
} 

output testAppHostname string = testAppHostname
output productionAppHostname string = productionAppHostname

output testAppKeyVaultName string = testAppKeyVaultName
output productionAppKeyVaultName string = productionAppKeyVaultName
