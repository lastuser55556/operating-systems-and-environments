#!/usr/bin/env bash
factorial() { (( $1 <= 1 )) && { echo 1; return; }; local prev; prev=$(factorial "$(( $1 - 1 ))"); echo "$(( $1 * prev ))"; }
read -r -p "Введите неотрицательное число: " n
[[ "$n" =~ ^[0-9]+$ ]] || { echo "Введите неотрицательное целое"; exit 1; }
factorial "$n"
