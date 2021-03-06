# QuickStart Azure Devops Pipeline setup

You'll need access to an Azure Devops project to use these Pipelines.

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

## Step 4 - Add a Service Connection for the test and the prod environment

- Head to the ``` Project Settings ``` pane from your Project.
- Select ``` Service Connections ``` from the menu
- Select ``` Create service connection ```
- Select ``` Azure Resource Manager ``` and select ``` Next ```
- Select ``` Service Principal (manual) ``` and select ``` Next ```

Fill in the follow details: ``` Subscription Id, Subscription Name, Service principal key, Tenant ID ``` and select ``` Verify ```. Use the details from the Service Principal you created earlier.

- Enter the name ``` PlatformServiceConnectionTest ``` and click ``` Verify and save ```
- Repeat the process for name ``` PlatformServiceConnectionProduction ``` and click ``` Verify and save ```. This service principal needs access to the Prod environment.

## Step 4.5 - Add a Service Connection that can connect to AAD (recommend using a single service principal)

> This is only necessary if the Service Connection above cannot manipulate AAD objects.

- Head to the ``` Project Settings ``` pane from your Project.
- Select ``` Service Connections ``` from the menu
- Select ``` Create service connection ```
- Select ``` Azure Resource Manager ``` and select ``` Next ```
- Select ``` Service Principal (manual) ``` and select ``` Next ```

Fill in the follow details: ``` Subscription Id, Subscription Name, Service principal key, Tenant ID ``` and select ``` Verify ```. Use the details from the Service Principal you created earlier.

- Enter the name ``` PlatformAadServiceConnection ``` and click ``` Verify and save ```


## Step 5 - Create a Variable Group to store the variables required to deploy the Platform

- Head to the Pipelines - Library section of your Project.
- Select ``` + Variable Group ```, and change the name to Platform

Now add the following variables:

| Secret | Purpose | Other information | 
| --- | --- | --- |
| RESOURCE_PREFIX | A small string that prefixes the resources. |  It's just used to prevent against resource name clashes. Some services like keyvault and web-apps require globally unique names |
| DEPLOYMENTPRINCIPAL_ID | Application Id of the service principal you created to perform the deployment | Used to setup the AAD Admin account for Sql Server |
| DEPLOYMENTPRINCIPAL_NAME | Application name of the service principal you created to perform the deployment | Used to setup the AAD Admin account for Sql Server. This must match the name of the AAD service principal |

## Step 6 - Create the Platform pipeline

- Head to the Pipelines section of your Project.
- Select ``` Create Pipeline ```
- Select ``` Azure Repos Git ``` when asked 'Where is your code?'
- Select the Quickstart Repository
- Select ``` Existing Azure Pipelines YAML file ``` when asked to 'Configure your pipeline'
- Locate the ``` AzDevOps/Platform-Pipeline.yaml ``` file and select 'Continue'
- Press the dropdown on the ``` Run ``` button and click ``` Save ```
- Select ` Run Pipeline ` to deploy

At this point the pipeline will wait for permission to use the Service Connection.  Select the pipeline run and look for the warning box saying:

``` This pipeline needs permission to access 2 resources before this run can continue to Deploying platform ```

- Click ``` View ``` and select ``` Permit ``` on the two required permissions.

The platform pipeline is now ready to run. Run it and it will deploy the core app-services / keyvaults / databases required to run the application / api.


## Step 7 - Add the variables required for the application and api deployments

Head to the library section of your project. We're going to add the following variables to the PlatformTest, and the PlatformProduction group.

| Secret | Purpose | Other information | 
| --- | --- | --- |
| AZURE_WEBAPP_NAME | The name of the test web-app deployed in Step 6 |
| AZURE_WEBAPI_NAME | The name of the test web-api deployed in Step 6 |
| AZURE_SQL_CONNECTION_STRING | Sql connection string to the database deployed in Step 4 | This is used by the CI/CD pipeline to deploy the database. Format: ``` Server=tcp:<database-server-name>.database.windows.net,1433;Initial Catalog=<test-database-name>;Persist Security Info=False;;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30; ```   |

# Step 8 - Add the application and the api pipelines to devops

Complete these steps **twice**, once for the Application-Pipeline.yaml file, the next for the Api-Pipeline.yaml file

- Head to the Pipelines section of your Project.
- Select ``` Create Pipeline ```
- Select ``` Azure Repos Git ``` when asked 'Where is your code?'
- Select the Quickstart Repository
- Select ``` Existing Azure Pipelines YAML file ``` when asked to 'Configure your pipeline'
- Locate the ``` AzDevOps/[Application or Api]-Pipeline.yaml ``` file and select 'Continue'
- Press the dropdown on the ``` Run ``` button and click ``` Save ```
- Select ` Run Pipeline ` to deploy

