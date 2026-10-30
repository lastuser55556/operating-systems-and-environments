#!/usr/bin/env bash
# Fail-fast валидация: падаем до начала работы, если конфиг плохой.
set -Eeuo pipefail

: "${LOG_LEVEL:=INFO}"
: "${CMD_TIMEOUT:=10}"
: "${DISK_WARN_PCT:=80}"
: "${DISK_CRIT_PCT:=90}"

die() { echo "ОШИБКА: $*" >&2; exit 1; }

validate_config() {
  [[ "$LOG_LEVEL" =~ ^(DEBUG|INFO|WARN|ERROR)$ ]] \
    || die "LOG_LEVEL должен быть DEBUG|INFO|WARN|ERROR, получено: '$LOG_LEVEL'"

  [[ "$CMD_TIMEOUT" =~ ^[0-9]+$ ]] \
    || die "CMD_TIMEOUT должен быть целым числом, получено: '$CMD_TIMEOUT'"

  (( CMD_TIMEOUT > 0 && CMD_TIMEOUT <= 300 )) \
    || die "CMD_TIMEOUT должен быть в диапазоне 1..300"

  [[ "$DISK_WARN_PCT" =~ ^[0-9]+$ ]] || die "DISK_WARN_PCT должен быть числом"
  [[ "$DISK_CRIT_PCT" =~ ^[0-9]+$ ]] || die "DISK_CRIT_PCT должен быть числом"

  (( DISK_WARN_PCT < DISK_CRIT_PCT )) \
    || die "DISK_WARN_PCT ($DISK_WARN_PCT) должен быть < DISK_CRIT_PCT ($DISK_CRIT_PCT)"

  echo "Валидация пройдена: LOG_LEVEL=$LOG_LEVEL, CMD_TIMEOUT=$CMD_TIMEOUT, пороги: $DISK_WARN_PCT/$DISK_CRIT_PCT"
}

validate_config
