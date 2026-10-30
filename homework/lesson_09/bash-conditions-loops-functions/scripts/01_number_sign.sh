#!/usr/bin/env bash
read -r -p "Введите число: " n
if (( n > 0 )); then echo "положительное"; elif (( n < 0 )); then echo "отрицательное"; else echo "ноль"; fi
