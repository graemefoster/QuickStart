# QuickStart Github Actions setup

QuickStart contains 3 github action pipelines

| Pipeline | Purpose |
|---|---|
| platform.yaml | Build the Azure & AAD foundations to run the apps and apis |
| api.yaml | Pipeline to build and deploy the API, and run a database migration |
| app.yaml | Pipeline to build and deploy the APP  |

## platform.yaml

| Secret | Purpose | Other information | 
| --- | --- | --- |
| RESOURCE_PREFIX | A small string that prefixes the resources. |  It's just used to prevent against resource name clashes. Some services like keyvault and web-apps require globally unique names |
| AZURE_CREDENTIALS | Service Principal details that has Contributor permissions on your subscription. | |
| DEPLOYMENTPRINCIPAL_ID | Application Id of the above service principal | Used to setup the AAD Admin account for Sql Server |
| DEPLOYMENTPRINCIPAL_NAME | Application Id of the above service principal | Used to setup the AAD Admin account for Sql Server |
| AAD_AZURE_CREDENTIALS | Used to create AAD Application entries to represent the App and the Api. This service principal needs to be a member of the Directory Writers role. Note this can be the same as AZURE_CREDENTIALS above. 

## api.yaml

## app.yaml

