param resourceSuffix string
param databaseServerName string
param testAppHostname string
param productionAppHostname string

var testApiHostname = '${resourceSuffix}-api-${uniqueString(resourceGroup().name)}-test'
var testDatabaseName = '${resourceSuffix}-test-sqldb'

var productionApiHostname = '${resourceSuffix}-api-${uniqueString(resourceGroup().name)}'
var productionDatabaseName = '${resourceSuffix}-sqldb'

resource TestWebApiConfiguration 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${testApiHostname}/appSettings'
  properties: {
    'ASPNETCORE_ENVIRONMENT': 'Test'
    'ApiSettings__Cors__0': 'https://${testAppHostname}.azurewebsites.net'
    'ApiSettings__ConnectionString': 'Data Source=${databaseServerName}.database.windows.net; Initial Catalog=${testDatabaseName};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;app=Test Website'
    }
}

resource ProductionWebApiConfiguration 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${productionApiHostname}/appSettings'
  properties: {
    'ASPNETCORE_ENVIRONMENT': 'Production'
    'ApiSettings__Cors__0': 'https://${productionAppHostname}.azurewebsites.net'
    'ApiSettings__Cors__1': 'https://${productionAppHostname}-green.azurewebsites.net'
    'ApiSettings__ConnectionString': 'Data Source=${databaseServerName}.database.windows.net; Initial Catalog=${productionDatabaseName};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;app=Production Website'
    }
}

resource ProductionSlotWebApiConfiguration 'Microsoft.Web/sites/slots/config@2021-02-01' = {
  name: '${productionApiHostname}/green/appsettings'
  properties: {
    'ASPNETCORE_ENVIRONMENT': 'Production'
    'ApiSettings__Cors__0': 'https://${productionAppHostname}.azurewebsites.net'
    'ApiSettings__Cors__1': 'https://${productionAppHostname}-green.azurewebsites.net'
    'ApiSettings__ConnectionString': 'Data Source=${databaseServerName}.database.windows.net; Initial Catalog=${productionDatabaseName};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;app=Production (Green) Website'
    }
}
