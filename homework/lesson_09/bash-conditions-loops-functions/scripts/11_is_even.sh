#!/usr/bin/env bash
is_even() { (( $1 % 2 == 0 )); }
for ((i=1; i<=20; i++)); do is_even "$i" && printf '%s ' "$i"; done
printf '\n'
