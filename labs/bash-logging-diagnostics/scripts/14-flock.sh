#!/usr/bin/env bash
# flock: не даём двум экземплярам работать одновременно.
set -Eeuo pipefail

: "${DEMO_LOCK_FILE:=/tmp/demo-flock.lock}"
LOCK_FILE="$DEMO_LOCK_FILE"

# Открываем FD 9 на файл блокировки.
exec 9>"$LOCK_FILE" || { echo "не могу открыть $LOCK_FILE" >&2; exit 1; }

# flock -n 9 — неблокирующая попытка взять блокировку.
# Если занято — падаем сразу, не ждём.
if ! flock -n 9; then
  echo "Другой экземпляр уже работает (lock: $LOCK_FILE)" >&2
  exit 1
fi

echo "Блокировка взята. Работаю 10 секунд..."
for i in $(seq 1 10); do
  echo "  тик $i"
  sleep 1
done
echo "Готово"
# Блокировка снимется автоматически при выходе процесса.
