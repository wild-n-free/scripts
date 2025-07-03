#!/bin/bash

# Default profile
PROFILE=""

# Usage function
usage() {
  echo "Usage: $0 --profile <aws_profile>"
  exit 1
}

# Parse CLI arguments
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

# Get list of queue URLs and filter out unwanted ones
echo "Fetching SQS queues using profile '$PROFILE'..."
QUEUE_URLS=$(aws sqs list-queues --profile "$PROFILE" \
  | jq -r '.QueueUrls[]' \
  | grep -v "sys" \
  | grep -v "int" \
  | grep -v "hotfix" \
  | grep -v "dev-###-dev")

# Delete each queue
for QUEUE_URL in $QUEUE_URLS; do
  echo "Deleting SQS queue: $QUEUE_URL"
  aws sqs delete-queue --queue-url "$QUEUE_URL" --profile "$PROFILE"

  if [ $? -eq 0 ]; then
    echo "Successfully deleted: $QUEUE_URL"
  else
    echo "Failed to delete: $QUEUE_URL" >&2
  fi
done

echo "All applicable SQS queues processed."
