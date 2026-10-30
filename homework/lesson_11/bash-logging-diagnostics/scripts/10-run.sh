#!/usr/bin/env bash
# run: обёртка над внешними командами — таймаут, логи, stdin.
set -Eeuo pipefail

: "${CMD_TIMEOUT:=5}"

# --- Внутренняя функция логирования (упрощённая) ---
log_debug() { printf '[DEBUG] %s\n' "$*" >&2; }
log_warn()  { printf '[WARN]  %s\n' "$*" >&2; }

run() {
  local desc="$1"; shift
  log_debug "RUN: $desc :: $*"

  local out rc
  # timeout --signal=TERM Ns cmd — если команда не завершится за N секунд,
  # ей отправится SIGTERM. `</dev/null` отвязывает stdin.
  # `2>&1` — stderr в stdout, чтобы весь вывод попал в отчёт.
  if out="$(timeout --signal=TERM "${CMD_TIMEOUT}s" "$@" 2>&1 </dev/null)"; then
    printf '%s\n' "$out"
    return 0
  else
    rc=$?
    log_warn "Команда '$desc' вернула код $rc"
    printf '%s\n' "$out"
    return $rc
  fi
}

echo "=== Быстрая команда ==="
run "uname" uname -a

echo
echo "=== Медленная команда (упадёт по таймауту) ==="
run "sleep" sleep 30 || echo "Как и ожидалось, команда прервана"

echo
echo "=== Несуществующая команда ==="
run "nonexistent" /no/such/binary || echo "Команда не найдена, продолжили"
