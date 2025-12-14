#!/usr/bin/env bash
# Usage: ./add_appwrite_invitations_fields.sh <endpoint> <projectId> <databaseId> <collectionId> <apiKey>
# Example:
#     ./add_appwrite_invitations_fields.sh "https://fra.cloud.appwrite.io" "69393f23001c2e93607c" "payrent_db" "invitations" "SCOPED_ADMIN_KEY"

ENDPOINT="$1"
PROJECT_ID="$2"
DATABASE_ID="$3"
COLLECTION_ID="$4"
API_KEY="$5"

if [ -z "$ENDPOINT" ] || [ -z "$PROJECT_ID" ] || [ -z "$DATABASE_ID" ] || [ -z "$COLLECTION_ID" ] || [ -z "$API_KEY" ]; then
  echo "Usage: $0 <endpoint> <projectId> <databaseId> <collectionId> <apiKey>"
  exit 1
fi

BASE="$ENDPOINT/v1/databases/$DATABASE_ID/collections/$COLLECTION_ID/attributes"

# 1) add string attribute for hash
echo "Adding attribute: connectionCodeHash (string)"
curl -s -X POST "$BASE/string" \
  -H "X-Appwrite-Project: $PROJECT_ID" \
  -H "X-Appwrite-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"key":"connectionCodeHash","size":256,"required":false,"array":false}'

# 2) add datetime attribute for expiry
echo "Adding attribute: connectionCodeExpiry (datetime)"
curl -s -X POST "$BASE/datetime" \
  -H "X-Appwrite-Project: $PROJECT_ID" \
  -H "X-Appwrite-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"key":"connectionCodeExpiry","required":false,"array":false}'

# 3) add boolean attribute for used flag
echo "Adding attribute: connectionCodeUsed (boolean)"
curl -s -X POST "$BASE/boolean" \
  -H "X-Appwrite-Project: $PROJECT_ID" \
  -H "X-Appwrite-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"key":"connectionCodeUsed","required":false,"default":false,"array":false}'

echo "Done. Verify the collection via Appwrite console."
