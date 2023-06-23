targetScope = 'resourceGroup'

param resourcePrefix string
param environmentName string
param serverFarmId string
param logAnalyticsWorkspaceId string
param containerAppFqdn string
param apiAadClientId string
param apiHostName string
param appAadClientId string
param aadTenantId string

param location string = resourceGroup().location
param uniqueness string

@secure()
param appClientSecret string

var subscriptionSecretName = 'ApiSubscriptionKey'
var deploySlot = environmentName != 'test'

var appHostname = '${resourcePrefix}-${uniqueness}-${environmentName}-webapp'
var appKeyVaultName = '${resourcePrefix}-app-${environmentName}-kv'

@description('This is the built-in Key Vault Administrator role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#key-vault-administrator')
resource keyVaultSecretsUserRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

resource AppKeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: appKeyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
  }

  resource secret 'secrets' = {
    name: 'ApplicationClientSecret'
    properties: {
      value: appClientSecret
    }
  }
}

resource KeyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'aspDiagnostics'
  scope: AppKeyVault
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 3
          enabled: true
        }
      }
    ]
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          days: 3
          enabled: true
        }
      }
    ]
  }
}

resource WebAppAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${appHostname}-appi'
  location: location
  kind: 'Web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

var settings = [
  {
    name: 'WEBSITE_RUN_FROM_PACKAGE'
    value: '1'
  }
  {
    name: 'ASPNETCORE_ENVIRONMENT'
    value: environmentName
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: WebAppAppInsights.properties.ConnectionString
  }
  {
    name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
    value: '~2'
  }
  {
    name: 'XDT_MicrosoftApplicationInsights_Mode'
    value: 'recommended'
  }
  {
    name: 'InstrumentationEngine_EXTENSION_VERSION'
    value: '~1'
  }
  {
    name: 'XDT_MicrosoftApplicationInsights_BaseExtensions'
    value: '~1'
  }
  {
    name: 'ApiSettings__MicroServiceUrl'
    value: 'https://${containerAppFqdn}'
  }
  {
    name: 'ApiSettings__SubscriptionKey'
    value: '@Microsoft.KeyVault(VaultName=${AppKeyVault.name};SecretName=${subscriptionSecretName})'
  }
  {
    name: 'ApiSettings__URL'
    value: 'https://${apiHostName}'
  }
  {
    name: 'ApiSettings__Scope'
    value: 'api://${apiAadClientId}/Pets.Manage'
  }
  {
    name: 'AzureAD__ClientId'
    value: appAadClientId
  }
  {
    name: 'AzureAD__TenantId'
    value: aadTenantId
  }
  {
    name: 'AzureAD__ClientSecret'
    value: '@Microsoft.KeyVault(VaultName=${appKeyVaultName};SecretName=ApplicationClientSecret)'
  }
]

resource WebApp 'Microsoft.Web/sites@2021-01-15' = {
  name: appHostname
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v7.0'
      appSettings: settings
    }
  }
}


resource WebAppAppInsightsHealthCheck 'Microsoft.Insights/webtests@2018-05-01-preview' = {
  location: location
  name: 'webapp-ping-test'
  kind: 'ping'
  //Must have tag pointing to App Insights
  tags: {
    'hidden-link:${WebAppAppInsights.id}' : 'Resource'
  }
  properties: {
    Kind: 'ping'
    Frequency: 300
    Name: 'webapp-ping-test'
    SyntheticMonitorId: 'webapp-ping-test'
    Enabled: true
    Timeout: 10
    Configuration: {
      WebTest: '<WebTest Name="webapp-ping-test" Id="678ddf91-1ab8-44c8-9274-123456789abc" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="300" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="" ><Items><Request Method="GET" Guid="b4162485-9114-fcfc-e086-123456789abc" Version="1.1" Url="https://${appHostname}.azurewebsites.net/health" ThinkTime="0" Timeout="120" ParseDependentRequests="False" FollowRedirects="False" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" /></Items></WebTest>'
    }
    //Locations here: https://docs.microsoft.com/en-us/azure/azure-monitor/app/monitor-web-app-availability
    Locations: [
      {
        Id: 'emea-au-syd-edge' //australia east
      }
      {
        Id: 'apac-sg-sin-azr' //south-east asia
      }
      {
        Id: 'emea-nl-ams-azr' //west-europe
      }
      {
        Id: 'us-va-ash-azr' //east-us
      }
      {
        Id: 'us-ca-sjc-azr' //west-us
      }
    ]
  }
}

resource KeyVaultAuth 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('${appHostname}-read-${appKeyVaultName}')
  scope: AppKeyVault
  properties: {
    roleDefinitionId: keyVaultSecretsUserRoleDefinition.id
    principalId: WebApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource WebAppGreen 'Microsoft.Web/sites/slots@2021-01-15' = if(deploySlot) {
  parent: WebApp
  name: 'green'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v7.0'
      appSettings: settings
    }
  }
}

resource GreenKeyVaultAuth 'Microsoft.Authorization/roleAssignments@2022-04-01' = if(deploySlot) {
  name: guid('${appHostname}.green-read-${appKeyVaultName}')
  scope: AppKeyVault
  properties: {
    roleDefinitionId: keyVaultSecretsUserRoleDefinition.id
    principalId: (deploySlot == true) ? WebAppGreen.identity.principalId : 'Not deploying'
    principalType: 'ServicePrincipal'
  }
} 

output appName string = WebApp.name
output appHostname string = WebApp.properties.hostNames[0]
output appSlotHostname string = deploySlot ? WebAppGreen.properties.hostNames[0] : ''
output appInsightsKey string = WebAppAppInsights.properties.InstrumentationKey
output appKeyVaultName string = appKeyVaultName
output apiKeySecretName string = subscriptionSecretName
