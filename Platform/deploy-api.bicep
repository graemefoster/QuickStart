param resourcePrefix string
param serverFarmId string
param environmentName string
param deploySlot bool

var apiHostname = '${resourcePrefix}-${uniqueString(resourceGroup().name)}-${environmentName}-api'
var apiMsiName = '${resourcePrefix}-${uniqueString(resourceGroup().name)}-${environmentName}-msi'

resource ManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  location:resourceGroup().location
  name: apiMsiName
}

resource WebApi 'Microsoft.Web/sites@2021-01-15' = {
  name: apiHostname
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${ManagedIdentity.id}' : {}
    }
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v5.0'
    }
  }
}

resource WebApiGreen 'Microsoft.Web/sites/slots@2021-01-15' = if(deploySlot) {
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
      netFrameworkVersion: 'v5.0'
    }
  }
}

output apiHostname string = apiHostname
output managedIdentityName string = ManagedIdentity.name
output managedIdentityAppId string = ManagedIdentity.properties.clientId
