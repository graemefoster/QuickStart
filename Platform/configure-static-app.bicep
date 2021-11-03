param appKeyVaultName string
param appAadClientId string
param spaHostname string
param apiHostname string
param apiAadClientId string
param environmentName string
param appAppInsightsKey string

@secure()
param appClientSecret string

var hasSlot = environmentName != 'test'

resource AppClientSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = if (!empty(appClientSecret)) {
  name: '${appKeyVaultName}/ApplicationClientSecret'
  properties: {
    contentType: 'application/text'
    value: appClientSecret
  }
}

resource WebAppConfiguration 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${spaHostname}/appSettings'
  properties: {
    'WEBSITE_RUN_FROM_PACKAGE' : 1
    'ASPNETCORE_ENVIRONMENT': 'Test'
    'APPINSIGHTS_INSTRUMENTATIONKEY' : appAppInsightsKey
    'ApiSettings__URL': 'https://${apiHostname}.azurewebsites.net'
    'ApiSettings__Scope' : 'api://${apiAadClientId}/Pets.Manage'
    'AzureAD__ClientId': appAadClientId
    'AzureAD__ClientSecret': '@Microsoft.KeyVault(VaultName=${appKeyVaultName};SecretName=ApplicationClientSecret)'
    }
}

resource SlotWebAppConfiguration 'Microsoft.Web/sites/slots/config@2021-02-01' = if(hasSlot) {
  name: '${spaHostname}/green/appsettings'
  properties: {
    'WEBSITE_RUN_FROM_PACKAGE' : 1
    'ASPNETCORE_ENVIRONMENT': 'Test'
    'APPINSIGHTS_INSTRUMENTATIONKEY' : appAppInsightsKey
    'ApiSettings__URL': 'https://${apiHostname}.azurewebsites.net'
    'ApiSettings__Scope' : 'api://${apiAadClientId}/Pets.Manage'
    'AzureAD__ClientId': appAadClientId
    'AzureAD__ClientSecret': '@Microsoft.KeyVault(VaultName=${appKeyVaultName};SecretName=ApplicationClientSecret)'
    }
}
