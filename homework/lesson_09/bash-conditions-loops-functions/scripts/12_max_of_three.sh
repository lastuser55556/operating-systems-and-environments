#!/usr/bin/env bash
max_of_three() { local max=$1; (( $2 > max )) && max=$2; (( $3 > max )) && max=$3; echo "$max"; }
read -r -p "Введите три числа через пробел: " a b c
max_of_three "$a" "$b" "$c"
