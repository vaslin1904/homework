# **Systemd**
___________________________________________
## **Создание сервиса мониторинга**
___________________________________________
1. Создадим файл конфигурации для сервиса: /etc/sysconfig/watchlog.cfg
**echo "Congiguration file for my watchdog service">watchlog.cfg** <br>
![Директория /etc/sysconfig](картинки/1.png)
<br>В файл конфигурации добавляем слово Alert, которое сервис мониторинга будет искать в лог файле */var/log/watchlog.log*<br>
![Содержимое файла watchlog.cfg](картинки/2.png)
2. Создадим лог файл со словами: /var/log/watchlog.log:
            **touch /var/log/watchlog.log**<br>
![Содержимое файла watchlog.log](картинки/3.png)<br>
3. Создаем скрипт, который ищет заданное слово в лог файле: */opt/watshlog.sh*<br>
Даем права на выполнение скрипта chmod +x /opt/watshlog.sh<br>
![Скрипт поиска](картинки/4.png)<br>
4. Создаем сервис мониторинга и таймер для его периодическго запуска в директории /etc/systemd/<br>
см. файлы watchlog.service и watchlog.timer.<br>
5. Запускаем созданные сервис и таймер systemd. <br>
![Запуск watchlog.timer](картинки/5.png)<br>
6. Проверим работу системы мониторинга:<br>
**tail -f /var/log/messages**<br>
![Мониторинг файла](картинки/6.png)<br>
_____________________________________________________________________
## **Переписать init-скрипт на unit-файл**
_____________________________________________________________________
1. Устанавливаем spawn-fcgi и необходимые для него пакеты:<br>
**yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y**
2. В файле /etc/sysconfig/spawn-fcgi раскомментируем строку "OPTIONS".<br>
![Файл spawn-fcgi](картинки/7.png)<br>
3. Создаем юнит: **vi /etc/systemd/system/spawn-fcgi.service**<br>.
см. файл spawn-fcgi.service. <br>
4. Запускаем созданный сервис. <br>
![Запуск spawn-fcgi.service](картинки/8.png)<br>
______________________________________________
## **Добавить модуль в initrd**
______________________________________________
1. Создадим папку с именем *01test*:**mkdir /usr/lib/dracut/modules.d/01test**

![Создание папки](images/module_dir.png)

2. В созданную папку помещаем скрипт *module-setup.sh*:

![Создание скрипта](images/module_sh.png)

3.  В созданную папку помещаем скрипт *test.sh*:

![Создание скрипта](images/module_test_sh.png)

4.  Пересобираем образ файловой системы, загружаемый в оперативную память вместе с ядром - **initramfs**:<br>
**mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)**<br>
или<br>
**dracut -f -v**

![Пересборка initramfs](images/module_initramfs.png)

5. Убедимся, что модуль test загружен в образ: **lsinitrd -m /boot/initramfs-$(uname -r).img | grep test**

![Проверка загрузки модуля](images/module_check.png)

6. Отредактируем файл grub.cfg. Убираем параметры rghb и quiet.
**В результате загрузки системы подзагружается новый модуль**

![Результат загрузки модуля](images/module_rez.png)

____________________________________________
## **Вывод**
_____________________________________________
Файл Vagrant подзагружает box из облака, в котором уже есть LVM и переименована Volume Group, <br>
а также при запуске системы в графическом режиме Virtual Box можно увидеть встроенный модуль ядра при загрузке системы.

