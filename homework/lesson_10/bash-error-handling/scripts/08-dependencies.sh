#!/usr/bin/env bash
missing=()
for dependency in git curl jq; do
  command -v "$dependency" >/dev/null 2>&1 || missing+=("$dependency")
done
if (( ${#missing[@]} > 0 )); then
  printf 'Отсутствуют зависимости: %s\n' "${missing[*]}" >&2
  exit 127
fi
echo "Все зависимости на месте"
