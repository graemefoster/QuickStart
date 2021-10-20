param resourceSuffix string
param serverFarmId string
param environmentName string

var apiHostname = '${resourceSuffix}-${uniqueString(resourceGroup().name)}-${environmentName}-api'

resource WebApi 'Microsoft.Web/sites@2021-01-15' = {
  name: apiHostname
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      windowsFxVersion: 'DOTNET|5.0'
    }
  }
}

resource WebApiGreen 'Microsoft.Web/sites/slots@2021-01-15' = {
  parent: WebApi
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
      windowsFxVersion: 'DOTNET|5.0'
    }
  }
}

output apiHostname string = apiHostname
output managedIdentityId string = WebApi.identity.principalId
output greenManagedIdentityId string = WebApiGreen.identity.principalId
