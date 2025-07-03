#!/bin/bash

# Default value
PROFILE=""

# Usage function
usage() {
  echo "Usage: $0 --profile <aws_profile>"
  exit 1
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
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

# Validate required input
if [[ -z "$PROFILE" ]]; then
  usage
fi

# Fetch all bucket names
echo "Fetching S3 buckets for profile '$PROFILE'..."
BUCKETS=$(aws s3api list-buckets \
  --query 'Buckets[*].Name' \
  --output text \
  --profile "$PROFILE")

# Loop and attempt to delete each bucket
for BUCKET in $BUCKETS; do
  echo "Attempting to delete bucket: $BUCKET"
  aws s3api delete-bucket \
    --bucket "$BUCKET" \
    --profile "$PROFILE"

  if [ $? -eq 0 ]; then
    echo
