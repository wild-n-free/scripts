#!/bin/bash

# Default value
PROFILE=""

# Usage instructions
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

# Ensure profile is provided
if [[ -z "$PROFILE" ]]; then
  usage
fi

# Fetch all bucket names
echo "Fetching S3 buckets for profile '$PROFILE'..."
BUCKETS=$(aws s3api list-buckets \
  --query 'Buckets[*].Name' \
  --output text \
  --profile "$PROFILE")

# Loop through and empty each bucket
for BUCKET in $BUCKETS; do
  echo "Emptying bucket: $BUCKET"
  aws s3 rm "s3://$BUCKET/" --recursive --profile "$PROFILE"

  if [ $? -eq 0 ]; then
    echo "Successfully emptied: $BUCKET"
  else
    echo "Failed to empty: $BUCKET" >&2
  fi
done

echo "All S3 buckets processed for emptying."
