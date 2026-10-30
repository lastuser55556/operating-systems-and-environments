#!/usr/bin/env bash
for ((i=1; i<=100; i++)); do (( i % 3 == 0 || i % 5 == 0 )) && printf '%s ' "$i"; done
printf '\n'
