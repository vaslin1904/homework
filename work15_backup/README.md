#  Создание резервных копий.
Настроить стенд Vagrant с двумя виртуальными машинами: backup_server и client. </br>
Настроить удаленный бэкап каталога /etc c сервера client при помощи borgbackup.</br>
Резервные копии должны соответствовать следующим критериям:</br>
 * директория для резервных копий /var/backup;</br>
 * репозиторий для резервных копий должен быть зашифрован ключом или паролем;</br>
 * имя бэкапа должно содержать информацию о времени снятия бекапа;</br>
 * глубина бекапа должна быть год, хранить можно по последней копии на конец месяца, кроме последних трех. Последние три месяца должны содержать копии на каждый день;</br>
 * резервная копия снимается каждые 5 минут;</br>
 * написан скрипт для снятия резервных копий. Скрипт запускается из соответствующей Cron, либо systemd timer;</br>
 * настроено логирование процесса бекапа. Для упрощения можно весь вывод перенаправлять в logger с соответствующим тегом.</br>
_______________________________________________________________________
# Выполнение задания:
## Настройка времени на всех хостах
Для правильной работы c логами, нужно, чтобы на всех хостах было настроено одинаковое время.</br>
Укажем часовой пояс (Московское время):</br>
**cp/usr/share/zoneinfo/Europe/Moscow /etc/localtime**</br>
Перезупустим службу NTP Chrony: </br>
**systemctl restart chronyd**</br>
Проверим, что служба работает корректно: </br>
**systemctl status chronyd**</br>
![img](image/1%20repo%20borg.png)</br>
 Подключаем EPEL репозиторий с дополнительными пакетами
# yum install epel-release
 Устанавливаем borgbackup
# yum install borgbackup
server
На сервере backup создаем пользователя и каталог /var/backup (в
домашнем задании нужно будет создать диск ~2Gb и
примонтировать его) и назначаем на него права пользователя borg
 useradd -m borg
# mkdir /var/backup
# chown borg:borg /var/backup/

На сервер backup создаем каталог ~/.ssh/authorized_keys в
каталоге /home/borg
# mkdir
# mkdir .ssh
# touch .ssh/authorized_keys
# chmod 700 .ssh
# chmod 600 .ssh/authorized_keys


client
генерируем ssh-ключ и добавляем его на сервер backup в
файл authorized_keys созданным на прошлом шаге
# ssh-keygen
ssh-copy-id borg@192.168.56.160

 Инициализируем репозиторий borg на backup сервере с client
сервера:
# borg init --encryption=repokey borg@192.168.56.160:/var/backup/first
**1**
Запускаем для проверки создания бэкапа
sudo borg create --list --stats borg@192.168.56.160:/var/backup/first::"etc-{now:%Y-%m-%d_%H:%M:%S}" /etc
**2**

Список backup
borg list borg@192.168.56.160:/var/backup/first
**3**
Смотрим список файлов
# borg list borg@192.168.56.160:/var/backup/first/::etc-2023-04-08_16:06:52

**4**
Достаем файл из бекапа
borg extract borg@192.168.56.160:/var/backup/first/::etc-2023-04-08_16:06:52 etc/hostname
************
Автоматизируем создание бэкапов с помощью systemd
Создаем сервис и таймер в каталоге /etc/systemd/system/
# /etc/systemd/system/borg-backup.service

 Включаем и запускаем службу таймера
# systemctl enable borg-backup.timer
# systemctl start borg-backup.timer
**5**
Проверяем копии:
**
6**
