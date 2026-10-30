#!/usr/bin/env bash
if ! command -v bc >/dev/null; then echo "Установите bc: sudo apt install bc" >&2; exit 1; fi
echo "10 / 3 = $(echo "scale=2; 10/3" | bc)"
echo "2^10 = $((2**10))"
