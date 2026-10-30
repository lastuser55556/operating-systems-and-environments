#!/usr/bin/env bash
# Замена паролей/токенов на *** перед логированием.
set -Eeuo pipefail

# Функция-фильтр: читает stdin, пишет в stdout с маскированием.
mask_secrets() {
  # sed -E — расширенные regex.
  # \1=*** — оставляем имя параметра, значение затираем.
  sed -E \
    -e 's/(password|passwd|pwd|token|secret|api[_-]?key)=([^[:space:]]+)/\1=***/gi' \
    -e 's/(Authorization:[[:space:]]*Bearer[[:space:]]+)[^[:space:]]+/\1***/gi'
}

echo "=== Демонстрация ==="
cat <<'EOF' | mask_secrets
user=alice password=s3cr3t host=example.com
token=abcdef1234567890
api_key=xyz-9876-5432
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
нормальная строка без секретов
EOF
