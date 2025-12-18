create-contract Appwrite Function

But: Node.js function to create a rental contract in a secure way (server-side), ensuring proper permissions.

Required environment variables (set in Appwrite Function settings):
- APPWRITE_ENDPOINT
- APPWRITE_PROJECT
- APPWRITE_API_KEY (secret key for this function)
- DATABASE_ID
- USERS_COLLECTION
- INVITATIONS_COLLECTION
- BIENS_COLLECTION
- CONTRATS_COLLECTION

Usage: the function expects a JSON payload on stdin (when executed) like:
{
  "token": "<invitationToken>",
  "locataireId": "<tenantUserId>"
}

Deployment:
1. Create a Function in Appwrite console with runtime Node.js (>=18), assign environment variables above.
2. Upload `index.js` as the source and set entrypoint to `index.js`.

Deployment helper scripts are included in the repository:
- `functions/deploy/deploy_function.sh` (bash) and `functions/deploy/deploy_function.ps1` (PowerShell).

Usage with environment variables (example):

APPWRITE_ENDPOINT=https://fra.cloud.appwrite.io/v1 \
APPWRITE_PROJECT=<PROJECT_ID> \
APPWRITE_API_KEY=<API_KEY> \
./functions/deploy/deploy_function.sh

After successful deployment, copy the function ID and set `Environment.createContractFunctionId` in `lib/config/environment.dart`.

Notes:
- This function acts with the project's API key and can create documents with `user:<id>` permissions which is not allowed from clients.
- It validates the invitation token and that the `locataireId` email corresponds to the invitation email to prevent abuse.
