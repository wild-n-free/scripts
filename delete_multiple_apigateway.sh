#!/bin/bash

# Default values
REGION=""
PROFILE=""
SLEEP_TIME=30

# Usage function
usage() {
  echo "Usage: $0 --region <region> --profile <aws_profile>"
  exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --region)
      REGION="$2"
      shift 2
      ;;
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

# Check required arguments
if [[ -z "$REGION" || -z "$PROFILE" ]]; then
  usage
fi

# Fetch all REST API IDs
echo "Fetching REST API IDs from region '$REGION' using profile '$PROFILE'..."
API_IDS=$(aws apigateway get-rest-apis \
  --region "$REGION" \
  --query 'items[*].id' \
  --output text \
  --profile "$PROFILE")

# Loop through each API ID and delete
for rest_api_id in $API_IDS; do
  echo "Deleting REST API with ID: $rest_api_id"
  aws apigateway delete-rest-api \
    --region "$REGION" \
    --rest-api-id "$rest_api_id" \
    --profile "$PROFILE"

  if [ $? -eq 0 ]; then
    echo "Successfully deleted REST API: $rest_api_id. Sleeping for $SLEEP_TIME seconds..."
  else
    echo "Failed to delete REST API: $rest_api_id" >&2
  fi

  sleep "$SLEEP_TIME"
done

echo "All specified REST APIs processed."
