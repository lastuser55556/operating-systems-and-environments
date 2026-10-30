#!/usr/bin/env bash
read -r -p "Введите высоту: " height
[[ "$height" =~ ^[1-9][0-9]*$ ]] || { echo "Введите положительное целое"; exit 1; }
for ((i=1; i<=height; i++)); do printf '%*s' "$((height-i))" ''; printf '%*s\n' "$((2*i-1))" '' | tr ' ' '*'; done
