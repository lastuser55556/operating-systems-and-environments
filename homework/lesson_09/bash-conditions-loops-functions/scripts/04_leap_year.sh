#!/usr/bin/env bash
read -r -p "Введите год: " year
if (( (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 )); then echo "високосный"; else echo "не високосный"; fi
