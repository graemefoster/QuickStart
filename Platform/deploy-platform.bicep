param resourceSuffix string
param databaseAdministratorName string
param databaseAdministratorObjectId string

var testAppHostname = '${resourceSuffix}-${uniqueString(resourceGroup().name)}-test'
var testApiHostname = '${resourceSuffix}-api-${uniqueString(resourceGroup().name)}-test'
var productionApiHostname = '${resourceSuffix}-api-${uniqueString(resourceGroup().name)}'
var productionAppHostname = '${resourceSuffix}-${uniqueString(resourceGroup().name)}'

resource QuickStartServerFarm 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: '${resourceSuffix}-asp'
  location: resourceGroup().location
  sku: {
    name: 'S1'
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
      login: databaseAdministratorName
      principalType: 'Application'
      tenantId: subscription().tenantId
      sid: databaseAdministratorObjectId
    }
  }
}

resource WebAppTest 'Microsoft.Web/sites@2021-01-15' = {
  name: testAppHostname
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: QuickStartServerFarm.id
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

resource WebApiTest 'Microsoft.Web/sites@2021-01-15' = {
  name: testApiHostname
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: QuickStartServerFarm.id
    siteConfig: {
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Test'
        }
        {
          name: 'ApiSettings__Cors__0'
          value: 'https://${testAppHostname}.azurewebsites.net'
        }
      ]
      linuxFxVersion: 'DOTNETCORE|5.0'
    }
  }
}

resource SqlDatabaseTest 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: '${resourceSuffix}-test-sqldb'
  parent: SqlDatabaseServer
  location: resourceGroup().location
}

resource WebApp 'Microsoft.Web/sites@2021-01-15' = {
  name: productionAppHostname
  location: resourceGroup().location
  properties: {
    httpsOnly: true
    serverFarmId: QuickStartServerFarm.id
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
    serverFarmId: QuickStartServerFarm.id
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


resource WebApi 'Microsoft.Web/sites@2021-01-15' = {
  name: productionApiHostname
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: QuickStartServerFarm.id
    siteConfig: {
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'ApiSettings__Cors__0'
          value: 'https://${productionAppHostname}.azurewebsites.net'
        }
      ]
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
    serverFarmId: QuickStartServerFarm.id
    siteConfig: {
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'ApiSettings__Cors__0'
          value: 'https://${productionAppHostname}.azurewebsites.net'
        }
      ]
      linuxFxVersion: 'DOTNETCORE|5.0'
    }
  }
}

resource SqlDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: '${resourceSuffix}-sqldb'
  parent: SqlDatabaseServer
  location: resourceGroup().location
}
