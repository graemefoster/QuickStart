param resourceSuffix string
param environmentName string

var staticWebsiteName = '${resourceSuffix}-${uniqueString(resourceGroup().name)}-${environmentName}-staticapp'

resource symbolicname 'Microsoft.Web/staticSites@2021-02-01' = {
  name: staticWebsiteName
  location: resourceGroup().location
  sku: {
    name: 'free'
    tier: 'free'
  }
}
