#!/bin/bash

# This script sets up 2 AAD applications to control access to the Applications / API.
# One is configured for an OIDC flow to sign the user into the app.
# The 2nd configures authorisation for the API.

# Your CI/CD will need permission to create AAD App Registrations else it won't work.
RESOURCE_PREFIX=$1
ENVIRONMENT_NAME=$2
UNIQUENESS=$3

WEBSITE_HOST_NAME="$RESOURCE_PREFIX-$UNIQUENESS-$ENVIRONMENT_NAME-webapp.azurewebsites.net"
WEBSITE_SLOT_HOST_NAME="$RESOURCE_PREFIX-$UNIQUENESS-$ENVIRONMENT_NAME-webapp0-green.azurewebsites.net"

WEB_API_HOST_NAME="$RESOURCE_PREFIX-$UNIQUENESS-$ENVIRONMENT_NAME-api.azurewebsites.net"

SPA_HOST_NAME="$RESOURCE_PREFIX-$UNIQUENESS-$ENVIRONMENT_NAME-spa.azurewebsites.net"
SPA_SLOT_HOST_NAME="$RESOURCE_PREFIX-$UNIQUENESS-$ENVIRONMENT_NAME-spa-green.azurewebsites.net"

# Build the application representing the API.
read -r -d '' API_ROLES << EOM
[{
    "allowedMemberTypes": [
      "User"
    ],
    "id" : "a0bdae44-5469-4395-bba4-e0158a0ebc54",
    "description": "Readers can read pets",
    "displayName": "Reader",
    "isEnabled": "true",
    "value": "reader"
},
{
    "allowedMemberTypes": [
      "User"
    ],
    "id" : "d8eb2b97-42e6-47af-bab7-8f964e8d3a29",
    "description": "Admins can create pets",
    "displayName": "Admin",
    "isEnabled": "true",
    "value": "admin"
}
]
EOM

AAD_API_APPLICATION_ID=$(az ad app create --display-name "$WEB_API_HOST_NAME" --app-roles "$API_ROLES" --query "appId" -o tsv | tr -d '\r')
_=$(az ad app update --id $AAD_API_APPLICATION_ID --identifier-uris "api://${AAD_API_APPLICATION_ID}")
echo "Created / retrieved API Application Id ${AAD_API_APPLICATION_ID}"
echo "apiClientId=${AAD_API_APPLICATION_ID}" >> $GITHUB_OUTPUT


###Remove api permissions: disable default exposed scope first (https://learn.microsoft.com/en-us/azure/healthcare-apis/register-application-cli-rest)
# az ad app no longer adds a default 'user_impersonation' scope .
# default_scope=$(az ad app show --id $AAD_API_APPLICATION_ID | jq '.oauth2Permissions[0].isEnabled = false' | jq -r '.oauth2Permissions')
# az ad app update --id $AAD_API_APPLICATION_ID --set oauth2Permissions="$default_scope"

#Create a scope we can prompt the user for 
read -r -d '' API_SCOPES << EOM
{
    "oauth2PermissionScopes": [
        {
                "adminConsentDescription": "Allows the app to see and create pets",
                "adminConsentDisplayName": "Pets",
                "id": "922d92cd-454b-4544-afd8-99f9a6ed9a44",
                "isEnabled": true,
                "type": "User",
                "userConsentDescription": "Allows the app to see and create pets",
                "userConsentDisplayName": "See pets",
                "value": "Pets.Manage"
            }
        ],
    "requestedAccessTokenVersion": 2
}
EOM
az ad app update --id "$AAD_API_APPLICATION_ID" --set api="$API_SCOPES"
echo "Set Scopes on API"

#Create a service principal so we can request permissions against this in our directory
_=$(az ad sp create --id $AAD_API_APPLICATION_ID)
echo "Created service principal to represent API in directory"



# Build the application representing the website.
# All we want to do here is sign someone in. The application behaves like a SPA using a separate API for resource access.
read -r -d '' REQUIRED_WEBSITE_RESOURCE_ACCESS << EOM
[{
    "resourceAppId": "00000003-0000-0000-c000-000000000000",
    "resourceAccess": [
        {
            "id": "e1fe6dd8-ba31-4d61-89e7-88639da4683d",
            "type": "Scope"
        }
   ]
},
{
    "resourceAppId": "$AAD_API_APPLICATION_ID",
    "resourceAccess": [
        {
            "id": "922d92cd-454b-4544-afd8-99f9a6ed9a44",
            "type": "Scope"
        },
   ]
}]
EOM

AAD_WEBSITE_APPLICATION_ID=$(az ad app create --display-name $WEBSITE_HOST_NAME --required-resource-access "$REQUIRED_WEBSITE_RESOURCE_ACCESS" --query "appId" -o tsv | tr -d '\r')
_=$(az ad app update --id $AAD_WEBSITE_APPLICATION_ID --identifier-uris "api://${AAD_WEBSITE_APPLICATION_ID}")
AAD_WEBSITE_OBJECT_ID=$(az ad app show --id $AAD_WEBSITE_APPLICATION_ID --query "id" -o tsv | tr -d '\r')
echo "Created / retrieved Web Application Id ${AAD_WEBSITE_APPLICATION_ID}. ObjectId ${AAD_WEBSITE_OBJECT_ID}"
echo "applicationClientId=${AAD_WEBSITE_APPLICATION_ID}" >> $GITHUB_OUTPUT

#https://github.com/Azure/azure-cli/issues/9501
echo "Calling REST Api to update redirects for web and public client"
if [ "$ENVIRONMENT_NAME" = "Development" ]; then
    LOCAL_REDIRECT=", \"http://localhost:3000\""
else
    LOCAL_REDIRECT=""
fi

read -r -d '' CLIENT_SPA_REDIRECTS << EOM
{
    "spa" : {
        "redirectUris" : [ "https://${SPA_HOST_NAME}/", "https://${SPA_SLOT_HOST_NAME}/" $LOCAL_REDIRECT ]
    }
}
EOM

echo $CLIENT_SPA_REDIRECTS

az rest --method PATCH \
    --uri "https://graph.microsoft.com/v1.0/applications/${AAD_WEBSITE_OBJECT_ID}" \
    --headers 'Content-Type=application/json' \
    --body "$CLIENT_SPA_REDIRECTS"

echo "Patched SPA redirects"

if [ "$ENVIRONMENT_NAME" = "Development" ]; then
    LOCAL_REDIRECT=", \"https://sampleapp.localtest.me:4430/signin-oidc\""
else
    LOCAL_REDIRECT=""
fi

read -r -d '' CLIENT_WEB_REDIRECTS << EOM
{
    "web" : {
        "redirectUris" : [ "https://${WEBSITE_HOST_NAME}/signin-oidc", "https://${WEBSITE_SLOT_HOST_NAME}/signin-oidc" $LOCAL_REDIRECT ]
    }
}
EOM

az rest --method PATCH \
    --uri "https://graph.microsoft.com/v1.0/applications/${AAD_WEBSITE_OBJECT_ID}" \
    --headers 'Content-Type=application/json' \
    --body "$CLIENT_WEB_REDIRECTS"

echo "Patched Web redirects"

echo "Patched redirects for web and public client"

_=$(az ad sp create --id $AAD_WEBSITE_APPLICATION_ID)
echo "Created service principal to represent APP in directory"

#Get a secret so we can do a code exchange in the app. 
#TODO - Conscious choice to overwrite. This should be part of a rotation
WEBSITE_CLIENT_SECRET=$(az ad app credential reset --id $AAD_WEBSITE_APPLICATION_ID --query "password" -o tsv)

#TODO write direct to KeyVault?
echo "::add-mask::${WEBSITE_CLIENT_SECRET}"
echo "applicationClientSecret=${WEBSITE_CLIENT_SECRET}" >> $GITHUB_OUTPUT
echo "aadTenantId=$(az account show --query 'tenantId' --output tsv)" >> $GITHUB_OUTPUT

# #Az Devops
# echo "##vso[task.setvariable variable=applicationClientId;isOutput=true]${AAD_WEBSITE_APPLICATION_ID}"
# echo "##vso[task.setvariable variable=applicationClientSecret;isOutput=true;issecret=true]${WEBSITE_CLIENT_SECRET}"
# echo "##vso[task.setvariable variable=apiClientId;isOutput=true]${AAD_API_APPLICATION_ID}"
