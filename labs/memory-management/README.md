# Управление памятью в Linux

## `/proc/iomem`

Просмотр карты адресного пространства памяти:

```bash
cat /proc/iomem
```

## `/proc/meminfo`

Просмотр сведений об использовании памяти:

```bash
cat /proc/meminfo
```

## Процесс `bash`

```bash
pgrep bash
3249
```

Карта памяти процесса:

```bash
cat /proc/3249/maps
```

Попытка чтения памяти процесса:

```bash
cat /proc/3249/mem
cat: /proc/3249/mem: Input/output error
```

## Процесс `gnome-terminal-server`

Карта памяти процесса `/proc/3242/maps`:

![Карта памяти процесса gnome-terminal-server](screenshots/01-gnome-terminal-maps.png)

Попытка чтения памяти процесса:

```bash
cat /proc/3242/mem
cat: /proc/3242/mem: Input/output error
```
