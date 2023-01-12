targetScope = 'subscription'

param consumerKeyVaultName string
param consumerKeyVaultResourceGroupName string

@secure()
param subscriptionPrimaryKey string

param secretName string

module SubSecret 'subscription-secret-inr.bicep' = {
  name: '${deployment().name}-inr'
  scope: resourceGroup(consumerKeyVaultResourceGroupName)
  params: {
    consumerKeyVaultName: consumerKeyVaultName
    secretName: secretName
    subscriptionPrimaryKey: subscriptionPrimaryKey
  }
}

