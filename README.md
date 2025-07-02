
# AWS Cleanup Scripts

This repository contains several Bash scripts to manage AWS resources across your accounts using AWS CLI profiles. Each script accepts AWS CLI profiles (and regions where applicable) as command-line arguments for flexibility.

---

## Prerequisites

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed and configured with named profiles.
- [`jq`](https://stedolan.github.io/jq/) installed for JSON parsing (required for SQS script).
- Bash shell to run the scripts.

---

## Scripts Overview

| Script Name              | Description                                      | Arguments                              |
|--------------------------|------------------------------------------------|--------------------------------------|
| `delete-rest-apis.sh`    | Deletes all API Gateway REST APIs in a region. | `--region <region> --profile <profile>` |
| `delete-domain-names.sh` | Deletes all API Gateway custom domain names.   | `--region <region> --profile <profile>` |
| `delete-s3-buckets.sh`   | Deletes all S3 buckets under a profile (buckets must be empty). | `--profile <profile>`                 |
| `delete-sqs-queues.sh`   | Deletes all SQS queues except those filtered out by patterns. | `--profile <profile>`                 |
| `empty-s3-buckets.sh`    | Empties (deletes all objects) in all S3 buckets under a profile. | `--profile <profile>`                 |
| `list_ebs_snapshots.sh`  | List Amazon EBS snapshots filtered by a specific tag key-value pair | `<aws-profile>` `<tag-key>` `<tag-value>` |

---

## Usage

Make any script executable before running:

```bash
chmod +x <script-name>.sh
```

Run the script with the required arguments:

### 1. Delete all REST APIs

```bash
./delete-rest-apis.sh --region eu-west-2 --profile Dev_sso
```

---

### 2. Delete all API Gateway custom domain names

```bash
./delete-domain-names.sh --region eu-west-2 --profile Dev_sso
```

---

### 3. Delete all S3 buckets (buckets must be empty)

```bash
./delete-s3-buckets.sh --profile Dev_sso
```

---

### 4. Delete SQS queues (excluding certain patterns)

```bash
./delete-sqs-queues.sh --profile Dev_sso
```

---

### 5. Empty all S3 buckets (delete all objects inside)

```bash
./empty-s3-buckets.sh --profile Dev_sso
```

---

### 6. List Amazon EBS snapshots filtered by a specific tag key-value pair

```bash
./list_snapshots.sh <tag-key> <tag-value> <aws-profile>
```

---
## Notes

- **Always use caution**: these scripts perform destructive operations on your AWS resources.
- The S3 bucket deletion script requires buckets to be empty; otherwise, deletion will fail.
- The SQS script requires [`jq`](https://stedolan.github.io/jq/) installed and filters out queues containing `"sys"`, `"int"`, `"hotfix"`, or `"dev-###-dev"` in their names.
- You can customize the filters and behavior in the scripts as needed.
- Adding confirmation prompts, dry-run mode, or logging are recommended for production use.

---

## Troubleshooting

- Make sure your AWS CLI credentials and permissions allow these actions for the specified profile.
- Check AWS CLI version (`aws --version`) and update if needed.
- For JSON parsing, ensure `jq` is installed and available in your PATH.

---

## License

This script is provided as-is, without warranty. Use at your own risk.
