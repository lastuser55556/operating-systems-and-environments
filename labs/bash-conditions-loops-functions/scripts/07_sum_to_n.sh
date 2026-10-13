#!/usr/bin/env bash
read -r -p "Введите N: " n
[[ "$n" =~ ^[0-9]+$ ]] || { echo "Введите неотрицательное целое"; exit 1; }
sum=0; for ((i=1; i<=n; i++)); do ((sum += i)); done; echo "Сумма: $sum"
