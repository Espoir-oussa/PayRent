#!/usr/bin/env bash
set -euo pipefail

# Déploiement Appwrite Function (Unix)
# Usage:
# APPWRITE_ENDPOINT=https://fra.cloud.appwrite.io/v1 \
# APPWRITE_PROJECT=<PROJECT_ID> \
# APPWRITE_API_KEY=<API_KEY> \
# ./deploy_function.sh

: ${APPWRITE_ENDPOINT:?Need to set APPWRITE_ENDPOINT}
: ${APPWRITE_PROJECT:?Need to set APPWRITE_PROJECT}
: ${APPWRITE_API_KEY:?Need to set APPWRITE_API_KEY}
: ${FUNCTION_NAME:=create-contract}
: ${RUNTIME:=node-18.0}
: ${ENTRYPOINT:=index.js}
: ${SOURCE_DIR:=functions/create-contract}

ZIP_FILE="${FUNCTION_NAME}.zip"

echo "📦 Zipping $SOURCE_DIR -> $ZIP_FILE"
rm -f "$ZIP_FILE"
(cd "$SOURCE_DIR" && zip -r "../$ZIP_FILE" .)

# If FUNCTION_ID is not provided, try to create the function
if [[ -z "${FUNCTION_ID:-}" ]]; then
  echo "🔎 No FUNCTION_ID provided. Creating function '$FUNCTION_NAME' in project $APPWRITE_PROJECT..."
  resp=$(curl -s -X POST "${APPWRITE_ENDPOINT}/functions" \
    -H "x-appwrite-project: ${APPWRITE_PROJECT}" \
    -H "x-appwrite-key: ${APPWRITE_API_KEY}" \
    -H "content-type: application/json" \
    -d "{\"name\": \"${FUNCTION_NAME}\", \"runtime\": \"${RUNTIME}\", \"entrypoint\": \"${ENTRYPOINT}\"}")
  echo "Response: $resp"
  FUNCTION_ID=$(echo "$resp" | jq -r '"\(.\$id)"' 2>/dev/null || echo "")
  if [[ -z "$FUNCTION_ID" || "$FUNCTION_ID" == "null" ]]; then
    echo "⚠️ Could not create function automatically. Please create it manually in Appwrite console and set FUNCTION_ID environment variable. Response: $resp"
    exit 1
  fi
  echo "✅ Function created with ID: $FUNCTION_ID"
else
  echo "ℹ️ Using provided FUNCTION_ID: $FUNCTION_ID"
fi

# Create deployment (upload zip)
echo "🚀 Creating deployment for function $FUNCTION_ID"
deployResp=$(curl -s -X POST "${APPWRITE_ENDPOINT}/functions/${FUNCTION_ID}/deployments" \
  -H "x-appwrite-project: ${APPWRITE_PROJECT}" \
  -H "x-appwrite-key: ${APPWRITE_API_KEY}" \
  -F "code=@${ZIP_FILE}" \
  -F "activate=true")

echo "Deployment response: $deployResp"

newDeploymentId=$(echo "$deployResp" | jq -r '.\$id // .id // empty')
if [[ -z "$newDeploymentId" ]]; then
  echo "⚠️ Deployment failed. Please check the response above."
  exit 1
fi

echo "✅ Deployment created: $newDeploymentId"

echo "🔁 Note: Copiez l'ID de la function ($FUNCTION_ID) et mettez à jour 'Environment.createContractFunctionId' dans 'lib/config/environment.dart'"

echo "🎉 Done."