param resourceSuffix string
param serverFarmId string
param testApiHostname string
param productionApiHostname string

var testAppHostname = '${resourceSuffix}-webapp-${uniqueString(resourceGroup().name)}-test'
var productionAppHostname = '${resourceSuffix}-webapp-${uniqueString(resourceGroup().name)}'

resource WebAppTest 'Microsoft.Web/sites@2021-01-15' = {
  name: testAppHostname
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Test'
        }
        {
          name: 'ApiSettings__URL'
          value: 'https://${testApiHostname}.azurewebsites.net'
        }
      ]
      linuxFxVersion: 'DOTNETCORE|5.0'
    }
  }
}

resource WebApp 'Microsoft.Web/sites@2021-01-15' = {
  name: productionAppHostname
  location: resourceGroup().location
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'ApiSettings__URL'
          value: 'https://${productionApiHostname}.azurewebsites.net'
        }
      ]
      linuxFxVersion: 'DOTNETCORE|5.0'
    }
  }
}

resource WebAppGreen 'Microsoft.Web/sites/slots@2021-01-15' = {
  parent: WebApp
  name: 'green'
  location: resourceGroup().location
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'ApiSettings__URL'
          value: 'https://${productionApiHostname}.azurewebsites.net'
        }
      ]
      linuxFxVersion: 'DOTNETCORE|5.0'
    }
  }
}

output testAppHostname string = testAppHostname
output productionAppHostname string = productionAppHostname
