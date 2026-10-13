#!/usr/bin/env bash
read -r -p "Введите оценку (1-5): " grade
case "$grade" in
  5) echo "отлично" ;; 4) echo "хорошо" ;; 3) echo "удовлетворительно" ;;
  1|2) echo "плохо" ;; *) echo "неверная оценка" ;;
esac
