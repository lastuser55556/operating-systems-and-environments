# Операции с файлами и каталогами

## Цель работы

Повторить основные команды Linux для работы с файлами и каталогами.

## Выполненные команды

Создание рабочей папки:

```bash
cd ~
mkdir file-work-lab
cd file-work-lab
pwd
```

Создание каталогов и файлов:

```bash
mkdir dir1 dir2 dir3
mkdir -p parent/child/grandchild
touch file1.txt file2.txt file3.txt
ls
ls -l
```

Создание текстовых файлов:

```bash
cat > docs.txt
cat > table.txt
```

Просмотр файлов:

```bash
cat docs.txt
cat table.txt
more docs.txt
```

Копирование файлов и каталогов:

```bash
cp file1.txt file1_copy.txt
cp file2.txt dir1/
cp -r dir1 dir1_copy
ls -l
ls -l dir1
```

Переименование и перемещение:

```bash
mv file3.txt renamed_file.txt
mv renamed_file.txt dir2/
mv dir3 katalog
ls
ls dir2
```

Выборка столбцов:

```bash
cut -c 1,3,4,5,16-22 table.txt
```

Поиск текста:

```bash
grep linux docs.txt
grep -i linux docs.txt
grep -c Linux docs.txt
grep -v Linux docs.txt
grep '^Ubuntu' docs.txt
grep 'system$' docs.txt
```

Поиск файлов:

```bash
find . -name "*.txt"
find . -type f
find . -type d
find . -maxdepth 1 -type f
find . -name "*.txt" -exec ls -l {} \;
```

Удаление файлов и каталогов:

```bash
rm file1_copy.txt
rmdir parent/child/grandchild
rm -r dir1_copy
ls -l
```

## Результат

В ходе работы были выполнены команды для создания, просмотра, копирования, перемещения, переименования, поиска и удаления файлов и каталогов.

## Скриншоты

- [Создание каталогов и файлов](screenshots/01-directories-and-files.png)
- [Создание файлов и копирование](screenshots/02-cat-and-copy.png)
- [Перемещение, cut, grep и find](screenshots/03-move-cut-grep-find.png)
- [Результаты find](screenshots/04-find-results.png)
- [Удаление файлов и итоговый список](screenshots/05-remove-results.png)
