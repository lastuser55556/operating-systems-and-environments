#!/usr/bin/env bash
set -u
greet() {
  if (( $# == 0 )); then
    echo "Привет, ${1:-Гость}!"
  else
    echo "Привет, ${1:-Незнакомец}!"
  fi
}
required_greet() {
  local name=${1:?Имя обязательно}
  echo "Привет, $name!"
}
greet
greet ""
greet "Анна"
# Отдельный вызов: bash scripts/05-defaults.sh --required [имя]
if [[ "${1:-}" == '--required' ]]; then
  required_greet "${2:-}"
fi
