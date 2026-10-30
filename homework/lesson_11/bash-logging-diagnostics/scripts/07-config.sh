#!/usr/bin/env bash
# Безопасный парсер конфига: KEY=VALUE, без source.
set -Eeuo pipefail

load_config() {
  local file="$1"
  [[ -r "$file" ]] || { echo "не читается: $file" >&2; return 1; }

  # Проверка прав: последняя цифра не должна быть 2/3/6/7
  # (иначе файл пишется группой или всеми — потенциальная инъекция).
  local perms
  perms="$(stat -c '%a' "$file" 2>/dev/null || stat -f '%Lp' "$file")"
  if [[ "${perms: -1}" =~ [2367] ]]; then
    echo "ОПАСНО: $file пишется группой/всеми ($perms)" >&2
    return 1
  fi

  local line key val
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Комментарии и пустые строки — пропускаем.
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    # Принимаем только KEY=VALUE.
    if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      val="${BASH_REMATCH[2]}"
      # Снимаем кавычки.
      val="${val%\"}"; val="${val#\"}"
      # printf -v — безопасное присвоение по имени.
      printf -v "$key" '%s' "$val"
      export "$key"
      echo "  $key=$val"
    else
      echo "  ПРОПУЩЕНО: $line" >&2
    fi
  done <"$file"
}

# --- Создаём тестовый конфиг ---
CFG="$(mktemp)"
cat >"$CFG" <<'EOF'
# Это комментарий
LOG_LEVEL=DEBUG
LOG_DIR="/tmp/my-logs"
CMD_TIMEOUT=15

# Опасная строка — должна быть пропущена
rm -rf / # это НЕ выполнится
EOF
chmod 600 "$CFG"

# --- Загружаем ---
echo "Загружаю $CFG:"
load_config "$CFG" || exit 1

echo
echo "LOG_LEVEL=$LOG_LEVEL"
echo "LOG_DIR=$LOG_DIR"
echo "CMD_TIMEOUT=$CMD_TIMEOUT"

rm -f "$CFG"
