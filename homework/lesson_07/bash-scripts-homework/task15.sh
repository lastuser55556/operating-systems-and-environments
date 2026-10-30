#!/usr/bin/env bash
if ! command -v git >/dev/null 2>&1; then echo "Ошибка: git не установлен" >&2; exit 1; fi
git --version
