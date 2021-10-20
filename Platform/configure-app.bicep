param testAppKeyVaultName string
param productionAppKeyVaultName string

param testAppAadClientId string
param productionAppAadClientId string

param testAppHostname string
param productionAppHostname string

param testApiHostname string
param productionApiHostname string


resource TestWebAppConfiguration 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${testAppHostname}/appSettings'
  properties: {
    'ASPNETCORE_ENVIRONMENT': 'Test'
    'ApiSettings__URL': 'https://${testApiHostname}.azurewebsites.net'
    'AzureAD__ClientId': testAppAadClientId
    'AzureAD__ClientSecret': 'https://${testAppKeyVaultName}.${environment().suffixes.keyvaultDns}/secrets/AzureAdClientSecret'
    }
}

resource ProductionWebAppConfiguration 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${productionAppHostname}/appSettings'
  properties: {
    'ASPNETCORE_ENVIRONMENT': 'Test'
    'ApiSettings__URL': 'https://${productionApiHostname}.azurewebsites.net'
    'AzureAD__ClientId': productionAppAadClientId
    'AzureAD__ClientSecret': 'https://${productionAppKeyVaultName}.${environment().suffixes.keyvaultDns}/secrets/AzureAdClientSecret'
    }
}

resource ProductionSlotWebAppConfiguration 'Microsoft.Web/sites/slots/config@2021-02-01' = {
  name: '${productionAppHostname}/green/appsettings'
  properties: {
    'ASPNETCORE_ENVIRONMENT': 'Test'
    'ApiSettings__URL': 'https://${productionApiHostname}.azurewebsites.net'
    'AzureAD__ClientId': productionAppAadClientId
    'AzureAD__ClientSecret': 'https://${productionAppKeyVaultName}.${environment().suffixes.keyvaultDns}/secrets/AzureAdClientSecret'
    }
}
