param containerAppName string
param containerImage string
param environmentId string
param location string = 'canadacentral'

resource containerApp 'Microsoft.Web/containerApps@2021-03-01' = {
  name: containerAppName
  kind: 'containerapps'
  location: location
  properties: {
    kubeEnvironmentId: environmentId
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
      dapr: {
        enabled: false
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
