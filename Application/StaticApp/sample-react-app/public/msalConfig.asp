<% 
Response.ContentType = "application/json"
Set foo = CreateObject("WScript.Shell")
apiUrl = foo.Environment("PROCESS").Item("ApiSettings__URL")
scope = foo.Environment("PROCESS").Item("ApiSettings__Scope")
clientId = foo.Environment("PROCESS").Item("AzureAD__ClientId")
hostName = foo.Environment("PROCESS").Item("WEBSITE_HOSTNAME")
%>
{
    "msalConfig": {
        "auth": {
            "clientId": "<%= clientId %>",
            "authority": "https://login.microsoftonline.com/49f24cca-11a6-424d-b2e2-0650053986cc",
            "redirectUri": "https://<%= hostName %>/"
        },
        "cache": {
            "cacheLocation": "sessionStorage",
            "storeAuthStateInCookie": false
        }
    },
    "apiConfig": {
        "BaseUrl": "<%= apiUrl %>",
        "Scopes": [
            "<%= scope %>"
        ]
    }
}