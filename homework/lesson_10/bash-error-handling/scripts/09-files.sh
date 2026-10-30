#!/usr/bin/env bash
errors=0
for file in "$@"; do
  if [[ -e "$file" ]]; then
    echo "OK: $file"
  else
    echo "MISSING: $file" >&2
    ((errors+=1))
  fi
done
(( errors == 0 )) || exit 1
exit 0
