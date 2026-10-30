#!/usr/bin/env bash
if read -r -t 5 -p "Введите значение за 5 секунд: " value; then echo "Введено: $value"; else echo; echo "Время вышло"; fi
