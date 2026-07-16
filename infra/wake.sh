#!/usr/bin/env bash
# ./wake.sh
set -euo pipefail

wake_arn=$(terraform output -raw wake_lambda_arn)
aws lambda invoke --function-name "$wake_arn" response.json
cat response.json
