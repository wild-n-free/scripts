#!/bin/bash

# Check for required arguments
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <tag-key> <tag-value> <aws-profile>"
  echo "Example: $0 velero.io/schedule-name sandbox-backup my-profile"
  exit 1
fi

TAG_KEY=$1
TAG_VALUE=$2
AWS_PROFILE=$3

aws ec2 describe-snapshots \
  --filters "Name=tag:$TAG_KEY,Values=$TAG_VALUE" \
  --query "Snapshots[*].{SnapshotId:SnapshotId,StartTime:StartTime}" \
  --output table \
  --profile "$AWS_PROFILE"
