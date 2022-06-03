# **Работа с файловой системой ZFS**
________________________________________________
## 1 Часть. Определение наилучшего метода сжатия.
________________________________________________
- Смотрим информацию о существующих блочных устройствах в системе:
___***lsblk*
- Создаем 4-ре пула, состоящих из двух дисков, в режиме Рейд1<br>
___**zpool create otus1 mirror /dev/sdb /dev/sdc
zpool create otus2 mirror /dev/sdd /dev/sde
zpool create otus3 mirror /dev/sdf /dev/sdg
zpool create otus4 mirror /dev/sdh /dev/sdi**
- Смотрим информацию о размере пула, количеству занятого и свободного места, дедупликации:
___**zpool list**
- Посмореть информацию о каждом диске, состоянии сканирования и об ошибках чтения, записи и совпадения хэш-сумм
можно с помощью:
___**zpool status**
- Добавим разные алгоритмы сжатия в каждую файловую систему:
___**zfs set compression=lzjb otus1
___zfs set compression=lz4 otus2
___zfs set compression=gzip-9 otus3
___zfs set compression=zle otus4**
- Проверим результат:
___**zfs get all | grep compression**
- Для проверки методов сжатия скачаем файл во все пулы:
___**for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done**
- Проверим результат скачивания:
___**ls -l /otus**
Меньше всего блоков занимает файл в пуле otus3: total 10950.
- Проверим, сколько места занимает один и тот же файл в разных пулах: 
___**zfs list**
**NAME    USED  AVAIL     REFER  MOUNTPOINT
otus1  21.8M   330M     21.5M  /otus1
otus2  17.8M   334M     17.6M  /otus2
otus3  10.9M   341M     10.7M  /otus3
otus4  39.2M   313M     39.0M  /otus4**
- Проверим степень сжатия файлов:
**zfs get all | grep compressratio | grep -v ref** 
**[root@zfs ~]# zfs get all |grep compressratio |grep -v ref
otus1  compressratio         1.81x                  -
otus2  compressratio         2.21x                  -
otus3  compressratio         3.63x                  -
otus4  compressratio         1.00x                  -**
Самая большая степень сжатия в пуле otus3, значит,
**алгоритм gzip-9 самый эффективный.**
________________________________________________
# 2 Часть. Определить настройки pool.
_________________________________________________
- Скачаем архив в домашний каталог:
___**wget -O archive.tar.gz --no-check-certificate "https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&e xport=download"**
- Распакуем его:
___**tar -xzvf archive.tar.gz**
- Проверим можно ли импортировать данный каталог в пул:
___**zpool import -d zpoolexport/**
**[root@zfs ~]# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

        otus                         ONLINE
          mirror-0                   ONLINE
            /root/zpoolexport/filea  ONLINE
            /root/zpoolexport/fileb  ONLINE**
Вывод показывает нам имя пула, тип raid и его состав.
- Сделаем импорт данного пула в ОС:
___**zpool import -d zpoolexport/ otus**
- Вывести все настройки pool можно командой:
___**zpool get all otus**
или 
___**zfs get all otus**
- Размер хранилища - *350 М* :
___** zfs get available otus**
- Тип pool - *filesystem* 
___**zfs get type otus**
- Значение recordsize -*128 K*
___**zfs get recordsize otus**
- Используемое сжатие - zle
___**zfs get compression otus**
- Контрольная сумма - sha256
___**zfs get checksum otus**
________________________________________________
# 3.Часть. Восстановление pool.
________________________________________________
- Восстановим систему с закаченного файла otus_task2.file
1. Скачаем этот файл:
**wget -O otus_task2.file --no-check-certificate "https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&e xport=download"**
2. Восстанавливаем pool со скаченного файла
**zfs receive otus/test@today < otus_task2.file**
_________________________________________________
# 4. Часть. Секретное сообщение от преподавателя.
_________________________________________________
- В каталоге найдем файл “secret_message”
___**find /otus/test -name "secret_message"**
*/otus/test/task1/file_mess/secret_message*
- Откроем этот файл
___**cat /otus/test/task1/file_mess/secret_message**
*https://github.com/sindresorhus/awesome*
<center>
<img width="500" height="350" src="media/secret.jpg" alt="secret message">
</center>
_________________________________________________________
# Вывод
___________________________________________________________
В данной работе познакомилась с основными командами zfs.
Из Vagrantfile команды по установке ZFS перенесены в отдельный скрипт
**install_zfs.sh**
который был подключен в Vagrantfile командой path.
Выполнение домашней работы в командной строке запротоколировано в файле
**zfs.log**