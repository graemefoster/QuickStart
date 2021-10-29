# QuickStart
It can be tricky for new teams to get going in a cloud environment. Here's a braindump of what you need to thing about

- Setting up infrastructure
- Setting up pipelines
- Runtime authentication and authorisation
- Incremental database schema migration
- Blue / Green deployments

Most starter templates focus on the infrastructure. But few stitch everything together and put a bow around it.

QuickStart tries to do that for a simple scenario: A sample Azure Web-Application with an Api / Database, using OIDC / OAUTH, and scopes and roles. The aim is to not just create the resources, but wire them up securely, and provide sample blue / greeen deployment pipelines against a variety of CI / CD systems.

# Supported CI / CD platforms
| CI / CD | Status|
|---|---| 
| Github Actions | Done|
| Azure Devops | Not Done |
| Octopus 'as code' | Not Done | 

# Getting Started (Common steps)

To get started you'll need 

- An Azure Subscription to deploy the Azure resources to
- An Azure Subscription to deploy AAD objects to (this can be the same as above if you have privileges to create Service Principals that can manipulate the AAD directory assigned to the subscription)
- The az cli installed locally, or access to an Azure Cloud Shell.

Start by creating service principals in the subscriptions to let the CI/CD pipeline deploy resources and setup AAD applications.

## Create a Service Principal in the subscription where you deploy resources

``` az ad sp create-for-rbac --name "<ServicePrincipalName>" --role contributor --sdk-auth ```

This will output a JSON string with the Service Principal login information. Hold onto this as we'll use it when setting up our CI / CD Pipelines.

## Assign the above Service Principal the Directory.Writers role

When you've created the Service Principal, head to the [Azure Portal AAD page](https://ms.portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RolesAndAdministrators), find the 'Directory writers' role. Select that and add your Service Principal to it. 

> The Directory Writers role is used to create AAD Application objects to represent your API and Web Application. It's a high privilege role and requires AAD Admin consent. If you are unable to consent in the subscription you are deloying your resources into, you can still use QuickStart. Create a Service Principal in a directory that you control using ```  az ad sp create-for-rbac --name "<ServicePrincipalName>" --skip-assignment --sdk-auth  ``` and add it to the Directory.Writers role.

Next, let's move on to configuring the pipelines.

## Github Actions

Follow the instructions here [Github Actions Setup](./docs/actions-setup.md) to get started in Actions.

# Known issues

## Github Action Pipelines

### Github Action Secret Detection

My original intent was to deploy the platform as a set of Github Action jobs, each with a few steps. I hit some issues with Github's 'secret' detection logic which stopped me in my tracks.

TLDR; A job can write an output variable to make it available to other jobs. If Github Actions thinks it detects a secret then it blocks that output (and the output is essentially empty).

I had an output which contained something that Github had seen in a secret.... Technically the 'secret' wasn't secret, but Github Actions does not let you store plain-text project level variables. 

I didn't want to write too much code to get around this so decided to keep all the steps in a single 'deploy-platform' job.

## Azure Active Directory

### Roles inside JWT tokens
The sample defines two roles, Admin and User for authorisation. Both roles were declared Pascal case but when I retrieve a token I noticed the roles came back in lower-case. The Asp.Net Core libraries manage this OK.

### Audience in token
Microsoft.Identity.Web can handle an audience in a token following the naming convention ``` api://<client-id> ``` . If you have a different audience remember to tell the library what to expect.


## Azure SQL AAD Authorisation

### Adding External Users required Directory.Read permission
The standard approach for adding an AAD principal as a SQL User into a SQL database is 

``` CREATE USER [<Name>] FROM EXTERNAL PROVIDER ``` 

But this requires the logged in user to have 'Directory Reader' AAD permissions which is a high level permission not handed out lightly.

There's a 'special' form of SQL to add the user that doesn't need this permission. It's not really supported but can get you around this limitation

``` CREATE USER [<Name>] WITH SID=<Binary representation of Application ID>, TYPE=E ```

For more detail see here

- https://github.com/MicrosoftDocs/sql-docs/issues/2323 for more information.
- https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-service-principal-tutorial
