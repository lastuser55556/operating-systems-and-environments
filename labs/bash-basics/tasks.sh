#!/bin/bash

echo "TASK 1"
echo "Hello, $USER"
echo "Home: $HOME"
echo "Date: $(date)"

echo "TASK 2"
echo "OK"

echo "TASK 3"
echo "Hello from bash"

echo "TASK 4"
ls -l "$0"

echo "TASK 5"
echo "script: $0"
echo "count: $#"
echo "all: $@"
echo "first: $1"
echo "last: ${!#}"

echo "TASK 6"
NAME="Иван"
CITY="Москва"
AGE=30
echo "${NAME}, ${AGE} лет, из ${CITY}"

echo "TASK 7"
echo "script: $0"
echo "PID: $$"
echo "last code: $?"

echo "TASK 8"
read -p "a: " a
read -p "b: " b
echo "sum: $((a+b))"
echo "difference: $((a-b))"
echo "multiply: $((a*b))"
echo "divide: $((a/b))"
echo "remainder: $((a%b))"

echo "TASK 9"
echo "10 / 3" | bc -l
echo $((2**10))

echo "TASK 10"
echo "kernel: $(uname -s)"
echo "free: $(df -h / | awk 'NR==2 {print $4}')"
echo "files: $(find /etc -maxdepth 1 -type f | wc -l)"

echo "TASK 11"
NAME="${1:-Гость}"
echo "Hello, $NAME"

echo "TASK 12"
MYVAR="secret"
bash -c 'echo $MYVAR'
export MYVAR
bash -c 'echo $MYVAR'

echo "TASK 13"
readonly TEST="hello"
TEST="world"
VAR="text"
unset VAR
echo "$VAR"

echo "TASK 14"
echo "${CONFIG:?CONFIG is not set}"

echo "TASK 15"
if command -v git
then
    git --version
else
    echo "git not installed" >&2
    exit 1
fi

echo "TASK 16"
read -p "text: " text
echo "${text^^}"
echo "${text,,}"
echo "${#text}"

echo "TASK 17"
ls /nonexistent
code=$?
echo "$code"

ls /
code=$?
echo "$code"

echo "TASK 18"
read -p "login: " login
read -s -p "password: " password
echo
echo "Пользователь $login авторизован"

echo "TASK 19"
if read -t 5 -p "value: " value
then
    echo "$value"
else
    echo "Время вышло"
fi

echo "TASK 20"
read -a words
for i in "${!words[@]}"
do
    echo "$((i+1)) ${words[$i]}"
done
