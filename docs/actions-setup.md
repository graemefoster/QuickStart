# QuickStart Github Actions setup

You'll need access to a Github account to use Github Actions.

## Step 1 - Clone the repo locally

``` git clone https://github.com/graemefoster/QuickStart/```

## Step 2 - Create a new repository in your Github account

## Step 3 - Add a remote to your local repository and push

```bash
cd QuickStart
git remote remove origin
git remote add origin <new-repository-url>
git push origin 
```

## Step 4 - Create 'Test' Environment secrets

| Secret | Purpose | Other information | 
| --- | --- | --- |
| RESOURCE_PREFIX | A small string that prefixes the resources. |  It's just used to prevent against resource name clashes. Some services like keyvault and web-apps require globally unique names |
| AZURE_CREDENTIALS | Service Principal that has Contributor permissions on your subscription. | This is the output from the ``` az ad create-for-rbac ``` command |
| DEPLOYMENTPRINCIPAL_ID | Application Id of the above service principal | Used to setup the AAD Admin account for Sql Server |
| DEPLOYMENTPRINCIPAL_NAME | Application name of the above service principal | Used to setup the AAD Admin account for Sql Server. This must match the name of the AAD service principal |

> If you are unable to grant a Service Principal the Directory.Write role then you can configure your Web Application / API to use a different Azure Active Directory to the one backing your Azure Subscription. To do this, add a secret called ``` AAD_AZURE_CREDENTIALS ``` representing a Service Principal from the other directory.
 

## Step 5 - Run the platform Pipeline

- Goto the 'Actions' tab in your repository. 
- Select the 'Platform' workflow. 
- Click 'Run Workflow' followed by 'Run workflow'

This will kick off deployment of the core resources and will take a few minutes to run.

## Step 6 - Create 'Test' Environment secrets

- Start by creating a new environment called 'Test' in the 'Settings' tab of your Git repository

- You'll now need to create 3 secrets against the environment.

| Secret | Purpose | Other information | 
| --- | --- | --- |
| AZURE_WEBAPP_NAME | The name of the test web-app deployed in Step 4 |
| AZURE_WEBAPI_NAME | The name of the test web-api deployed in Step 4 |
| AZURE_SQL_CONNECTION_STRING | Sql connection string to the database deployed in Step 4 | This is used by the CI/CD pipeline to deploy the database. Format: ``` Server=tcp:<database-server-name>.database.windows.net,1433;Initial Catalog=<test-database-name>;Persist Security Info=False;;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30; ```   |

The server-name / database-name can be found in the ``` <prefix>-platform-rg ``` resource group deployed in step 4.

## Step 7 - Create 'Production' Environment secrets

Follow Step 4 and 6, but name the environment ``` Production ``` and use secrets from the Production platform.

At this point optionally put protection over the branch. Things to consider would be:

- Limit deployments to this environment to the 'main' branch
- Add reviewers to deployments before they are allowed to run against this environment

## Pipelines

QuickStart contains 3 github action pipelines

| Pipeline | Purpose |
|---|---|
| platform.yaml | Build the Azure & AAD foundations to run the apps and apis |
| api.yaml | Pipeline to build and deploy the API, and run a database migration |
| app.yaml | Pipeline to build and deploy the APP  |


