param databaseServerName string

param testDatabaseName string
param productionDatabaseName string

param productionAppHostname string
param testAppHostname string

param testApiAadClientId string
param productionApiAadClientId string

param testApiHostname string
param productionApiHostname string

resource TestWebApiConfiguration 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${testApiHostname}/appSettings'
  properties: {
    'ASPNETCORE_ENVIRONMENT': 'Test'
    'ApiSettings__Cors__0': 'https://${testAppHostname}.azurewebsites.net'
    'AzureAD__ClientId': testApiAadClientId
    'ApiSettings__ConnectionString': 'Data Source=${databaseServerName}.database.windows.net; Initial Catalog=${testDatabaseName};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;app=Test Website'
    }
}

resource ProductionWebApiConfiguration 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${productionApiHostname}/appSettings'
  properties: {
    'ASPNETCORE_ENVIRONMENT': 'Production'
    'ApiSettings__Cors__0': 'https://${productionAppHostname}.azurewebsites.net'
    'ApiSettings__Cors__1': 'https://${productionAppHostname}-green.azurewebsites.net'
    'AzureAD__ClientId': productionApiAadClientId
    'ApiSettings__ConnectionString': 'Data Source=${databaseServerName}.database.windows.net; Initial Catalog=${productionDatabaseName};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;app=Production Website'
    }
}

resource ProductionSlotWebApiConfiguration 'Microsoft.Web/sites/slots/config@2021-02-01' = {
  name: '${productionApiHostname}/green/appsettings'
  properties: {
    'ASPNETCORE_ENVIRONMENT': 'Production'
    'ApiSettings__Cors__0': 'https://${productionAppHostname}.azurewebsites.net'
    'ApiSettings__Cors__1': 'https://${productionAppHostname}-green.azurewebsites.net'
    'AzureAD__ClientId': productionApiAadClientId
    'ApiSettings__ConnectionString': 'Data Source=${databaseServerName}.database.windows.net; Initial Catalog=${productionDatabaseName};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;app=Production (Green) Website'
    }
}
