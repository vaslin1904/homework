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
![Содержимое файла watchlog.log](картинки/3.png)
3.Создаем скрипт, который ищет заданное слово в лог файле: */opt/watshlog.sh*<br>
![Скрипт поиска](картинки/4.png)<br>
4.Создаем сервис мониторинга и таймер для его периодическго запуска в директории /etc/systemd/
см. файлы 
_____________________________________________________________________
## **Установить систему с LVM, после чего переименовать VG**
_____________________________________________________________________
1. Убедимся в наличии *lvm*: **vgs**
![Проверка LVM](images/lvm_check.png)
2. Переименуем *Volume* группу: **vgrename VolGroup00 OtusRoot**

![Переименование Volume Group](images/lvm_renameVG.png)
3. Правим файл монтирования: **vi /etc/fstab**

![Правка файла fstab](images/lvm_edit_fstab.png)
4. Правим файл с начальными настройками загрузчика: **vi /etc/default/grub**

![Правка default Grub](images/lvm_editGrub.png)
5. Правим конфигурационный файл загрузчика: **vi /boot/grub2/grub.cfg**

![Правка файла grub.cfg](images/lvm_edit_Grub2.png)
6. Пересобираем образ файловой системы, загружаемый в оперативную память вместе с ядром - **initramfs**:<br>
**mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)**

![Пересборка initramfs](images/lvm_edit_Grub2.png)
7. Перезагружаем систему и убеждаемся, что LVM имеет измененное имя Volume Group:

![Проверка загрузки системы с новым имененм VG](images/lvm_checkWork.png) 
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
