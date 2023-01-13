targetScope = 'resourceGroup'

param containerAppName string
param containerImage string
param environmentId string
param location string = resourceGroup().location

resource containerApp 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: containerAppName
  location: location
  properties: {
    environmentId: environmentId
    configuration: {
      secrets: []
      registries: []
      ingress: {
        external: true
        targetPort: 3000
        transport: 'auto'
      }
    }
    template: {
      containers: [
        {
          image: containerImage
          name: containerAppName
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
  }
}

output containerAppFqdn string = containerApp.properties.configuration.ingress.fqdn
output containerAppName string = containerApp.name
output containerAppResourceGroup string = resourceGroup().name
