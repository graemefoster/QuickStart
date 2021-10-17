-- Script to set up initial users for the database.
IF NOT EXISTS(SELECT * from sys.database_principals WHERE NAME = '${{ env.MANAGED_IDENTITY_NAME }}')
    CREATE USER [${{ env.MANAGED_IDENTITY_NAME }}] FROM EXTERNAL PROVIDER;

EXEC sp_addrolemember 'db_owner', '${{ env.MANAGED_IDENTITY_NAME }}'

print 'Added user ${{ env.MANAGED_IDENTITY_NAME }} as db_owner to database'
