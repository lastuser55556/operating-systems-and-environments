#!/usr/bin/env bash
ls / >/dev/null
status=$?
echo "Имя скрипта: $0"
echo "PID: $$"
echo "Код возврата ls: $status"
