targetScope = 'resourceGroup'

param apiClientId string
param appName string
param appClientId string

resource app 'Microsoft.Web/sites@2022-03-01' existing = {
  name: appName
}

resource clientId 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  parent: app
  properties: {
    AzureAD__ClientId: appClientId
    ApiSettings__Scope: 'api://${apiClientId}/Pets.Manage'
  }
}
