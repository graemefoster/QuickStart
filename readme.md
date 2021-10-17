# QuickStart

## Purpose
QuickStart is a sample Azure Web-Application with Api / Database. The main aim is to demonstrate not just how to create the resources, but to provide the runtime wireup, as-well as a deployment pipelines to test and production with a blue/green swap in production.

## Pipelines
QuickStart provides Github Actions pipelines, and Azure DevOps pipelines. 

Feel free to use this as a QuickStart for your own pipelines.

## Things to know
If you cannot assign the AAD director reader role to your CI/CD pipeline then you'll need to do a bit of pre-work after the sql server has deployed.

 - Change the Sql admin to someone who does have that role
 - Manually add the CI/CD User to the database
 - ``` CREATE USER [<Name>] FROM EXTERNAL PROVIDER; GRANT ALTER ANY USER TO [<Name>]; GO ```
 - https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-service-principal-tutorial
 