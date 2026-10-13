#!/usr/bin/env bash
read -r -p "Введите число от 1 до 10: " n
[[ "$n" =~ ^([1-9]|10)$ ]] || { echo "Нужно число от 1 до 10"; exit 1; }
for ((i=1; i<=10; i++)); do echo "$n × $i = $((n * i))"; done
