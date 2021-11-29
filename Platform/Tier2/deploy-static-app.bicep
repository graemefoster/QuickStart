param resourcePrefix string
param serverFarmId string
param environmentName string
param deploySlot bool

var appHostname = '${resourcePrefix}-${uniqueString(resourceGroup().name)}-${environmentName}-spa'

resource WebApp 'Microsoft.Web/sites@2021-01-15' = {
  name: appHostname
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      nodeVersion: 'node|16-lts'
    }
  }
}

resource WebAppGreen 'Microsoft.Web/sites/slots@2021-01-15' = if(deploySlot) {
  parent: WebApp
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
      nodeVersion: 'node|16-lts'
    }
  }
}

output appHostname string = appHostname
