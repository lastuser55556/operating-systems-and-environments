#!/usr/bin/env bash
# Логи одновременно в stderr и в файл.
set -Eeuo pipefail

: "${LOG_LEVEL:=INFO}"
: "${LOG_DIR:=/tmp/diag-demo}"

declare -A LOG_LEVELS=([DEBUG]=10 [INFO]=20 [WARN]=30 [ERROR]=40 [FATAL]=50)
LOG_FILE=""

_log() {
  local level="$1"; shift
  local msg="$*"

  (( ${LOG_LEVELS[$level]:-20} < ${LOG_LEVELS[$LOG_LEVEL]:-20} )) && return 0

  local ts; ts="$(date '+%Y-%m-%dT%H:%M:%S%z')"
  local line="[$ts] [$level] $msg"

  printf '%s\n' "$line" >&2
  [[ -n "$LOG_FILE" ]] && printf '%s\n' "$line" >>"$LOG_FILE"
}

log_debug() { _log DEBUG "$@"; }
log_info()  { _log INFO  "$@"; }
log_warn()  { _log WARN  "$@"; }
log_error() { _log ERROR "$@"; }

# --- Инициализация лог-файла ---
mkdir -p -- "$LOG_DIR"
LOG_FILE="$LOG_DIR/demo-$(date +%Y%m%d-%H%M%S)-$$.log"
: >"$LOG_FILE"

log_info "Старт, лог пишется в $LOG_FILE"
log_debug "Отладочное сообщение"
log_warn  "Предупреждение"
log_info  "Завершение"

echo "Лог-файл: $LOG_FILE"
