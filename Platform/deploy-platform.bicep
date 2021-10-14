param resourceSuffix string
param databaseAdministrator string

resource QuickStartServerFarm 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: '${resourceSuffix}-asp'
  location: resourceGroup().location
  sku: {
    name: 'F1'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}
resource WebApp 'Microsoft.Web/sites@2021-01-15' = {
  name: '${resourceSuffix}${uniqueString(resourceGroup().name)}site'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: QuickStartServerFarm.id
    siteConfig: {
      minTlsVersion: '1.2'
    }
  }
}

resource SqlDatabaseServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: '${resourceSuffix}-sqlserver'
  location: resourceGroup().location
  properties: {
    minimalTlsVersion: '1.2'
    administrators: {
      azureADOnlyAuthentication: true
      administratorType: 'ActiveDirectory'
      login: databaseAdministrator
      principalType: 'User'
    }
  }
}

resource SqlDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: '${resourceSuffix}-sqldb'
  parent: SqlDatabaseServer
  location: resourceGroup().location
}
