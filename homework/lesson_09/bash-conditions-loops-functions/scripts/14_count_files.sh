#!/usr/bin/env bash
count_files() { find "$1" -maxdepth 1 -type f -print | wc -l | tr -d ' '; }
read -r -p "Введите путь к директории: " dir
[[ -d "$dir" ]] || { echo "Директория не найдена"; exit 1; }
echo "Файлов: $(count_files "$dir")"
