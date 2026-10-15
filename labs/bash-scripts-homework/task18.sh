#!/usr/bin/env bash
read -r -p "Логин: " login
read -r -s -p "Пароль: " password
echo
echo "Пользователь $login авторизован"
unset password
