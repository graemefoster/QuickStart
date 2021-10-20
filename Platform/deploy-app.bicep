param resourceSuffix string
param serverFarmId string
param apiHostname string
param environment string

var appHostname = '${resourceSuffix}-${uniqueString(resourceGroup().name)}-${environment}-webapp'
var appKeyVaultName = '${resourceSuffix}-${uniqueString(resourceGroup().name)}-app-${environment}-kv'
var secretsUserRoleId = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6'

resource AppKeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: appKeyVaultName
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
  name: appHostname
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
          value: 'https://${apiHostname}.azurewebsites.net'
        }
        {
          name: 'AzureAD__ClientSecret'
          value: '@Microsoft.KeyVault(VaultName=${AppKeyVault.name};SecretName=AzureAdClientSecret)'
        }
      ]
      windowsFxVersion: 'DOTNETCORE|5.0'
    }
  }
}

resource KeyVaultAuth 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid('${appHostname}-read-${appKeyVaultName}')
  scope: AppKeyVault
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
          value: 'https://${apiHostname}.azurewebsites.net'
        }
        {
          name: 'AzureAD__ClientSecret'
          value: '@Microsoft.KeyVault(VaultName=${AppKeyVault.name};SecretName=AzureAdClientSecret)'
        }
      ]
      windowsFxVersion: 'DOTNETCORE|5.0'
    }
  }
}

resource GreenKeyVaultAuth 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid('${appHostname}.green-read-${appKeyVaultName}')
  scope: AppKeyVault
  properties: {
    roleDefinitionId: secretsUserRoleId
    principalId: WebAppGreen.identity.principalId
    principalType: 'ServicePrincipal'
  }
} 

output appHostname string = appHostname
output appKeyVaultName string = appKeyVaultName
