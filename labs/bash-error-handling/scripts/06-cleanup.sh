#!/usr/bin/env bash
set -euo pipefail
TMP_DIR="$(mktemp -d)"
cleanup() {
  trap - EXIT INT TERM
  rm -rf -- "$TMP_DIR"
  echo "Убрано"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
printf 'Временный каталог: %s\n' "$TMP_DIR"
sleep "${SLEEP_SECONDS:-30}"
