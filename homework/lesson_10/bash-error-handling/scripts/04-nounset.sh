#!/usr/bin/env bash
set -euo pipefail
trap 'echo "Переменная не задана" >&2' ERR
# Ошибка раскрытия $UNDEFINED_VAR возникает до запуска команды, поэтому
# Bash не вызывает ERR. EXIT ловит завершение с ненулевым статусом.
trap 'status=$?; if (( status != 0 )); then echo "Переменная не задана" >&2; fi' EXIT
unset UNDEFINED_VAR
echo "$UNDEFINED_VAR"
