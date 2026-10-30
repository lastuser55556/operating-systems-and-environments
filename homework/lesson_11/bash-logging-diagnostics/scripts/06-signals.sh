#!/usr/bin/env bash
# Обработка SIGINT (Ctrl+C) и SIGTERM (kill).
set -Eeuo pipefail

# Функция очистки — вынесена отдельно, чтобы её могли вызвать оба trap'а.
cleanup() {
  echo "[cleanup] освобождаю ресурсы..."
  rm -f -- "$DEMO_LOCK_FILE" 2>/dev/null || true
}

# trap EXIT выполнится ВСЕГДА.
trap cleanup EXIT

# INT/TERM — перехватываем и завершаемся с правильным кодом.
# 130 = 128 + 2 (SIGINT), 143 = 128 + 15 (SIGTERM).
trap 'echo "[signal] INT"; exit 130' INT
trap 'echo "[signal] TERM"; exit 143' TERM

: "${DEMO_LOCK_FILE:=/tmp/demo-signal.lock}"
touch "$DEMO_LOCK_FILE"

echo "Работаю... (нажмите Ctrl+C или убейте снаружи: kill $$)"
# Долгий цикл — эмуляция полезной работы.
for i in $(seq 1 30); do
  sleep 1
  echo "  тик $i"
done
echo "Досчитал до конца"
