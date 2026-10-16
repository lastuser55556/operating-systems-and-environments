#!/usr/bin/env bash
# Логирование с уровнями и цветами.
set -Eeuo pipefail

# --- Уровни логирования как ассоциативный массив ---
declare -A LOG_LEVELS=(
  [DEBUG]=10
  [INFO]=20
  [WARN]=30
  [ERROR]=40
  [FATAL]=50
)

# --- Цвета (только если stdout — терминал) ---
if [[ -t 2 ]]; then
  C_RESET=$'\033[0m'
  C_DEBUG=$'\033[36m'   # голубой
  C_INFO=$'\033[32m'    # зелёный
  C_WARN=$'\033[33m'    # жёлтый
  C_ERROR=$'\033[31m'   # красный
  C_FATAL=$'\033[35m'   # пурпурный
else
  C_RESET=""; C_DEBUG=""; C_INFO=""; C_WARN=""; C_ERROR=""; C_FATAL=""
fi

# --- Текущий порог. Переопределяется через окружение. ---
: "${LOG_LEVEL:=INFO}"

# --- Внутренняя функция логирования ---
_log() {
  local level="$1"; shift
  local msg="$*"

  # Фильтр по уровню.
  if (( ${LOG_LEVELS[$level]:-20} < ${LOG_LEVELS[$LOG_LEVEL]:-20} )); then
    return 0
  fi

  local ts; ts="$(date '+%Y-%m-%dT%H:%M:%S%z')"
  local color_var="C_$level"
  local color="${!color_var:-}"

  # Логи идут в stderr, чтобы stdout оставался чистым.
  printf '%s[%s] [%-5s] %s%s\n' "$color" "$ts" "$level" "$msg" "$C_RESET" >&2
}

log_debug() { _log DEBUG "$@"; }
log_info()  { _log INFO  "$@"; }
log_warn()  { _log WARN  "$@"; }
log_error() { _log ERROR "$@"; }
log_fatal() { _log FATAL "$@"; }

# --- Демонстрация ---
log_debug "Это DEBUG — видно только при LOG_LEVEL=DEBUG"
log_info  "Это INFO"
log_warn  "Это WARN"
log_error "Это ERROR"
log_fatal "Это FATAL"

# Логи и данные разделены: это уйдёт в stdout, а не в лог.
echo "результат работы"
