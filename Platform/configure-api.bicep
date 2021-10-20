param databaseServerName string

param databaseName string
param appHostname string
param apiAadClientId string
param apiHostname string

resource WebApiConfiguration 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${apiHostname}/appSettings'
  properties: {
    'ASPNETCORE_ENVIRONMENT': 'Production'
    'ApiSettings__Cors__0': 'https://${appHostname}.azurewebsites.net'
    'ApiSettings__Cors__1': 'https://${appHostname}-green.azurewebsites.net'
    'AzureAD__ClientId': apiAadClientId
    'ApiSettings__ConnectionString': 'Data Source=${databaseServerName}.database.windows.net; Initial Catalog=${databaseName};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;app=Production Website'
    }
}

resource ProductionSlotWebApiConfiguration 'Microsoft.Web/sites/slots/config@2021-02-01' = {
  name: '${apiHostname}/green/appsettings'
  properties: {
    'ASPNETCORE_ENVIRONMENT': 'Production'
    'ApiSettings__Cors__0': 'https://${appHostname}.azurewebsites.net'
    'ApiSettings__Cors__1': 'https://${appHostname}-green.azurewebsites.net'
    'AzureAD__ClientId': apiAadClientId
    'ApiSettings__ConnectionString': 'Data Source=${databaseServerName}.database.windows.net; Initial Catalog=${databaseName};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;app=Production (Green) Website'
    }
}
