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

## Step 4 - Create 'test' Environment secrets

| Secret | Purpose | Other information | 
| --- | --- | --- |
| RESOURCE_PREFIX | A small string that prefixes the resources. |  It's just used to prevent against resource name clashes. Some services like keyvault and web-apps require globally unique names |
| AZURE_CREDENTIALS | Service Principal that has Contributor permissions on your subscription. | This is the output from the ``` az ad create-for-rbac ``` command |
| DEPLOYMENTPRINCIPAL_NAME | Application name of the above service principal | Used to setup the AAD Admin account for Sql Server. This must match the name of the AAD service principal |

> If you are unable to grant a Service Principal the Directory.Write role then you can configure your Web Application / API to use a different Azure Active Directory to the one backing your Azure Subscription. To do this, add a secret called ``` AAD_AZURE_CREDENTIALS ``` representing a Service Principal from the other directory.
 

## Step 5 - Run the platform Pipeline

- Goto the 'Actions' tab in your repository. 
- Select the 'Platform' workflow. 
- Click 'Run Workflow' followed by 'Run workflow'

This will kick off deployment of the core resources and will take a few minutes to run.

## Step 6 - Create 'Production' Environment secrets

Follow Step 4 and 5, but name the environment ``` prod ``` and use secrets for the Production platform.

At this point optionally put protection over the branch. Things to consider would be:

- Limit deployments to this environment to the 'main' branch
- Add reviewers to deployments before they are allowed to run against this environment

## Pipelines

QuickStart contains 3 github action pipelines

| Pipeline | Purpose |
|---|---|
| platform.yaml | Build the Azure & AAD foundations to run the apps and apis |
| api.yaml | Pipeline to build and deploy the Api, run a database migration, and demonstrate blue/green between old and new revision  |
| app.yaml | Pipeline to build and deploy the AppService, and demonstrate blue/green between old and new revision   |
| container-app.yaml | Pipeline to build and deploy the Micro Service, and demonstrate blue/green between old and new revision |
| static-app.yaml | Pipeline to build and deploy the Static App, and demonstrate blue/green between old and new version  |


