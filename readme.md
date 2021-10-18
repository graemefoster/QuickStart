# QuickStart

## Purpose
QuickStart is a sample Azure Web-Application with Api / Database. The main aim is to demonstrate not just how to create the resources, but to provide the runtime wireup, as-well as a deployment pipelines to test and production with a blue/green swap in production.

## Pipelines
QuickStart provides Github Actions pipelines, and Azure DevOps pipelines. 

Feel free to use this as a QuickStart for your own pipelines.

## Getting new users into the database
The standard approach for adding an AAD principal into a SQL database is this: ``` CREATE USER [<Name>] FROM EXTERNAL PROVIDER ```. But this requires the logged in user to have Directory Reader permissions which is a high level permission.

If you cannot give the CI/CD service principal Azure AD Directory Reader then there's a 'special' form of SQL to add the user without needing an AAD lookup: ``` CREATE USER [<Name>] WITH SID=<Binary representation of Application ID>, TYPE=E ```. See https://github.com/MicrosoftDocs/sql-docs/issues/2323 for more information.

-- For more information see here:
-- https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-service-principal-tutorial
