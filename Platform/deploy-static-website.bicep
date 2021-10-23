param resourceSuffix string
param environmentName string

var staticWebsiteName = '${resourceSuffix}-${uniqueString(resourceGroup().name)}-${environmentName}-staticapp'

resource symbolicname 'Microsoft.Web/staticSites@2021-02-01' = {
  name: staticWebsiteName
  location: 'westus2' //not available in most regions as of October 2021
  sku: {
    name: 'free'
    tier: 'free'
  }
}
