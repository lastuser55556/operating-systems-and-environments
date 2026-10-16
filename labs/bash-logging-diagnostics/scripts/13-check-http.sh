#!/usr/bin/env bash
# Проверка доступности HTTP-сервисов.
set -Eeuo pipefail

: "${HTTP_TARGETS:=https://example.com https://httpbin.org/status/500}"
: "${CMD_TIMEOUT:=5}"

log_info()  { printf '[INFO]  %s\n' "$*"; }
log_error() { printf '[ERROR] %s\n' "$*" >&2; }

# Разбиваем строку на отдельные URL по пробелам (сознательно без кавычек,
# потому что мы сами контролируем содержимое HTTP_TARGETS).
for t in $HTTP_TARGETS; do
  # curl -sS -o /dev/null -w '%{http_code}' — печатает только код ответа.
  # 2>/dev/null — подавляем сообщения curl.
  # || echo 000 — если curl вообще не смог подключиться.
  code="$(timeout "${CMD_TIMEOUT}s" curl -sS -o /dev/null -w '%{http_code}' "$t" 2>/dev/null || echo 000)"

  if [[ "$code" =~ ^2 ]]; then
    log_info  "OK   $t (HTTP $code)"
  else
    log_error "FAIL $t (HTTP $code)"
  fi
done
