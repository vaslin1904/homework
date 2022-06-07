# **Автоматическое монтирование сетевой папки.NFS systemd,fstab**
___________________________________________________________________
## **Настройка сервера**
________________________________________________
1. Подключаемся к серверу: **vagrant ssh nfss**.
2. Все команды выполняем под суперпользователем: **sudo su**.
3. Устанавливаем утилиты для работы с nfs: **yum install -y nfs-utils**.
4. Включаем firewall: **systemctl enable firewalld --now**.
5. Проверяем firewalld: **systemctl status firewalld**.
6. Разрешаем в firewall доступ к сервисам NFS:</br>
-firewall-cmd -- permanent --add-service="nfs3"</br>
-firewall-cmd -- permanent --add-service="nfs" </br>
-firewall-cmd -- permanent --add-service="rpc-bind"</br>
-firewall-cmd  -- permanent  --add-service="mountd"</br>
7. Перезагружаем firewall:  firewall-cmd --reload.
8. Включаем сервер NFS (настройки в файле /etc/nfs.conf): **systemctl enable nfs --now**.
9. Проверяем статус слушаемых портов 2049/udp, 2049/tcp, 20048/udp,20048/tcp, 111/udp, 111/tcp: **ss -tnplu**.
10. Создаём и настраиваем директорию, которая будет экспортирована в будущем:</br>
-mkdir -p /srv/share/upload,</br>
-chown -R nfsnobody:nfsnobody /srv/share (назначается владелец директории),</br>
-chmod 0777 /srv/share/upload (назначаются права для папки). </br>
11. Создаём в файле */etc/exports* структуру, которая позволит экспортировать ранее созданную директорию.</br>
**cat << EOF > /etc/exports</br>
/srv/share 192.168.50.11/32(rw,sync,root_squash)</br>
EOF**</br>
12. Экспортируем ранее созданную директорию: **exportfs -r**.
13. Проверяем экспортированную директорию: : **exportfs -s**.
14. Создаем файл в расшаренной папке для проверки:**touch /srv/share/upload/check_file2**. 
____________________________________________________________
## **Настройка клиента**
____________________________________________________________
1. Подключаемся к клиенту: **vagrant ssh nfsс**.
2. Все команды выполняем под суперпользователем: **sudo su**.
3. Устанавливаем утилиты для работы с nfs: **yum install -y nfs-utils**.
4. Включаем firewall: **systemctl enable firewalld --now**.
5. Проверяем firewalld: **systemctl status firewalld**.
6. Монтируем расшаренную папку сервера в папку mnt клиента. Изменение fstab:</br>
**cho "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab**/
7. Автоматически генерируем systemd units в каталоге */run/systemd/generator/*:</br>
-systemctl daemon-reload.
-systemctl restart remote-fs.target.
8.Systemd units в каталоге производят монтирование при первом обращении к каталогу */mnt/*:**cd mnt**.
9.Проверяем успешность монтирования: **mount | grep mnt**.
10. В каталоге /mnt/ есть смонтированный каталог с сервера upload, а в нем есть файл **check_file2**.
___________________________________________________________________
## **Вывод**
_____________________________________________________________________
Все выполненные действия по настройке сервера и клиента записаны в соответствующие скрипты и добавлены в Vagrantfile.</br>
В данной работе было использовано автоматическое монтирование сетевой папки с помощью </br>
NFS, systemd и файла fstab.</br>
Все порты были открыты через firewall.</br>
Права чтение/запись для пользователя клиента настроены с помощью команд: chown и chmod.</br>
Во время выполнения задания были трудности с формированием правильного файла fstab, соблюдение всех пробелов.</br>
