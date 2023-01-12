targetScope = 'resourceGroup'
param consumerKeyVaultName string
@secure()
param subscriptionPrimaryKey string
param secretName string

resource ApimProductKeySecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: '${consumerKeyVaultName}/${secretName}'
  properties: {
    value: subscriptionPrimaryKey
  }
}
