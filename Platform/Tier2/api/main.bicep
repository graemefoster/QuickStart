targetScope = 'resourceGroup'

param resourcePrefix string
param environmentName string
param platformResourceGroupName string
param logAnalyticsWorkspaceId string
param serverFarmId string
param databaseServerName string
param uniqueness string

param location string = resourceGroup().location

var apiName = '${resourcePrefix}-${uniqueness}-${environmentName}-api'
var apiMsiName = '${resourcePrefix}-${uniqueness}-${environmentName}-msi'

var deploySlot = environmentName != 'test'

module database 'database.bicep' = {
  name: '${deployment().name}-db'
  scope: resourceGroup(platformResourceGroupName)
  params: {
    databaseServerName: databaseServerName
    environmentName: environmentName
    resourcePrefix: resourcePrefix
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    location: location
  }
}

resource ManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  location: location
  name: apiMsiName
}


resource WebAppAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${apiName}-appi'
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
  { name: 'ASPNETCORE_ENVIRONMENT'
    value: 'Production' 
  }
  { 
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: WebAppAppInsights.properties.InstrumentationKey 
  }
  { 
    name: 'ApiSettings__UserAssignedClientId'
    value: ManagedIdentity.properties.clientId 
  }
  // { 
  //   name: 'AzureAD__ClientId'
  //   value: apiAadClientId 
  // }
  { 
    name: 'ApiSettings__ConnectionString'
    value: database.outputs.apiDatabaseConnectionString
  }
]

resource WebApi 'Microsoft.Web/sites@2021-01-15' = {
  name: apiName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${ManagedIdentity.id}': {}
    }
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v5.0'
      appSettings: settings
    }
  }
}

resource WebAppInsightsHealthCheck 'Microsoft.Insights/webtests@2018-05-01-preview' = {
  location: location
  name: 'webapi-ping-test'
  kind: 'ping'
  //Must have tag pointing to App Insights
  tags: {
    'hidden-link:${WebAppAppInsights.id}': 'Resource'
  }
  properties: {
    Kind: 'ping'
    Frequency: 300
    Name: 'webapi-ping-test'
    SyntheticMonitorId: 'webapi-ping-test'
    Enabled: true
    Timeout: 10
    Configuration: {
      WebTest: '<WebTest Name="webapi-ping-test" Id="678ddf92-1ab8-44c8-9274-123456789abc" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="300" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="" ><Items><Request Method="GET" Guid="b4162485-9114-fcfc-e086-123456789abc" Version="1.1" Url="https://${apiName}.azurewebsites.net/health" ThinkTime="0" Timeout="120" ParseDependentRequests="False" FollowRedirects="False" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" /></Items></WebTest>'
    }
    Locations: [
      {
        Id: 'emea-au-syd-edge'
      }
      {
        Id: 'apac-sg-sin-azr'
      }
    ]
  }
}

resource WebApiGreen 'Microsoft.Web/sites/slots@2021-01-15' = if (deploySlot) {
  parent: WebApi
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
      netFrameworkVersion: 'v5.0'
      appSettings: settings
    }
  }
}

output appName string = WebApi.name
output appHostname string = WebApi.properties.hostNames[0]
output appSlotHostname string = deploySlot ? WebApiGreen.properties.hostNames[0] : ''
output managedIdentityName string = ManagedIdentity.name
output managedIdentityAppId string = ManagedIdentity.properties.clientId
output appInsightsKey string = reference(WebAppAppInsights.id).InstrumentationKey
output databaseConnectionString string = database.outputs.apiDatabaseConnectionString
