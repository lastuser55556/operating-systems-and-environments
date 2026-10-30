#!/usr/bin/env bash
safe_divide() {
  local a=$1 b=$2
  if (( b == 0 )); then
    echo "Ошибка: деление на ноль" >&2
    return 1
  fi
  echo "$(( a / b ))"
  return 0
}
safe_divide 10 2
first_status=$?
echo "Код первого вызова: $first_status"
safe_divide 10 0
second_status=$?
echo "Код второго вызова: $second_status"
