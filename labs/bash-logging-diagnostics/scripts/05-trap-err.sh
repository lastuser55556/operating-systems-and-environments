#!/usr/bin/env bash
# trap ERR: получаем код, строку и команду, которая упала.
set -Eeuo pipefail

# -E нужен, чтобы trap ERR срабатывал внутри функций,
# а не только на верхнем уровне.
trap 'echo "[ERR] rc=$? line=$LINENO cmd=$BASH_COMMAND" >&2' ERR

# Хорошая функция.
do_ok() {
  echo "всё хорошо"
}

# Плохая функция — упадёт.
do_fail() {
  false
  echo "сюда не дойдём"
}

do_ok
# do_fail   # раскомментируйте, чтобы увидеть trap в действии
echo "Продолжаем работу"
