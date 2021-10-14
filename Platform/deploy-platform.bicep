param resourceSuffix string
param databaseAdministrator string
param databaseAdministratorObjectId string

resource QuickStartServerFarm 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: '${resourceSuffix}-asp'
  location: resourceGroup().location
  sku: {
    name: 'S1'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource CiCdIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${resourceSuffix}-cicd-umi'
  location: resourceGroup().location
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
      principalType: 'Application'
      tenantId: subscription().tenantId
      sid: databaseAdministratorObjectId
    }
  }
}

resource WebAppTest 'Microsoft.Web/sites@2021-01-15' = {
  name: '${resourceSuffix}-${uniqueString(resourceGroup().name)}-test'
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

resource SqlDatabaseTest 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: '${resourceSuffix}-test-sqldb'
  parent: SqlDatabaseServer
  location: resourceGroup().location
}

resource WebApp 'Microsoft.Web/sites@2021-01-15' = {
  name: '${resourceSuffix}-${uniqueString(resourceGroup().name)}'
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

resource WebAppGreen 'Microsoft.Web/sites/slots@2021-01-15' = {
  parent: WebApp
  name: 'green'
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

resource SqlDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: '${resourceSuffix}-sqldb'
  parent: SqlDatabaseServer
  location: resourceGroup().location
}
