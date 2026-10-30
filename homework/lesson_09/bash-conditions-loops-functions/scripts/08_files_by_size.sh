#!/usr/bin/env bash
find . -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file; do
  printf '%s\t%s\n' "$(wc -c < "$file")" "${file#./}"
done | sort -n | awk -F '\t' '{printf "%10d байт  %s\\n", $1, $2}'
