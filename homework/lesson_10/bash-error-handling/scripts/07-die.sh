#!/usr/bin/env bash
set -u
die() {
  echo "ОШИБКА: $*" >&2
  exit 1
}
if (( $# < 1 )); then
  die 'имя файла не указано'
fi
[[ -r "$1" ]] || die "нет доступа к $1"
echo "Файл читается: $1"
