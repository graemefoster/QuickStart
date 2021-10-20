param resourceSuffix string
param databaseServerName string
param serverFarmId string

var testApiHostname = '${resourceSuffix}-api-${uniqueString(resourceGroup().name)}-test'
var testDatabaseName = '${resourceSuffix}-test-sqldb'

var productionApiHostname = '${resourceSuffix}-api-${uniqueString(resourceGroup().name)}'
var productionDatabaseName = '${resourceSuffix}-sqldb'


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
      linuxFxVersion: 'DOTNETCORE|5.0'
    }
  }
}

resource SqlDatabaseTest 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: '${databaseServerName}/${testDatabaseName}'
  location: resourceGroup().location
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
      linuxFxVersion: 'DOTNETCORE|5.0'
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
      linuxFxVersion: 'DOTNETCORE|5.0'
    }
  }
}

resource SqlDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: '${databaseServerName}/${productionDatabaseName}'
  location: resourceGroup().location
}

output productionApiHostname string = productionApiHostname
output testApiHostname string = testApiHostname
