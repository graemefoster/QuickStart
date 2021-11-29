param resourcePrefix string
param environmentName string

var apimServiceName = '${resourcePrefix}-${environmentName}-apim'

resource Api 'Microsoft.ApiManagement/service/apis@2021-04-01-preview' = {
  name: '${apimServiceName}/SampleApi'
}
