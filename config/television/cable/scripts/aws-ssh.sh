#!/usr/bin/env bash
# Usage: aws-ssh.sh <instance-id>
# Connects to the EC2 instance using its local SSH key.

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

ssh -i "$HOME/camcloud/keys/$KEY_NAME.pem" ec2-user@"$HOST"
