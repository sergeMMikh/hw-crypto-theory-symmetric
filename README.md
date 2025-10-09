# Домашнее задание к занятию «3.1. Теоретические основы криптографии, симметричные криптосистемы»- Михалёв Сергей

## Задача №1 - HashCat

### Справка

[hashcat](https://hashcat.net/hashcat/) - инструмент восстановления паролей.

### Установка

Для установки достаточно скачать архив с официального сайта:

![](pic/hashcat.png)

<details>
<summary>Для счастливых обладателей Mac</summary>

Если вам повезло и вы пользователь Mac, то для вас готового hashcat в указанном архиве на официальном сайте нет, поэтому вам будет необходимо установить [Homebrew](https://brew.sh). Для этого небоходимо перейти по адресу https://brew.sh выполнить указанную на главной странице команду в терминале:

![](pic/brew.png)

После чего в терминале (в любом каталоге) выполнить команду:

```shell script
brew install hashcat
```

Индикатором успешности установки будет служить успешное выполнение следующей команды:

```shell script
hashcat --help
```

</details>

Архив упакован с помощью архиватора [7zip](https://www.7-zip.org/download.html), поэтому, возможно, вам придётся установить и его.

Распакуйте архив в каталог на вашем компьютере и откройте терминал каталоге, в котором расположены файлы `hashcat.bin` и `hashcat.exe` (см. [руководство по терминалу](../terminal)).

Для Linux необходимо запускать в терминале hashcat командой `./hashcat.bin` (находясь в том же каталоге), в Windows командой `.\hashcat.exe` (находясь в том же каталоге), а в Mac просто `hashcat` (при этом никакой архив с hashcat вам не нужен).

Далее для простоты мы будем просто писать `hashcat`, а не `./hashcat.bin` или `.\hashcat.exe`.

### Справка

Справка по работе с приложением выводится с помощью флага `--help`:
```shell script
hashcat --help
```

В общем виде hashcat запускается в следующем виде:
```shell script
hashcat [options] hash [dictionary]
```

### Задание

Каким-то образом у вас оказался хэш пароля. Вот такой: `5693299e0bbe87f327caa802008af432fbe837976b1232f8982d3e101b5b6fab`.

Что нужно сделать: вам нужно попробовать по длине хэша угадать его тип (это будет один из тех, что упоминался на лекции, как минимум, в табличке в конце лекции).

<details>
<summary>Подсказка</summary>
  
Обратите внимание, мы не просто так говорим про длину.
</details>

<details>
<summary>Использование hashcat</summary>

Запустить hashcat для подбора пароля можно в следующем формате:

`hashcat -m <X> 5693299e0bbe87f327caa802008af432fbe837976b1232f8982d3e101b5b6fab wordlist.txt`

Где `<X>` это тип хэша, в соответствии с таблицей (т.е. для GOST R 34.11-2012 (Streebog) 256-bit, big-endian будет `11700`):

|     # | Name                                             | Category                            |
|-------|--------------------------------------------------|-------------------------------------|
|   900 | MD4                                              | Raw Hash                            |
|     0 | MD5                                              | Raw Hash                            |
|   100 | SHA1                                             | Raw Hash                            |
|  1300 | SHA2-224                                         | Raw Hash                            |
|  1400 | SHA2-256                                         | Raw Hash                            |
| 10800 | SHA2-384                                         | Raw Hash                            |
|  1700 | SHA2-512                                         | Raw Hash                            |
| 11700 | GOST R 34.11-2012 (Streebog) 256-bit, big-endian | Raw Hash                            |
| 11800 | GOST R 34.11-2012 (Streebog) 512-bit, big-endian | Raw Hash                            |
|  6900 | GOST R 34.11-94                                  | Raw Hash                            |

А `wordlist.txt` - файл с самыми распространёнными паролями. Набор таких файлов вы можете найти по адресу https://github.com/danielmiessler/SecLists/tree/master/Passwords/Common-Credentials.

Т.е. мы собираемся осуществить атаку по словарю.

Мы рекомендуем вам использовать [`Common-Credentials/10-million-password-list-top-100000.txt`](https://gitlab.com/kalilinux/packages/seclists/-/blob/kali/master/Passwords/Common-Credentials/10-million-password-list-top-100000.txt).

</details>

---

## Решение.

После клонирования репозитория [SecLists](https://github.com/danielmiessler/SecLists) получаем достаточно обширную (40 документов) бибилотеку файлов с общепринятыми паролями. </br>
![lib-list](images/Task-1/image.png)

Согласно рекомендации задания и в соответсвии с примером на занятии делаю попытку подобрать пароль используя файл Common-Credentials/10-million-password-list-top-100000.txt предполагая тип хеширования MD5.</br>
![alt text](images/Task-1/image-1.png)

Узнаём длину хеша. 64 символа или 256 бит</br>
![alt text](images/Task-1/image-2.png)

В [документации к приложению](https://cocalc.com/github/hashcat/hashcat/blob/master/docs/exit_status_code.txt) находим список кодов возврата, так что можнопросто проверить результат (это позже пригодится).</br>
![alt text](images/Task-1/image-3.png)

![alt text](images/Task-1/image-4.png)

Не выходит. Но вспоминаем программирование на bash, и ипшем скрипт [uncript.sh](uncript.sh).

Создаём список "модов" (методов хешированиря):
```bash
modes=(
  "900"     
  "0"      
  "100"     
  "1300"   
  "1400"    
  "10800"  
  "1700"  
  "11700"   
  "11800"  
  "6900"   
)
```
Далее циклом `for`перебираем все моды.

Результат- пароль `MARINA`.</br>
![alt text](images/Task-1/image-5.png)

Здесь код возврата 255 появляется там, где длина хэша не подходит выбранному режиму (hashcat выдаёт “Token length exception”). Это будет учтено [в улучшеном варианте](advansed-uncript.sh).

Ничто не помешает использовать цикл для всех файлов в директории `SecLists/Passwords/Common-Credentials`. Но эта процедура займёт уйму времени.

