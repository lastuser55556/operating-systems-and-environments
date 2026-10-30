#!/usr/bin/env bash
# Парсинг CLI с короткими и длинными опциями.
set -Eeuo pipefail

: "${LOG_LEVEL:=INFO}"
: "${OUT_DIR:=/tmp/diag-out}"

usage() {
  cat <<EOF
Использование: $0 [опции]

  -l, --level LEVEL   уровень логирования (DEBUG|INFO|WARN|ERROR)
  -o, --out DIR       каталог вывода
  -h, --help          справка
  -V, --version       версия
EOF
}

parse_args() {
  while (($#)); do
    case "$1" in
      -l|--level)
        LOG_LEVEL="${2:?--level требует значение}"
        shift 2
        ;;
      -o|--out)
        OUT_DIR="${2:?--out требует значение}"
        shift 2
        ;;
      -h|--help)
        usage; exit 0
        ;;
      -V|--version)
        echo "demo 1.0.0"; exit 0
        ;;
      --)
        shift; break
        ;;
      -*)
        echo "Неизвестная опция: $1" >&2
        usage >&2
        exit 2
        ;;
      *)
        echo "Лишний аргумент: $1" >&2
        exit 2
        ;;
    esac
  done
}

parse_args "$@"

echo "LOG_LEVEL=$LOG_LEVEL"
echo "OUT_DIR=$OUT_DIR"
