#!/usr/bin/env bash
set -e
# Условие if — контекст проверки статуса: errexit здесь не применяется.
if false; then
  echo "Эта строка не выполняется"
fi
false
echo "Эта строка после false не должна появиться"
