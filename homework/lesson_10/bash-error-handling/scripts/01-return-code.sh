#!/usr/bin/env bash
# Сохраняем код test сразу: следующая команда перезапишет $?.
test -e /etc/passwd
status=$?
if (( status == 0 )); then
  test -e /etc/passwd && echo "Файл есть"
else
  test -e /etc/passwd || echo "Файла нет"
fi
printf 'Код возврата test: %s\n' "$status"
