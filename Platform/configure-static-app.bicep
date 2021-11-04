param appAadClientId string
param spaHostname string
param apiHostname string
param apiAadClientId string
param environmentName string
param appAppInsightsKey string

var hasSlot = environmentName != 'test'


resource WebAppConfiguration 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${spaHostname}/appSettings'
  properties: {
    'APPINSIGHTS_INSTRUMENTATIONKEY' : appAppInsightsKey
    'ApiSettings__URL': 'https://${apiHostname}.azurewebsites.net'
    'ApiSettings__Scope' : 'api://${apiAadClientId}/Pets.Manage'
    'AzureAD__ClientId': appAadClientId
    }
}

resource SlotWebAppConfiguration 'Microsoft.Web/sites/slots/config@2021-02-01' = if(hasSlot) {
  name: '${spaHostname}/green/appsettings'
  properties: {
    'APPINSIGHTS_INSTRUMENTATIONKEY' : appAppInsightsKey
    'ApiSettings__URL': 'https://${apiHostname}.azurewebsites.net'
    'ApiSettings__Scope' : 'api://${apiAadClientId}/Pets.Manage'
    'AzureAD__ClientId': appAadClientId
    }
}
