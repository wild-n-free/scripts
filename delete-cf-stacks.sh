
#!/usr/bin/env bash
set -uo pipefail

# Configuration
PROFILE="DevCAS"
PREFIX="eksctl-cas-sys-addon-iamserviceaccount-"
REGION="${AWS_REGION:-eu-west-2}"
DRY_RUN="${DRY_RUN:-true}"

# Verify AWS CLI
command -v aws >/dev/null 2>&1 || {
    echo "ERROR: AWS CLI is not installed."
    exit 1
}

# Apply the profile to all AWS CLI commands
export AWS_PROFILE="$PROFILE"
export AWS_REGION="$REGION"

aws sts get-caller-identity >/dev/null || {
    echo "ERROR: Unable to authenticate using profile $PROFILE."
    exit 1
}

ACCOUNT=$(aws sts get-caller-identity \
    --query Account --output text)

echo "AWS Profile: $PROFILE"
echo "AWS Account: $ACCOUNT"
echo "Region:      $REGION"
echo "Prefix:      $PREFIX"
echo "Dry run:     $DRY_RUN"
echo

# Find matching stacks
STACKS_RAW=$(aws cloudformation list-stacks \
    --query "StackSummaries[?starts_with(StackName, \`$PREFIX\`) && StackStatus != 'DELETE_COMPLETE'].StackName" \
    --output text) || {
        echo "ERROR: Failed to list CloudFormation stacks."
        exit 1
    }

STACKS=()
while IFS= read -r STACK; do
    [[ -n "$STACK" && "$STACK" != "None" ]] && STACKS+=("$STACK")
done < <(printf '%s\n' "$STACKS_RAW" | tr '\t' '\n')

if [[ ${#STACKS[@]} -eq 0 ]]; then
    echo "No matching stacks found."
    exit 0
fi

echo "Matching stacks (${#STACKS[@]}):"
printf '  %s\n' "${STACKS[@]}"
echo

if [[ "$DRY_RUN" == "true" ]]; then
    echo "DRY RUN: No changes made."
    echo "Would disable termination protection and delete the stacks above."
    echo
    echo "To execute:"
    echo "  DRY_RUN=false AWS_REGION=$REGION $0"
    exit 0
fi

read -r -p "Type DELETE to disable protection and delete these stacks: " CONFIRM
if [[ "$CONFIRM" != "DELETE" ]]; then
    echo "Cancelled."
    exit 0
fi

FAILED=0

for STACK in "${STACKS[@]}"; do
    echo
    echo "Processing: $STACK"

    # Disable termination protection
    if ! aws cloudformation update-termination-protection \
        --stack-name "$STACK" \
        --no-enable-termination-protection; then
        echo "ERROR: Could not disable termination protection."
        echo "Skipping deletion of $STACK."
        FAILED=1
        continue
    fi

    echo "Termination protection disabled."

    # Submit deletion request
    if aws cloudformation delete-stack --stack-name "$STACK"; then
        echo "Deletion request submitted for $STACK."
    else
        echo "ERROR: Failed to submit deletion for $STACK."
        FAILED=1
    fi
done

echo
if [[ "$FAILED" -eq 0 ]]; then
    echo "All deletion requests submitted successfully."
    echo "Check CloudFormation for final deletion status."
else
    echo "Completed with errors. Review the messages above."
    exit 1
fi
