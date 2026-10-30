#!/usr/bin/env bash
# ============================================================================
# Мини-версия диагностического скрипта, собранная из всех кусков.
# ============================================================================
set -Eeuo pipefail
shopt -s inherit_errexit nullglob
umask 077
IFS=$'\n\t'

readonly SCRIPT_NAME="${0##*/}"
readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_PID=$$

# --- Дефолты ---
: "${LOG_LEVEL:=INFO}"
: "${LOG_DIR:=/tmp/diag-final-logs}"
: "${OUT_DIR:=/tmp/diag-final-out}"
: "${CMD_TIMEOUT:=10}"
: "${DISK_WARN_PCT:=80}"
: "${DISK_CRIT_PCT:=90}"
: "${HTTP_TARGETS:=}"
: "${CONFIG_FILE:=/etc/diag.conf}"

# --- Логирование ---
declare -A LOG_LEVELS=([DEBUG]=10 [INFO]=20 [WARN]=30 [ERROR]=40 [FATAL]=50)
LOG_FILE=""

_log() {
  local level="$1"; shift
  local msg="$*"
  (( ${LOG_LEVELS[$level]:-20} < ${LOG_LEVELS[$LOG_LEVEL]:-20} )) && return 0
  local ts; ts="$(date '+%Y-%m-%dT%H:%M:%S%z')"
  local line="[$ts] [$level] (${FUNCNAME[2]:-main}) $msg"
  printf '%s\n' "$line" >&2
  [[ -n "$LOG_FILE" ]] && printf '%s\n' "$line" >>"$LOG_FILE"
}
log_debug() { _log DEBUG "$@"; }
log_info()  { _log INFO  "$@"; }
log_warn()  { _log WARN  "$@"; }
log_error() { _log ERROR "$@"; }
log_fatal() { _log FATAL "$@"; }
die() { log_fatal "$*"; exit 1; }

# --- Trap'ы ---
_cleanup() {
  local rc=$?
  log_debug "Завершение, rc=$rc"
  [[ -n "${LOCK_FILE:-}" && -f "$LOCK_FILE" ]] && rm -f -- "$LOCK_FILE" 2>/dev/null || true
  [[ -n "${TMP_DIR:-}" && -d "$TMP_DIR" ]] && rm -rf -- "$TMP_DIR" 2>/dev/null || true
  exit "$rc"
}
on_error() {
  log_error "Ошибка (rc=$1) в строке $2: $3"
}
on_signal() {
  log_warn "Сигнал $1 — завершаемся"
  exit 130
}
trap '_cleanup' EXIT
trap 'on_error $? $LINENO "$BASH_COMMAND"' ERR
trap 'on_signal INT'  INT
trap 'on_signal TERM' TERM

# --- Конфиг ---
load_config() {
  local file="$1"
  [[ -r "$file" ]] || die "Конфиг не читается: $file"
  local perms
  perms="$(stat -c '%a' "$file" 2>/dev/null || stat -f '%Lp' "$file")"
  [[ "${perms: -1}" =~ [2367] ]] && die "Конфиг $file доступен на запись группе/всем"
  local line key val
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"; val="${BASH_REMATCH[2]}"
      val="${val%\"}"; val="${val#\"}"; val="${val%\'}"; val="${val#\'}"
      printf -v "$key" '%s' "$val"
      export "$key"
    else
      log_warn "Пропущена строка конфига: $line"
    fi
  done <"$file"
}

# --- Args ---
usage() {
  cat <<EOF
$SCRIPT_NAME v$SCRIPT_VERSION

Использование: $SCRIPT_NAME [опции]
  -c, --config FILE   путь к конфигу (по умолчанию /etc/diag.conf)
  -l, --level LEVEL   уровень логов (по умолчанию INFO)
  -o, --out DIR       каталог отчётов
  -h, --help          справка
  -V, --version       версия
EOF
}
parse_args() {
  while (($#)); do
    case "$1" in
      -c|--config) CONFIG_FILE="${2:?требуется путь}"; shift 2 ;;
      -l|--level)  LOG_LEVEL="${2:?требуется уровень}"; shift 2 ;;
      -o|--out)    OUT_DIR="${2:?требуется каталог}"; shift 2 ;;
      -h|--help)   usage; exit 0 ;;
      -V|--version) echo "$SCRIPT_NAME $SCRIPT_VERSION"; exit 0 ;;
      --) shift; break ;;
      -*) die "Неизвестная опция: $1" ;;
      *)  die "Лишний аргумент: $1" ;;
    esac
  done
}

# --- Валидация ---
validate_config() {
  [[ "$LOG_LEVEL" =~ ^(DEBUG|INFO|WARN|ERROR)$ ]] \
    || die "LOG_LEVEL неверный: $LOG_LEVEL"
  [[ "$CMD_TIMEOUT" =~ ^[0-9]+$ ]] || die "CMD_TIMEOUT — целое"
  [[ "$DISK_WARN_PCT" =~ ^[0-9]+$ ]] || die "DISK_WARN_PCT — целое"
  [[ "$DISK_CRIT_PCT" =~ ^[0-9]+$ ]] || die "DISK_CRIT_PCT — целое"
  (( DISK_WARN_PCT < DISK_CRIT_PCT )) || die "WARN должен быть < CRIT"
}

# --- run ---
run() {
  local desc="$1"; shift
  log_debug "RUN: $desc :: $*"
  local out rc
  if out="$(timeout --signal=TERM "${CMD_TIMEOUT}s" "$@" 2>&1 </dev/null)"; then
    printf '%s\n' "$out"; return 0
  else
    rc=$?; log_warn "Команда '$desc' rc=$rc"; printf '%s\n' "$out"; return $rc
  fi
}

# --- Модули ---
check_system() {
  log_info "Системная информация"
  {
    printf '=== hostname ===\n';  run hostname hostname || true
    printf '=== uname ===\n';     run uname    uname -a  || true
    printf '=== uptime ===\n';    run uptime   uptime    || true
    printf '=== date ===\n';      run date     date -u   || true
  } >"$OUT_DIR/system.txt"
}

check_cpu_mem() {
  log_info "CPU и память"
  {
    printf '=== top ===\n'
    run top top -bn1 2>/dev/null | head -n 20 || true
    printf '\n=== free ===\n'
    run free free -h || true
  } >"$OUT_DIR/cpu_mem.txt"
}

check_disks() {
  log_info "Диски"
  {
    printf '=== df ===\n'
    run df df -hP || true
  } >"$OUT_DIR/disks.txt"
  while read -r fs size used avail pct mount; do
    [[ "$pct" =~ ^([0-9]+)%$ ]] || continue
    local p="${BASH_REMATCH[1]}"
    if   (( p >= DISK_CRIT_PCT )); then log_error "Критично: $mount = ${p}%"
    elif (( p >= DISK_WARN_PCT )); then log_warn  "Внимание: $mount = ${p}%"
    else log_debug "OK: $mount = ${p}%"
    fi
  done < <(df -hP | awk 'NR>1')
}

check_http() {
  [[ -z "$HTTP_TARGETS" ]] && { log_debug "HTTP_TARGETS пусто"; return 0; }
  log_info "HTTP-проверки"
  local t code
  local -a targets
  IFS=' ' read -r -a targets <<< "$HTTP_TARGETS"
  for t in "${targets[@]}"; do
    code="$(timeout "${CMD_TIMEOUT}s" curl -sS -o /dev/null -w '%{http_code}' "$t" 2>/dev/null || echo 000)"
    if [[ "$code" =~ ^2 ]]; then log_info "OK   $t ($code)"
    else log_error "FAIL $t ($code)"
    fi
  done
}

build_report() {
  local tar="${OUT_DIR}.tar.gz"
  log_info "Архив: $tar"
  tar -czf "$tar" -C "$(dirname "$OUT_DIR")" "$(basename "$OUT_DIR")" \
    || die "tar упал"
}

# --- Main ---
main() {
  parse_args "$@"

  [[ -f "$CONFIG_FILE" ]] && load_config "$CONFIG_FILE"

  mkdir -p -- "$LOG_DIR" 2>/dev/null || true
  LOG_FILE="$LOG_DIR/diag-$(date +%Y%m%d-%H%M%S)-$$.log"
  : >"$LOG_FILE" 2>/dev/null || LOG_FILE=""

  log_info "Старт $SCRIPT_NAME v$SCRIPT_VERSION PID=$SCRIPT_PID"

  validate_config

  LOCK_FILE="${DIAG_LOCK_FILE:-/var/lock/diag.lock}"
  if ! exec 9>"$LOCK_FILE"; then
    LOCK_FILE="/tmp/diag.lock"
    exec 9>"$LOCK_FILE" || die "Не могу создать lock"
  fi
  flock -n 9 || die "Другой экземпляр работает"

  mkdir -p -- "$OUT_DIR" || die "Не могу создать $OUT_DIR"
  TMP_DIR="$(mktemp -d -t diag.XXXXXX)"

  check_system  || log_error "check_system упал"
  check_cpu_mem || log_error "check_cpu_mem упал"
  check_disks   || log_error "check_disks упал"
  check_http    || log_error "check_http упал"

  build_report

  log_info "Завершено успешно"
  echo "Отчёт: ${OUT_DIR}.tar.gz"
  echo "Лог:   $LOG_FILE"
}

main "$@"
