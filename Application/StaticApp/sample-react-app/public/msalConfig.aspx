<%@ Page ContentType="application/json" %>
{
    "msalConfig": {
        "auth": {
            "clientId": "<%= Environment.GetEnvironmentVariable("AzureAD__ClientId") %>",
            "authority": "https://login.microsoftonline.com/49f24cca-11a6-424d-b2e2-0650053986cc",
            "redirectUri": "https://<%= Request.Url.Host %>/"
        },
        "cache": {
            "cacheLocation": "sessionStorage",
            "storeAuthStateInCookie": false
        }
    },
    "apiConfig": {
        "AppInsightsKey" : "<%= Environment.GetEnvironmentVariable("APPINSIGHTS_INSTRUMENTATIONKEY") %>",
        "MicroServiceUrl" : "<%= Environment.GetEnvironmentVariable("ApiSettings__MicroServiceUrl") %>/",
        "SubscriptionKey" : "<%= Environment.GetEnvironmentVariable("ApiSettings__SubscriptionKey") %>",
        "BaseUrl": "<%= Environment.GetEnvironmentVariable("ApiSettings__URL") %>/",
        "Scopes": [
            "<%= Environment.GetEnvironmentVariable("ApiSettings__Scope") %>"
        ]
    }
}