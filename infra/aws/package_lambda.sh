#!/usr/bin/env bash

set -euo pipefail

project_dir="$(cd "$(dirname "$0")/../.." && pwd)"
backend_dir="${project_dir}/backend"
artifact_dir="${project_dir}/build/lambda"
package_dir="${artifact_dir}/package"
zip_path="${artifact_dir}/dearme-api-dev.zip"

command -v uv >/dev/null 2>&1 || {
  echo "uv が見つかりません。" >&2
  exit 1
}

mkdir -p "${artifact_dir}"
find "${package_dir}" -mindepth 1 -delete 2>/dev/null || true
mkdir -p "${package_dir}"

uv pip install \
  --target "${package_dir}" \
  --requirements "${backend_dir}/requirements-lambda.txt" \
  --python-version 3.12 \
  --python-platform aarch64-manylinux2014 \
  --only-binary=:all: \
  --no-compile

cp "${backend_dir}/main.py" "${backend_dir}/lambda_handler.py" "${package_dir}/"
cp -R \
  "${backend_dir}/core" \
  "${backend_dir}/routers" \
  "${backend_dir}/schemas" \
  "${backend_dir}/services" \
  "${package_dir}/"

find "${package_dir}" -type d -name __pycache__ -prune -exec rm -rf {} +
find "${package_dir}" -type d -name tests -prune -exec rm -rf {} +
find "${package_dir}" -type f -name .lock -delete

rm -f "${zip_path}"
(
  cd "${package_dir}"
  zip -q -r "${zip_path}" .
)

zip_bytes="$(stat -f %z "${zip_path}")"
unzipped_bytes="$(du -sk "${package_dir}" | awk '{print $1 * 1024}')"
if (( zip_bytes > 50 * 1024 * 1024 )); then
  echo "ZIPがLambdaの直接アップロード上限50MBを超えています。" >&2
  exit 1
fi
if (( unzipped_bytes > 250 * 1024 * 1024 )); then
  echo "展開後サイズがLambda上限250MBを超えています。" >&2
  exit 1
fi

echo "Lambda package: ${zip_path}"
echo "ZIP bytes: ${zip_bytes}"
echo "Unzipped bytes: ${unzipped_bytes}"
