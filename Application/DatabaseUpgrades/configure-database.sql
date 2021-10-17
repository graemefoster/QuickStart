-- Script to set up initial users for the database.
IF NOT EXISTS(SELECT * from sys.database_principals WHERE NAME = '${{ env.AZURE_WEBAPI_NAME }}')
    CREATE USER [${{ env.AZURE_WEBAPI_NAME }}] FROM EXTERNAL PROVIDER;

EXEC sp_addrolemember 'db_owner', '${{ env.AZURE_WEBAPI_NAME }}'

print 'Added user ${{ env.AZURE_WEBAPI_NAME }} as db_owner to database'
