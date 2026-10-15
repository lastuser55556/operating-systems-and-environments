#!/usr/bin/env bash
read -r -p "Введите строку: " line
echo "Верхний регистр: ${line^^}"
echo "Нижний регистр: ${line,,}"
echo "Длина: ${#line}"
