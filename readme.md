# QuickStart

## Purpose
QuickStart is a sample Azure Web-Application with Api / Database. The main aim is to demonstrate not just how to create the resources, but to provide the runtime wireup, as-well as a deployment pipelines to test and production with a blue/green swap in production.

## Pipelines
QuickStart provides Github Actions pipelines, and Azure DevOps pipelines. 

Feel free to use this as a QuickStart for your own pipelines.

> If you cannot give the CI/CD service principal Azure AD Directory Reader then there's a bit of effort to get the Database migration going. 
Change the Sql Server AAD Admin to someone who does have the Directory Reader role. Then manually add the Service Principal users to the database using

``` sql
CREATE USER [<Name>] FROM EXTERNAL PROVIDER; 
GO
EXEC sp_addrolemember 'db_owner', [<Name>]
GO

-- This is supposed to let your principal add new users, but in my attmpt, I still got an error if the principal making the connection didn't have AAD Directory Reader, regardless of the server principal.
-- GRANT ALTER ANY USER TO [<Name>]
-- GO

--You'll need to do this for each user you want :(
CREATE USER [<OtherUser1>] FROM EXTERNAL PROVIDER;
GO
CREATE USER [<OtherUser2>] FROM EXTERNAL PROVIDER;
GO

-- For more information see here:
-- https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-service-principal-tutorial
-- https://github.com/MicrosoftDocs/sql-docs/issues/2323

```
