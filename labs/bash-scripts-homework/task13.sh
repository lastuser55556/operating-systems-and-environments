#!/usr/bin/env bash
readonly FIXED="первое"
FIXED="второе"  # Bash выдаст ошибку: readonly variable
TEMP="временное"
unset TEMP
echo "После unset: ${TEMP:-переменная удалена}"
