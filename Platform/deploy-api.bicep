param resourceSuffix string
param serverFarmId string

var testApiHostname = '${resourceSuffix}-api-${uniqueString(resourceGroup().name)}-test'
var productionApiHostname = '${resourceSuffix}-api-${uniqueString(resourceGroup().name)}'

resource WebApiTest 'Microsoft.Web/sites@2021-01-15' = {
  name: testApiHostname
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      windowsFxVersion: 'DOTNETCORE|5.0'
    }
  }
}

resource WebApi 'Microsoft.Web/sites@2021-01-15' = {
  name: productionApiHostname
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      windowsFxVersion: 'DOTNETCORE|5.0'
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
      windowsFxVersion: 'DOTNETCORE|5.0'
    }
  }
}

output productionApiHostname string = productionApiHostname
output testApiHostname string = testApiHostname
