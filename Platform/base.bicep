targetScope = 'subscription'

@description('A prefix to add to all resources to keep them unique')
@minLength(3)
@maxLength(6)
param resourcePrefix string

@description('Used to construct app / api / keyvault names. Suggestions include test, prod, nonprod')
param environmentName string

output configuration object = {
  platformResourceGroup: '${resourcePrefix}-platform-${environmentName}-rg'
}
