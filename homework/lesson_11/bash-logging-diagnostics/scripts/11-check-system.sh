#!/usr/bin/env bash
# Сбор базовой информации о системе в файл отчёта.
set -Eeuo pipefail

: "${OUT_DIR:=/tmp/diag-out}"
mkdir -p -- "$OUT_DIR"

run() {
  timeout 5s "$@" 2>&1 </dev/null || true
}

{
  echo "=== hostname ==="
  run hostname

  echo
  echo "=== uname ==="
  run uname -a

  echo
  echo "=== uptime ==="
  run uptime

  echo
  echo "=== who ==="
  run who

  echo
  echo "=== date (UTC) ==="
  run date -u

  echo
  echo "=== /etc/os-release ==="
  if [[ -r /etc/os-release ]]; then
    cat /etc/os-release
  else
    echo "(нет файла)"
  fi
} >"$OUT_DIR/system.txt"

echo "Отчёт: $OUT_DIR/system.txt"
cat "$OUT_DIR/system.txt"
