#!/usr/bin/env bash
# Анализ заполнения диска с порогами WARN/CRIT.
set -Eeuo pipefail

: "${DISK_WARN_PCT:=80}"
: "${DISK_CRIT_PCT:=90}"

log_info()  { printf '[INFO]  %s\n' "$*"; }
log_warn()  { printf '[WARN]  %s\n' "$*" >&2; }
log_error() { printf '[ERROR] %s\n' "$*" >&2; }

# df -hP — POSIX-формат, одна строка на ФС.
# awk 'NR>1' — пропускаем заголовок.
# < <(...) — process substitution: while не в subshell, переменные живы.
while read -r fs size used avail pct mount; do
  # Извлекаем число из "85%".
  [[ "$pct" =~ ^([0-9]+)%$ ]] || continue
  p="${BASH_REMATCH[1]}"

  if   (( p >= DISK_CRIT_PCT )); then
    log_error "$mount: ${p}% (критично, порог ${DISK_CRIT_PCT}%)"
  elif (( p >= DISK_WARN_PCT )); then
    log_warn  "$mount: ${p}% (внимание, порог ${DISK_WARN_PCT}%)"
  else
    log_info  "$mount: ${p}% (OK)"
  fi
done < <(df -hP | awk 'NR>1')
