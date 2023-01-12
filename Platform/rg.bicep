targetScope = 'subscription'

param resourceGroupName string
param location string = deployment().location

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}

output rgName string = rg.name
