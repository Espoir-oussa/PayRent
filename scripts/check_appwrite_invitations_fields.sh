#!/usr/bin/env bash
# Usage: ./scripts/check_appwrite_invitations_fields.sh <endpoint> <projectId> <databaseId> <collectionId> <apiKey>
# Example:
# ./scripts/check_appwrite_invitations_fields.sh "https://fra.cloud.appwrite.io" "69393f23001c2e93607c" "payrent_db" "invitations" "SCOPED_ADMIN_KEY"

ENDPOINT="$1"
PROJECT_ID="$2"
DATABASE_ID="$3"
COLLECTION_ID="$4"
API_KEY="$5"

if [ -z "$ENDPOINT" ] || [ -z "$PROJECT_ID" ] || [ -z "$DATABASE_ID" ] || [ -z "$COLLECTION_ID" ] || [ -z "$API_KEY" ]; then
  echo "Usage: $0 <endpoint> <projectId> <databaseId> <collectionId> <apiKey>"
  exit 1
fi

URL="$ENDPOINT/v1/databases/$DATABASE_ID/collections/$COLLECTION_ID"

resp=$(curl -s -H "X-Appwrite-Project: $PROJECT_ID" -H "X-Appwrite-Key: $API_KEY" "$URL")
if [ -z "$resp" ]; then
  echo "❌ No response from Appwrite API or invalid credentials"
  exit 2
fi

# parse JSON attributes keys using jq (optional; if jq not present, simple grep)
if command -v jq >/dev/null 2>&1; then
  keys=$(echo "$resp" | jq -r '.attributes[].key')
else
  # fallback: use grep/awk - unreliable but usable
  keys=$(echo "$resp" | grep -o '"key":"[^"]*"' | sed 's/"key":"//;s/"$//')
fi

echo "Attributs trouvés dans la collection $COLLECTION_ID :"
for k in $keys; do
  echo " - $k"
done

required=("connectionCodeHash" "connectionCodeExpiry" "connectionCodeUsed")
missing=()
for r in "${required[@]}"; do
  found=false
  for k in $keys; do
    if [ "$k" == "$r" ]; then
      found=true
      break
    fi
  done
  if [ "$found" = false ]; then
    missing+=("$r")
  fi
done

if [ ${#missing[@]} -eq 0 ]; then
  echo "✅ Tous les attributs requis sont présents."
  exit 0
else
  echo "⚠️ Attributs manquants: ${missing[*]}"
  exit 1
fi
