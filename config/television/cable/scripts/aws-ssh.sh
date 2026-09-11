#!/usr/bin/env bash
# Usage: aws-ssh.sh <instance-id>
# Fetches the SSH key from 1Password and connects to the EC2 instance.

set -euo pipefail

INSTANCE_ID="$1"
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"

read -r KEY_NAME HOST _ < <(
  AWS_REGION="$REGION" aws ec2 describe-instances \
    --output text \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[*].Instances[0].[KeyName,PublicDnsName,PublicIpAddress]"
)

KEY_NAME="${KEY_NAME%.pem}"

TMPKEY=$(mktemp)
trap 'rm -f "$TMPKEY"' EXIT

op read "op://Camcloud/${KEY_NAME}/private key?ssh-format=openssh" > "$TMPKEY"
chmod 600 "$TMPKEY"

ssh -i "$TMPKEY" ec2-user@"$HOST"
