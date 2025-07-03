#!/bin/bash

# Default values
REGION=""
PROFILE=""
SLEEP_TIME=30

# Usage instructions
usage() {
  echo "Usage: $0 --region <region> --profile <aws_profile>"
  exit 1
}

# Parse CLI arguments
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

# Validate required arguments
if [[ -z "$REGION" || -z "$PROFILE" ]]; then
  usage
fi

# Fetch all domain names
echo "Fetching custom domain names from region '$REGION' using profile '$PROFILE'..."
DOMAIN_NAMES=$(aws apigateway get-domain-names \
  --region "$REGION" \
  --query 'items[*].domainName' \
  --output text \
  --profile "$PROFILE")

# Delete each domain name
for domain_name in $DOMAIN_NAMES; do
  echo "Deleting custom domain name: $domain_name"
  aws apigateway delete-domain-name \
    --region "$REGION" \
    --domain-name "$domain_name" \
    --profile "$PROFILE"

  if [ $? -eq 0 ]; then
    echo "Successfully deleted: $domain_name. Sleeping for $SLEEP_TIME seconds..."
  else
    echo "Failed to delete: $domain_name" >&2
  fi

  sleep "$SLEEP_TIME"
done

echo "All specified custom domain names processed."
