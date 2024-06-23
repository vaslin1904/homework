# **Работа с LVM**
___________________________________________
## **1.Уменьшение размера тома**
___________________________________________
 - Все команды должны выполняться в режиме суперпользователя. Переходим в этот режим:<br>
 **[vagrant@lvm ~]$ sudo su**<br>
  - Небходимо установить пакет для создания копии тома:<br>
**yum install xfsdump**<br>
  - Просмотрим информацию о блочных устройствах и о LVM:<br>
**lsblk<br>
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT<br>
sda                       8:0    0   40G  0 disk<br>
├─sda1                    8:1    0    1M  0 part<br>
├─sda2                    8:2    0    1G  0 part /boot<br>
└─sda3                    8:3    0   39G  0 part<br>
  ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /<br>
  └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]<br>
sdb                       8:16   0   10G  0 disk<br>
sdc                       8:32   0    2G  0 disk<br>
sdd                       8:48   0    1G  0 disk<br>
sde                       8:64   0    1G  0 disk**<br>
  - Создаем LVM:<br>
1.**pvcreate /dev/sdb/**<br>
2.**vgcreate vg_root /dev/sdb**<br>
3.**lvcreate -n lv_root -l +100%FREE /dev/vg_root**<br>
  - На логической группе разварачиваем файловую систему:<br>
**mkfs.xfs /dev/vg_root/lv_root**<br>
  - Просмотрим информацию о LVM:<br>
**lsblk<br>
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT<br>
sda                       8:0    0   40G  0 disk<br>
├─sda1                    8:1    0    1M  0 part<br>
├─sda2                    8:2    0    1G  0 part /boot<br>
└─sda3                    8:3    0   39G  0 part<br>
  ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /<br>
  └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]<br>
sdb                       8:16   0   10G  0 disk<br>
└─vg_root-lv_root       253:2    0   10G  0 lvm<br>
sdc                       8:32   0    2G  0 disk<br>
sdd                       8:48   0    1G  0 disk<br>
sde                       8:64   0    1G  0 disk**<br>

**lvscan<br>
  ACTIVE            '/dev/VolGroup00/LogVol00' [<37.47 GiB] inherit<br>
  ACTIVE            '/dev/VolGroup00/LogVol01' [1.50 GiB] inherit<br>
  ACTIVE            '/dev/vg_root/lv_root' [<10.00 GiB] inherit**<br>
  - Смонтируем логическую группу в /mnt:<br>
**sudo mount /dev/vg_root/lv_root /mnt**<br>
  - Разворачиваем копию логической группы, на которой в настоящее время находится корневой раздел во временную логическую группу.<br> 
**xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt**<br>
  - Монтируем перечисленные папки в каталог /mnt, сохраняя исходную точку монтирования:<br>
**for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done**
  - Меняем корневой каталог диска для запущенного процесса и его дочерних процессов.<br>
  - Программа, запущенная в таком окружении, не может получить доступ к файлам вне нового корневого каталога.<br>
**chroot /mnt/**<br>
  - Сгенерируем новый конфигурационный файл для grub:<br>
**grub2-mkconfig -o /boot/grub2/grub.cfg**<br>
- Обновляем образ initrd, временной файловой системы, используемой ядром Linux при начальной загрузке. <br>
**cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done**<br>
  - Изменим в конфигурационном файле grub загрузку с *VolGroup00/LogVol00* на *vg_root/lv_root*:<br>
**vi /boot/grub2/grub.cfg**<br>
  - Перезагружаем систему, перед перезагрузкой нужно выйти из окружения *chroot jail*:<br>
1. **exit**<br>
2. **reboot**<br>
  - Во вновь запущенной системе просмотрим, что получилось:<br>
**lsblk<br>
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT<br>
sda                       8:0    0   40G  0 disk<br><br>
├─sda1                    8:1    0    1M  0 part<br>
├─sda2                    8:2    0    1G  0 part /boot<br>
└─sda3                    8:3    0   39G  0 part<br>
  ├─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]<br>
  └─VolGroup00-LogVol00 253:2    0 37.5G  0 lvm<br>
sdb                       8:16   0   10G  0 disk<br>
└─vg_root-lv_root       253:0    0   10G  0 lvm  /<br>
sdc                       8:32   0    2G  0 disk<br>
sdd                       8:48   0    1G  0 disk<br>
sde                       8:64   0    1G  0 disk<br>
sudo su<br>
lvscan<br>
  ACTIVE            '/dev/VolGroup00/LogVol00' [<37.47 GiB] inherit<br>
  ACTIVE            '/dev/VolGroup00/LogVol01' [1.50 GiB] inherit<br><br>
  ACTIVE            '/dev/vg_root/lv_root' [<10.00 GiB] inherit**<br>
  - Удаляем изначальную логическую группу с корневой системой:<br>
**lvremove /dev/VolGroup00/LogVol00**<br>
  - Создаем заново логическую группу, в которой хранилась система, с новым размером:<br>
**vcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00**<br>
   - На логической группе разварачиваем файловую систему:<br>
**mkfs.xfs /dev/VolGroup00/LogVol00**<br>
   - Смонтируем логическую группу в /mnt:<br>
**sudo mount /dev/VolGroup00/LogVol00 /mnt**<br>
  - Разворачиваем копию логической группы, на которой в настоящее время находится корневой раздел в исходную логическую группу.<br>
**xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt**<br>
  - Монтируем перечисленные папки в каталог /mnt, сохраняя исходную точку монтирования:<br>
**for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done**<br>
  - Меняем корневой каталог диска для запущенного процесса и его дочерних процессов.<br>
  - Программа, запущенная в таком окружении, не может получить доступ к файлам вне нового корневого каталога.<br>
**chroot /mnt/**<br>
  - Сгенерируем новый конфигурационный файл для grub:<br>
**grub2-mkconfig -o /boot/grub2/grub.cfg**<br>
  - Обновляем образ initrd, временной файловой системы, используемой ядром Linux при начальной загрузке. <br>
**cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done**<br>
  - Смотрим результат уменьшения раздела root:<br>
**lsblk<br>
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT<br><br>
sda                       8:0    0   40G  0 disk<br>
├─sda1                    8:1    0    1M  0 part<br>
├─sda2                    8:2    0    1G  0 part /boot<br>
└─sda3                    8:3    0   39G  0 part<br>
  ├─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]<br>
  └─VolGroup00-LogVol00 253:2    0    8G  0 lvm  /<br>
sdb                       8:16   0   10G  0 disk<br>
└─vg_root-lv_root       253:0    0   10G  0 lvm<br>
sdc                       8:32   0    2G  0 disk<br>
sdd                       8:48   0    1G  0 disk<br>
sde                       8:64   0    1G  0 disk**<br>
__________________________________________________________________________________________________________________________
## 2.Выделенный том под /var. Создание зеркала
__________________________________________________________________________________________________________________________
- Создаем LVM с зеркалом<br>
**pvcreate /dev/sde /dev/sdd**<br>
**vgcreate vg_var /dev/sde /dev/sdd**<br>
**lvcreate -L 950M -m1 -n lv_var vg_var**<br>
**mkfs.ext4 /dev/vg_var/lv_var**<br>
- Монтируем созданный логический раздел<br>
**sudo  mount /dev/vg_var/lv_var /mnt**<br>
- Копируем каталог /var в mnt с синхронизацией файлов.<br>
**cp -aR /var/* /mnt/ # rsync -avHPSAX /var/ /mnt/**
- Размонтируем каталог<br>
**sudo umount /mnt**<br>
- Монтируем новый каталог в /var<br>
**sudo mount /dev/vg_var/lv_var /var**
- Вносим изменения в файл fstab для автоматического монтирвания при запуске системы.<br>
**echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab**<br>
**cat /etc/fstab<br>
#<br>
#/etc/fstab<br>
#Created by anaconda on Sat May 12 18:50:26 2018<br>
#<br>
#Accessible filesystems, by reference, are maintained under '/dev/disk'<br>
#See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info<br>
#<br>
/dev/mapper/VolGroup00-LogVol00 /                       xfs     defaults        0 0<br>
UUID=570897ca-e759-4c81-90cf-389da6eee4cc /boot                   xfs     defaults        0 0<br>
/dev/mapper/VolGroup00-LogVol01 swap                    swap    defaults        0 0<br>
#VAGRANT-BEGIN<br>
#The contents below are automatically generated by Vagrant. Do not modify.<br>
#VAGRANT-END<br>
UUID="578ea5e7-8e24-4246-a805-06d01746612b" /var ext4 defaults 0 0**<br>
- Перезагружаем систему, перед перезагрузкой нужно выйти из окружения *chroot jail*:<br>
**1. exit<br>
2.reboot**<br>
 - Смотрим результат выполненной работы <br>
**lsblл<br>
NAME                     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT<br>
sda                        8:0    0   40G  0 disk<br>
├─sda1                     8:1    0    1M  0 part<br>
├─sda2                     8:2    0    1G  0 part /boot<br>
└─sda3                     8:3    0   39G  0 part<br>
  ├─VolGroup00-LogVol00  253:0    0    8G  0 lvm  /<br>
  └─VolGroup00-LogVol01  253:1    0  1.5G  0 lvm  [SWAP]<br>
sdb                        8:16   0   10G  0 disk<br>
└─vg_root-lv_root        253:2    0   10G  0 lvm<br>
sdc                        8:32   0    2G  0 disk<br>
sdd                        8:48   0    1G  0 disk<br>
├─vg_var-lv_var_rmeta_1  253:5    0    4M  0 lvm<br>
│ └─vg_var-lv_var        253:7    0  952M  0 lvm  /var<br>
└─vg_var-lv_var_rimage_1 253:6    0  952M  0 lvm<br>
  └─vg_var-lv_var        253:7    0  952M  0 lvm  /var<br>
sde                        8:64   0    1G  0 disk<br>
├─vg_var-lv_var_rmeta_0  253:3    0    4M  0 lvm<br>
│ └─vg_var-lv_var        253:7    0  952M  0 lvm  /var<br>
└─vg_var-lv_var_rimage_0 253:4    0  952M  0 lvm<br>
  └─vg_var-lv_var        253:7    0  952M  0 lvm  /var**<br>
  - Удаляем временно созданный vg_root/lv_root<br>
  **1. lvremove /dev/vg_root/lv_root<br>
    2. vgremove /dev/vg_root<br>
    3. pvremove /dev/sdb**<br>
   - Смотрим результат работы <br>
   **lvscan<br>
  ACTIVE            '/dev/VolGroup00/LogVol01' [1.50 GiB] inherit<br>
  ACTIVE            '/dev/VolGroup00/LogVol00' [8.00 GiB] inherit<br>
  ACTIVE            '/dev/vg_var/lv_var' [952.00 MiB] inherit<br>
_____________________________________________________________________________
## Выделить том под /home. Сделать Snapshot для /home. Восстановить /home.<br>
_____________________________________________________________________________
- Создаем логический том в VolGroup00<br>
**lvcreate -n LogVol_Home -L 2G /dev/VolGroup00**<br>
- Смотрим информацию по LVM<br>
**lvscan<br>
  ACTIVE            '/dev/VolGroup00/LogVol01' [1.50 GiB] inherit<br>
  ACTIVE            '/dev/VolGroup00/LogVol00' [8.00 GiB] inherit<br>
  ACTIVE            '/dev/VolGroup00/LogVol_Home' [2.00 GiB] inherit<br>
  ACTIVE            '/dev/vg_var/lv_var' [952.00 MiB] inherit**<br>
 - Создаем файловую систему<br>
**mkfs.xfs /dev/VolGroup00/LogVol_Home<br>
- Монтируем VolGroup00/LogVol_Home в /mnt<br>
**sudo mount /dev/VolGroup00/LogVol_Home /mnt/<br>
- Копируем /home в /mnt<br>
**cp -aR /home/* /mnt/**<br>
- Удаляем папку /home со всеми подпапками и файлами<br>
**rm -rf /home/***
- Размонтируем /mnt<br>
**sudo umount /mnt**<br>
- И монтируем VolGroup00/LogVol_Home в /home<br>
**sudo mount /dev/VolGroup00/LogVol_Home /home/**<br>
- Вносим в fstab изменения для автоматического монтирования /home<br>
**echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab**<br>
**cat /etc/fstab
#
#/etc/fstab<br>
#Created by anaconda on Sat May 12 18:50:26 2018<br>
#
#Accessible filesystems, by reference, are maintained under '/dev/disk'<br>
#See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info<br>
#
/dev/mapper/VolGroup00-LogVol00 /                       xfs     defaults        0 0<br>
UUID=570897ca-e759-4c81-90cf-389da6eee4cc /boot                   xfs     defaults        0 0<br>
/dev/mapper/VolGroup00-LogVol01 swap                    swap    defaults        0 0<br>
#VAGRANT-BEGIN<br>
#The contents below are automatically generated by Vagrant. Do not modify.<br>
#VAGRANT-END<br>
UUID="578ea5e7-8e24-4246-a805-06d01746612b" /var ext4 defaults 0 0<br>
UUID="b1738ca5-22f3-42df-addf-9b7f3ecbaf8e" /home xfs defaults 0 0**<br>
- Проеряем<br>
**lsblk<br>
NAME                       MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT<br>
sda                          8:0    0   40G  0 disk<br>
├─sda1                       8:1    0    1M  0 part<br>
├─sda2                       8:2    0    1G  0 part /boot<br>
└─sda3                       8:3    0   39G  0 part<br>
  ├─VolGroup00-LogVol00    253:0    0    8G  0 lvm  /<br>
  ├─VolGroup00-LogVol01    253:1    0  1.5G  0 lvm  [SWAP]<br>
  └─VolGroup00-LogVol_Home 253:2    0    2G  0 lvm  /home<br>
sdb                          8:16   0   10G  0 disk<br>
sdc                          8:32   0    2G  0 disk<br>
sdd                          8:48   0    1G  0 disk<br>
├─vg_var-lv_var_rmeta_1    253:5    0    4M  0 lvm<br>
│ └─vg_var-lv_var          253:7    0  952M  0 lvm  /var<br>
└─vg_var-lv_var_rimage_1   253:6    0  952M  0 lvm<br>
  └─vg_var-lv_var          253:7    0  952M  0 lvm  /var<br>
sde                          8:64   0    1G  0 disk<br>
├─vg_var-lv_var_rmeta_1    253:5    0    4M  0 lvm<br>
│ └─vg_var-lv_var          253:7    0  952M  0 lvm  /var<br>
└─vg_var-lv_var_rimage_1   253:6    0  952M  0 lvm<br>
  └─vg_var-lv_var          253:7    0  952M  0 lvm  /var**<br>
- Создадим /home 20 файлов<br>
**touch /home/file{1..20}<br>
ls /home<br>
file1   file11  file13  file15  file17  file19  file20  file4  file6  file8  vagrant<br>
file10  file12  file14  file16  file18  file2   file3   file5  file7  file9**<br>
- Создаем Snapshot для VolGroup00/LogVol_Home<br>
**lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home**
- Удаляем часть файлов из /home<br>
**rm -f /home/file{11..20}<br>
[root@lvm vagrant]# ls /home<br>
file1  file10  file2  file3  file4  file5  file6  file7  file8  file9  vagrant**<br>
-  Размонтируем /mnt.  Восстановим /home<br>
**1. sudo umount /home<br>
2.lvconvert --merge /dev/VolGroup00/home_snap<br>
3.sudo mount /home<br>
- Проверяем результат восстановления<br>
**ls /home<br>
file1   file11  file13  file15  file17  file19  file20  file4  file6  file8  vagrant<br>
file10  file12  file14  file16  file18  file2   file3   file5  file7  file9<br>
Connection to 127.0.0.1 closed.**<br>
__________________________________________________________________________________________
## Вывод
_________________________________________________________________________________________
В данной работе было рассмотрено:<br>
-создание и удаление LVM<br>
-уменьшение корневой папки с помощью переноса образа логического тома<br>
-изменение запуска системы с помощью конфигурирования grub<br>
-обновление образа временной файловой системы initrd<br>
-создание логического тома с зеркалом уже в существующем LVM<br>
-создание snapshot и восстановление с него.<br>
Выполнение работы в командной строке представлено в файле txt.<br>

