#!/usr/bin/env bash
echo "Ядро: $(uname -s)"
echo "Свободное место в /: $(df -h --output=avail / | tail -n 1 | xargs)"
echo "Обычных файлов в /etc (включая вложенные каталоги): $(find /etc -type f 2>/dev/null | wc -l)"
