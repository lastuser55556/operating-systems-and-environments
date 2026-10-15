#!/usr/bin/env bash
read -r -p "Введите слова через пробел: " -a words
for i in "${!words[@]}"; do echo "$((i+1)). ${words[i]}"; done
