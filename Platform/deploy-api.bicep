param resourcePrefix string
param serverFarmId string
param environmentName string
param logAnalyticsWorkspaceId string
param deploySlot bool

var apiHostname = '${resourcePrefix}-${uniqueString(resourceGroup().name)}-${environmentName}-api'
var apiMsiName = '${resourcePrefix}-${uniqueString(resourceGroup().name)}-${environmentName}-msi'

resource ManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  location:resourceGroup().location
  name: apiMsiName
}

resource WebApi 'Microsoft.Web/sites@2021-01-15' = {
  name: apiHostname
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${ManagedIdentity.id}' : {}
    }
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v5.0'
    }
  }
}

resource WebAppAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${apiHostname}-appi'
  location: resourceGroup().location
  kind: 'Web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

resource WebAppInsightsHealthCheck 'Microsoft.Insights/webtests@2018-05-01-preview' = {
  location: resourceGroup().location
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
    Configuration: {
      WebTest: '<WebTest Name="webapp-ping-test" Id="678ddf91-1ab8-44c8-9274-123456789abc" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="300" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="" ><Items><Request Method="GET" Guid="b4162485-9114-fcfc-e086-123456789abc" Version="1.1" Url="https://${apiHostname}.azurewebsites.net/health" ThinkTime="0" Timeout="120" ParseDependentRequests="True" FollowRedirects="False" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" /></Items></WebTest>'
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

resource WebApiGreen 'Microsoft.Web/sites/slots@2021-01-15' = if(deploySlot) {
  parent: WebApi
  name: 'green'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v5.0'
    }
  }
}

output apiHostname string = apiHostname
output managedIdentityName string = ManagedIdentity.name
output managedIdentityAppId string = ManagedIdentity.properties.clientId
output appInsightsKey string = reference(WebAppAppInsights.id).InstrumentationKey
