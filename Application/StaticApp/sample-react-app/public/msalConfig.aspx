<%@ Page ContentType="application/json" %>
{
    "msalConfig": {
        "auth": {
            "clientId": "<%= Environment.GetEnvironmentVariable("AzureAD__ClientId") %>",
            "authority": "https://login.microsoftonline.com/49f24cca-11a6-424d-b2e2-0650053986cc",
            "redirectUri": "https://<%= Environment.GetEnvironmentVariable("WEBSITE_HOSTNAME") %>/"
        },
        "cache": {
            "cacheLocation": "sessionStorage",
            "storeAuthStateInCookie": false
        }
    },
    "apiConfig": {
        "MicroServiceUrl" : "<%= Environment.GetEnvironmentVariable("ApiSettings__MicroServiceUrl") %>/",
        "BaseUrl": "<%= Environment.GetEnvironmentVariable("ApiSettings__URL") %>/",
        "Scopes": [
            "<%= Environment.GetEnvironmentVariable("ApiSettings__Scope") %>"
        ]
    }
}