#!/usr/bin/env bash
ls /nonexistent
first=$?
echo "Код для /nonexistent: $first"
ls / >/dev/null
second=$?
echo "Код для /: $second"
