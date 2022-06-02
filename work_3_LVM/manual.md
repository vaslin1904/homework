# **Работа с LVM**
___________________________________________
## **1.Уменьшение размера тома**
___________________________________________
  Все команды должны выполняться в режиме суперпользователя. Переходим в этот режим:<br>
 **[vagrant@lvm ~]$ sudo su**<br>
  Небходимо установить пакет для создания копии тома:<br>
**yum install xfsdump**<br>
  Просмотрим информацию о блочных устройствах и о LVM:<br>
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
  Создаем LVM:<br>
1.**pvcreate /dev/sdb/**<br>
2.**vgcreate vg_root /dev/sdb**<br>
3.**lvcreate -n lv_root -l +100%FREE /dev/vg_root**<br>
  На логической группе разварачиваем файловую систему:<br>
**mkfs.xfs /dev/vg_root/lv_root**<br>
  Просмотрим информацию о LVM:<br>
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
  Смонтируем логическую группу в /mnt:<br>
**sudo mount /dev/vg_root/lv_root /mnt**<br>
  Разворачиваем копию логической группы, на которой в настоящее время находится корневой раздел во временную логическую группу.<br> 
**xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt**<br>
  Монтируем перечисленные папки в каталог /mnt, сохраняя исходную точку монтирования:<br>
**for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done**
  Меняем корневой каталог диска для запущенного процесса и его дочерних процессов.<br>
  Программа, запущенная в таком окружении, не может получить доступ к файлам вне нового корневого каталога.<br>
**chroot /mnt/**<br>
  Сгенерируем новый конфигурационный файл для grub:<br>
**grub2-mkconfig -o /boot/grub2/grub.cfg**<br>
Обновляем образ initrd, временной файловой системы, используемой ядром Linux при начальной загрузке. <br>
**cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done**<br>
  Изменим в конфигурационном файле grub загрузку с *VolGroup00/LogVol00* на *vg_root/lv_root*:<br>
**vi /boot/grub2/grub.cfg**<br>
  Перезагружаем систему, перед перезагрузкой нужно выйти из окружения *chroot jail*:<br>
1. **exit**<br>
2. **reboot**<br>
  Во вновь запущенной системе просмотрим, что получилось:<br>
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
  Удаляем изначальную логическую группу с корневой системой:<br>
**lvremove /dev/VolGroup00/LogVol00**<br>
  Создаем заново логическую группу, в которой хранилась система, с новым размером:<br>
**vcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00**<br>
   На логической группе разварачиваем файловую систему:<br>
**mkfs.xfs /dev/VolGroup00/LogVol00**<br>
   Смонтируем логическую группу в /mnt:<br>
**sudo mount /dev/VolGroup00/LogVol00 /mnt**<br>
  Разворачиваем копию логической группы, на которой в настоящее время находится корневой раздел в исходную логическую группу.<br>
**xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt**<br>
  Монтируем перечисленные папки в каталог /mnt, сохраняя исходную точку монтирования:<br>
**for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done**<br>
  Меняем корневой каталог диска для запущенного процесса и его дочерних процессов.<br>
  Программа, запущенная в таком окружении, не может получить доступ к файлам вне нового корневого каталога.<br>
**chroot /mnt/**<br>
  Сгенерируем новый конфигурационный файл для grub:<br>
**grub2-mkconfig -o /boot/grub2/grub.cfg**<br>
  Обновляем образ initrd, временной файловой системы, используемой ядром Linux при начальной загрузке. <br>
**cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done**<br>
  Смотрим результат уменьшения раздела root:<br>
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
[root@lvm boot]# pvcreate /dev/sde /dev/sdd
  Physical volume "/dev/sde" successfully created.
  Physical volume "/dev/sdd" successfully created.
[root@lvm boot]# vgcreate vg_var /dev/sde /dev/sdd
  Volume group "vg_var" successfully created
[root@lvm boot]#  lvcreate -L 950M -m1 -n lv_var vg_var
  Rounding up size to full physical extent 952.00 MiB
  Logical volume "lv_var" created.
[root@lvm boot]# mkfs.ext4 /dev/vg_var/lv_var
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
60928 inodes, 243712 blocks
12185 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=249561088
8 block groups
32768 blocks per group, 32768 fragments per group
7616 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

[root@lvm vagrant]#
[root@lvm boot]# sudo  mount /dev/vg_var/lv_var /mnt
mount: /dev/mapper/vg_var-lv_var is already mounted or /mnt busy
       /dev/mapper/vg_var-lv_var is already mounted on /mnt
[root@lvm boot]# cp -aR /var/* /mnt/ # rsync -avHPSAX /var/ /mnt/
[root@lvm boot]#
[root@lvm boot]# sudo umount /mnt
[root@lvm boot]# sudo mount /dev/vg_var/lv_var /var
[root@lvm boot]# echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
[root@lvm boot]# cat /etc/fstab
#
# /etc/fstab
# Created by anaconda on Sat May 12 18:50:26 2018
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/VolGroup00-LogVol00 /                       xfs     defaults        0 0
UUID=570897ca-e759-4c81-90cf-389da6eee4cc /boot                   xfs     defaults        0 0
/dev/mapper/VolGroup00-LogVol01 swap                    swap    defaults        0 0
#VAGRANT-BEGIN
# The contents below are automatically generated by Vagrant. Do not modify.
#VAGRANT-END
UUID="578ea5e7-8e24-4246-a805-06d01746612b" /var ext4 defaults 0 0
[root@lvm boot]# exit
exit
[root@lvm vagrant]# reboot
Connection to 127.0.0.1 closed by remote host.
Connection to 127.0.0.1 closed.

n:\Linux ot\work_3_LVM>vagrant ssh
Last login: Wed Jun  1 17:31:35 2022 from 10.0.2.2
[vagrant@lvm ~]$ lsblk
NAME                     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                        8:0    0   40G  0 disk
├─sda1                     8:1    0    1M  0 part
├─sda2                     8:2    0    1G  0 part /boot
└─sda3                     8:3    0   39G  0 part
  ├─VolGroup00-LogVol00  253:0    0    8G  0 lvm  /
  └─VolGroup00-LogVol01  253:1    0  1.5G  0 lvm  [SWAP]
sdb                        8:16   0   10G  0 disk
└─vg_root-lv_root        253:2    0   10G  0 lvm
sdc                        8:32   0    2G  0 disk
sdd                        8:48   0    1G  0 disk
├─vg_var-lv_var_rmeta_1  253:5    0    4M  0 lvm
│ └─vg_var-lv_var        253:7    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_1 253:6    0  952M  0 lvm
  └─vg_var-lv_var        253:7    0  952M  0 lvm  /var
sde                        8:64   0    1G  0 disk
├─vg_var-lv_var_rmeta_0  253:3    0    4M  0 lvm
│ └─vg_var-lv_var        253:7    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_0 253:4    0  952M  0 lvm
  └─vg_var-lv_var        253:7    0  952M  0 lvm  /var
[vagrant@lvm ~]$ 
[vagrant@lvm ~]$ sudo su
[root@lvm vagrant]#  lvremove /dev/vg_root/lv_root
Do you really want to remove active logical volume vg_root/lv_root? [y/n]: y
  Logical volume "lv_root" successfully removed
[root@lvm vagrant]# vgremove /dev/vg_root
  Volume group "vg_root" successfully removed
[root@lvm vagrant]# pvremove /dev/sdb
  Labels on physical volume "/dev/sdb" successfully wiped.
[root@lvm vagrant]#
[root@lvm vagrant]# lvscan
  ACTIVE            '/dev/VolGroup00/LogVol01' [1.50 GiB] inherit
  ACTIVE            '/dev/VolGroup00/LogVol00' [8.00 GiB] inherit
  ACTIVE            '/dev/vg_var/lv_var' [952.00 MiB] inherit
[root@lvm vagrant]#
[root@lvm vagrant]# lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
  Logical volume "LogVol_Home" created.
[root@lvm vagrant]#
[root@lvm vagrant]# lvscan
  ACTIVE            '/dev/VolGroup00/LogVol01' [1.50 GiB] inherit
  ACTIVE            '/dev/VolGroup00/LogVol00' [8.00 GiB] inherit
  ACTIVE            '/dev/VolGroup00/LogVol_Home' [2.00 GiB] inherit
  ACTIVE            '/dev/vg_var/lv_var' [952.00 MiB] inherit
[root@lvm vagrant]#
[root@lvm vagrant]# mkfs.xfs /dev/VolGroup00/LogVol_Home
meta-data=/dev/VolGroup00/LogVol_Home isize=512    agcount=4, agsize=131072 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=524288, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@lvm vagrant]#
[root@lvm vagrant]# sudo mount /dev/VolGroup00/LogVol_Home /mnt/
[root@lvm vagrant]# cp -aR /home/* /mnt/
[root@lvm vagrant]# ls /mnt
vagrant
[root@lvm vagrant]#  rm -rf /home/*
[root@lvm vagrant]# ls /home
[root@lvm vagrant]# sudo umount /mnt
[root@lvm vagrant]# sudo mount /dev/VolGroup00/LogVol_Home /home/
[root@lvm vagrant]# ls /home
vagrant
[root@lvm vagrant]#  echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
[root@lvm vagrant]# cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Sat May 12 18:50:26 2018
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/VolGroup00-LogVol00 /                       xfs     defaults        0 0
UUID=570897ca-e759-4c81-90cf-389da6eee4cc /boot                   xfs     defaults        0 0
/dev/mapper/VolGroup00-LogVol01 swap                    swap    defaults        0 0
#VAGRANT-BEGIN
# The contents below are automatically generated by Vagrant. Do not modify.
#VAGRANT-END
UUID="578ea5e7-8e24-4246-a805-06d01746612b" /var ext4 defaults 0 0
UUID="b1738ca5-22f3-42df-addf-9b7f3ecbaf8e" /home xfs defaults 0 0
[root@lvm vagrant]#
[root@lvm vagrant]# lsblk
NAME                       MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                          8:0    0   40G  0 disk
├─sda1                       8:1    0    1M  0 part
├─sda2                       8:2    0    1G  0 part /boot
└─sda3                       8:3    0   39G  0 part
  ├─VolGroup00-LogVol00    253:0    0    8G  0 lvm  /
  ├─VolGroup00-LogVol01    253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol_Home 253:2    0    2G  0 lvm  /home
sdb                          8:16   0   10G  0 disk
sdc                          8:32   0    2G  0 disk
sdd                          8:48   0    1G  0 disk
├─vg_var-lv_var_rmeta_1    253:5    0    4M  0 lvm
│ └─vg_var-lv_var          253:7    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_1   253:6    0  952M  0 lvm
  └─vg_var-lv_var          253:7    0  952M  0 lvm  /var
sde                          8:64   0    1G  0 disk
├─vg_var-lv_var_rmeta_0    253:3    0    4M  0 lvm
[root@lvm vagrant]#
[root@lvm vagrant]# ge_0   253:4    0  952M  0 lvm
[root@lvm vagrant]#        253:7    0  952M  0 lvm  /var
[root@lvm vagrant]#
[root@lvm vagrant]#
[root@lvm vagrant]#  touch /home/file{1..20}
[root@lvm vagrant]# ls /home
file1   file11  file13  file15  file17  file19  file20  file4  file6  file8  vagrant
file10  file12  file14  file16  file18  file2   file3   file5  file7  file9
[root@lvm vagrant]#
[root@lvm vagrant]#  lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
  Rounding up size to full physical extent 128.00 MiB
  Logical volume "home_snap" created.
[root@lvm vagrant]# rm -f /home/file{11..20}
[root@lvm vagrant]# ls /home
file1  file10  file2  file3  file4  file5  file6  file7  file8  file9  vagrant
[root@lvm vagrant]#
[root@lvm vagrant]#
[root@lvm vagrant]# sudo umount /home
[root@lvm vagrant]#  lvconvert --merge /dev/VolGroup00/home_snap
  Merging of volume VolGroup00/home_snap started.
  VolGroup00/LogVol_Home: Merged: 100.00%
[root@lvm vagrant]#
[root@lvm vagrant]# sudo mount /home
[root@lvm vagrant]# ls /home
file1   file11  file13  file15  file17  file19  file20  file4  file6  file8  vagrant
file10  file12  file14  file16  file18  file2   file3   file5  file7  file9
[root@lvm vagrant]# exit
exit
[vagrant@lvm ~]$ exit
logout
Connection to 127.0.0.1 closed.
