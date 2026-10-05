# Работа с пользователями, группами и правами доступа

## Цель работы

Создать пользователей и группу в Ubuntu, настроить права доступа к файлам и проверить доступ от имени другого пользователя.

## Выполненные действия

Созданы пользователи:

```bash
sudo adduser user1
sudo adduser user2
sudo adduser user3
```

Создана группа `students`, в которую добавлены пользователи `user1` и `user2`:

```bash
sudo groupadd students
sudo usermod -aG students user1
sudo usermod -aG students user2
```

Создана папка `/home/lab` и два файла:

```bash
sudo mkdir /home/lab
sudo touch /home/lab/private.txt
sudo touch /home/lab/public.txt
```

Для файлов назначен владелец `user1`:

```bash
sudo chown user1:user1 /home/lab/private.txt
sudo chown user1:user1 /home/lab/public.txt
```

Настроены права доступа:

```bash
sudo chmod 600 /home/lab/private.txt
sudo chmod 777 /home/lab/public.txt
```

Файл `private.txt` доступен только владельцу. Файл `public.txt` доступен всем пользователям.

## Проверка

Проверка пользователей:

```bash
getent passwd user1 user2 user3
```

Проверка группы:

```bash
getent group students
```

Проверка прав доступа:

```bash
ls -l /home/lab
```

Проверка доступа от пользователя `user2`:

```bash
su - user2
cat /home/lab/public.txt
cat /home/lab/private.txt
exit
```

Пользователь `user2` смог открыть файл `public.txt`, но не смог открыть файл `private.txt`. Для файла `private.txt` была получена ошибка `Permission denied`.

## Скриншоты

- [Созданные пользователи](screenshots/01-users.png)
- [Созданная группа](screenshots/02-group.png)
- [Права доступа к файлам](screenshots/03-permissions.png)
- [Проверка доступа](screenshots/04-access-check.png)
