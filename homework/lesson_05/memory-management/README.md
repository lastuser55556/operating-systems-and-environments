# Управление памятью в Linux

## `/proc/iomem`

Просмотр карты адресного пространства памяти:

![Вывод /proc/iomem](screenshots/01-iomem.png)

## `/proc/meminfo`

Просмотр сведений об использовании памяти:

![Вывод /proc/meminfo](screenshots/02-meminfo.png)

## Процесс `bash`

```bash
pgrep bash
3249
```

Карта памяти процесса:

![Карта памяти процесса bash](screenshots/03-bash-maps.png)

Попытка чтения памяти процесса:

```bash
cat /proc/3249/mem
cat: /proc/3249/mem: Input/output error
```

## Процесс `gnome-terminal-server`

Получен PID процесса:

![PID процесса gnome-terminal-server](screenshots/04-gnome-terminal-pid.png)

Карта памяти процесса `/proc/3242/maps`:

![Карта памяти процесса gnome-terminal-server](screenshots/05-gnome-terminal-maps.png)

Попытка чтения памяти процесса:

```bash
cat /proc/3242/mem
cat: /proc/3242/mem: Input/output error
```

![Ошибка чтения /proc/3242/mem](screenshots/06-gnome-terminal-mem-error.png)
