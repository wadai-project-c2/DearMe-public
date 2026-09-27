#!/usr/bin/env bash

# Existing-resource, code-only deployment. Run only with operator approval.
set -euo pipefail

project_dir="$(cd "$(dirname "$0")/../.." && pwd)"
aws_cli="${DEARME_AWS_CLI:-aws}"
region="ap-northeast-1"
function_name="arn:aws:lambda:ap-northeast-1:000000000000:function:dearme-api-dev"
zip_path="${project_dir}/build/lambda/dearme-api-dev.zip"

if [[ "${1:-}" != "--confirm-code-update" ]]; then
  echo "承認後に --confirm-code-update を指定してください（既存Lambdaのコードのみ更新）。" >&2
  exit 1
fi
if [[ ! -f "${zip_path}" ]]; then
  echo "先に infra/aws/package_lambda.sh を実行してください。" >&2
  exit 1
fi

# Missing resources, denied reads, or unexpected auth modes fail closed.
# Never create resources or alter IAM/OAC/WAF/secrets/environment/concurrency.
auth_type="$("${aws_cli}" lambda get-function-url-config \
  --region "${region}" --function-name "${function_name}" \
  --query AuthType --output text)"
if [[ "${auth_type}" != "AWS_IAM" ]]; then
  echo "Function URL must already use AWS_IAM. No changes made." >&2
  exit 1
fi
revision_id="$("${aws_cli}" lambda get-function-configuration \
  --region "${region}" --function-name "${function_name}" \
  --query RevisionId --output text)"
if [[ -z "${revision_id}" || "${revision_id}" == "None" ]]; then
  echo "Existing Lambda revision could not be read. No changes made." >&2
  exit 1
fi
"${aws_cli}" lambda update-function-code \
  --region "${region}" --function-name "${function_name}" \
  --revision-id "${revision_id}" --zip-file "fileb://${zip_path}" >/dev/null
"${aws_cli}" lambda wait function-updated-v2 \
  --region "${region}" --function-name "${function_name}"

echo "Existing Lambda code updated. CloudFront/OAC/WAF/IAM settings preserved."
