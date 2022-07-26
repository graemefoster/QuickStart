param databaseServerName string

param databaseName string
param appHostname string
param spaHostname string
param apiAadClientId string
param apiName string
param userAssignedClientId string
param apiAppInsightsKey string
param environmentName string

var hasSlot = environmentName != 'test'

resource WebApiConfiguration 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${apiName}/appSettings'
  properties: {
    WEBSITE_RUN_FROM_PACKAGE: 1
    ASPNETCORE_ENVIRONMENT: 'Production'
    APPINSIGHTS_INSTRUMENTATIONKEY: apiAppInsightsKey
    ApiSettings__Cors__0: 'https://${appHostname}.azurewebsites.net'
    ApiSettings__Cors__1: 'https://${appHostname}-green.azurewebsites.net'
    ApiSettings__Cors__2: 'https://${spaHostname}.azurewebsites.net'
    ApiSettings__Cors__3: 'https://${spaHostname}-green.azurewebsites.net'
    ApiSettings__UserAssignedClientId: userAssignedClientId
    AzureAD__ClientId: apiAadClientId
    ApiSettings__ConnectionString: 'Data Source=${databaseServerName}.database.windows.net; Initial Catalog=${databaseName};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;app=Website'
  }
}

resource ProductionSlotWebApiConfiguration 'Microsoft.Web/sites/slots/config@2021-02-01' = if (hasSlot) {
  name: '${apiName}/green/appsettings'
  properties: {
    WEBSITE_RUN_FROM_PACKAGE: 1
    ASPNETCORE_ENVIRONMENT: 'Production'
    APPINSIGHTS_INSTRUMENTATIONKEY: apiAppInsightsKey
    ApiSettings__Cors__0: 'https://${appHostname}.azurewebsites.net'
    ApiSettings__Cors__1: 'https://${appHostname}-green.azurewebsites.net'
    ApiSettings__Cors__2: 'https://${spaHostname}.azurewebsites.net'
    ApiSettings__Cors__3: 'https://${spaHostname}-green.azurewebsites.net'
    ApiSettings__UserAssignedClientId: userAssignedClientId
    AzureAD__ClientId: apiAadClientId
    ApiSettings__ConnectionString: 'Data Source=${databaseServerName}.database.windows.net; Initial Catalog=${databaseName};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;app=Website'
  }
}
