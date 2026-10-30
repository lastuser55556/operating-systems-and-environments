#!/usr/bin/env bash
# Запуск: bash tasks.sh <номер> [аргументы]
set -u
task01(){ echo "Привет, ${USER:-$(id -un)}! Домашняя директория: $HOME. Дата: $(date '+%F %T')"; }
task02(){ printf '#!/usr/bin/env bash\necho OK\n' > check.sh; chmod +x check.sh; ./check.sh; echo 'Без ./ Bash ищет программу только в PATH; текущая папка обычно не входит в PATH.'; }
task03(){ printf '#!/usr/bin/env bash\necho "Bash: $BASH_VERSION"\n' > shebang.sh; chmod +x shebang.sh; ./shebang.sh; bash shebang.sh; sh shebang.sh; }
task04(){ echo "Права: $(ls -l "$0")"; chmod 700 "$0"; echo "После chmod 700: $(ls -l "$0")"; }
task05(){ local last=''; (($#)) && last="${!#}"; printf 'Скрипт: %s\nАргументов: %s\nВсе: %s\nПервый: %s\nПоследний: %s\n' "$0" "$#" "$*" "${1:-}" "$last"; }
task06(){ NAME=Иван CITY=Москвы AGE=30; echo "${NAME}, ${AGE} лет, из ${CITY}"; }
task07(){ true; echo "Скрипт: $0; PID: $$; код true: $?"; }
task08(){ read -r -p 'Два целых числа: ' a b; ((b)) || { echo 'Деление на ноль'; return 1; }; echo "сумма=$((a+b)) разность=$((a-b)) произведение=$((a*b)) частное=$((a/b)) остаток=$((a%b))"; }
task09(){ command -v bc >/dev/null || { echo 'Нужен пакет bc' >&2; return 1; }; echo "10/3=$(echo 'scale=2; 10/3' | bc); 2^10=$((2**10))"; }
task10(){ echo "Ядро: $(uname -s); свободно /: $(df -h / | awk 'NR==2{print $4}'); файлов /etc: $(find /etc -maxdepth 1 -type f | wc -l)"; }
task11(){ echo "Привет, ${1:-Гость}!"; }
task12(){ MYVAR=secret; echo "Без export: '$(bash -c 'echo "$MYVAR"')'"; export MYVAR; echo "С export: '$(bash -c 'echo "$MYVAR"')'"; }
task13(){ readonly FIXED=const; echo "$FIXED"; (FIXED=new) 2>&1 || true; regular=value; unset regular; echo "regular=${regular:-удалена}"; }
task14(){ echo "CONFIG=${CONFIG:?CONFIG не задана}"; }
task15(){ command -v git >/dev/null || { echo 'git не установлен' >&2; return 1; }; git --version; }
task16(){ read -r -p 'Строка: ' s; echo "Верх: ${s^^}; низ: ${s,,}; длина: ${#s}"; }
task17(){ ls /nonexistent >/dev/null 2>&1; bad=$?; ls / >/dev/null; good=$?; echo "ls /nonexistent: $bad (ошибка); ls /: $good (успех)"; }
task18(){ read -r -p 'Логин: ' login; read -r -s -p 'Пароль: ' password; echo; echo "Пользователь $login авторизован"; }
task19(){ if read -r -t 5 -p 'Введите значение за 5 секунд: ' value; then echo "$value"; else echo 'Время вышло'; fi; }
task20(){ read -r -a words -p 'Слова: '; for i in "${!words[@]}"; do echo "$((i+1)). ${words[i]}"; done; }
num=${1:?Укажите номер задания 1-20}; shift || true
fn=$(printf 'task%02d' "$num"); declare -F "$fn" >/dev/null || { echo 'Нет такого задания' >&2; exit 1; }; "$fn" "$@"
