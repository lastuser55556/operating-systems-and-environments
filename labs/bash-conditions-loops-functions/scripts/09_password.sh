#!/usr/bin/env bash
for ((attempt=1; attempt<=3; attempt++)); do
  read -r -s -p "Пароль (попытка $attempt из 3): " password; echo
  [[ "$password" == "secret" ]] && { echo "Доступ разрешён"; exit 0; }
done
echo "Попытки исчерпаны"; exit 1
