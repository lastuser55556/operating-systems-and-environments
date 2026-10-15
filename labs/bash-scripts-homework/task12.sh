#!/usr/bin/env bash
MYVAR="secret"
echo "Без export: [$(bash -c 'echo "$MYVAR"')]"
export MYVAR
echo "С export: [$(bash -c 'echo "$MYVAR"')]"
