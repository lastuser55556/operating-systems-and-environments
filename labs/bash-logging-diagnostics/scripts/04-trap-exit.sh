#!/usr/bin/env bash
# trap EXIT: код выполняется при любом завершении скрипта.
set -Eeuo pipefail

# Создаём временный каталог.
TMP_DIR="$(mktemp -d -t demo.XXXXXX)"
echo "Создан временный каталог: $TMP_DIR"

# Регистрируем очистку. Она сработает:
#  * при нормальном выходе,
#  * при exit 1,
#  * при падении из-за set -e,
#  * при Ctrl+C,
#  * при kill.
trap 'echo "[cleanup] удаляю $TMP_DIR"; rm -rf -- "$TMP_DIR"' EXIT

# Что-то делаем во временном каталоге.
touch "$TMP_DIR/file1" "$TMP_DIR/file2"
ls -la "$TMP_DIR"

# Дальше — либо нормальный выход, либо ошибка.
# Попробуйте раскомментировать:
# exit 1
# false

echo "Работа завершена"
