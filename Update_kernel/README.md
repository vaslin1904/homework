# Обновление ядра системы
__________________________________________
Исходные данные:
- Vagrantfile. Разворачивается виртуальная машина "kernel-update".
cpu 2/ RAM 1024/Ubuntu 22.04
Провижингмашины происходит с помощью ансибл.
- Стенд. 
host машина - Ubuntu 24.04
vagrant --version >> 2.4.1
ansible --version >> core 2.16.3
vboxmanage --version >> 7.0
_________________________________________________________________
##  Описание ansible playbook
* Задача решается с помощью одной роли: roles:- update_kernel
*Последовательность действий и tasks:
1. Выводим на экран версию ядра системы. [Task - read_version] (docs/CONTRIBUTING.md)
С помощью gather_facts = yes собираются факты о ситеме. В частности факт
о версии ядра - var: ansible_kernel.
2. Создается директория, куда будут загружатться файлы нового ядра. Task - Create
path: /home/vagrant/Downloads
3. Загружаются файлы в созданную директорию. Task - Download
Через цикл loop  загружаются файлы из url, указанные в переменной download_pkgs блока vars.
ownload_pkgs:
  - https://kernel.ubuntu.com/mainline/v6.11-rc7/amd64/linux-headers-6.11.0-061100rc7_6.11.0-061100rc7.202409082235_all.deb
  - https://kernel.ubuntu.com/mainline/v6.11-rc7/amd64/linux-image-unsigned-6.11.0-061100rc7-generic_6.11.0-061100rc7.202409082235_amd64.deb
  - https://kernel.ubuntu.com/mainline/v6.11-rc7/amd64/linux-modules-6.11.0-061100rc7-generic_6.11.0-061100rc7.202409082235_amd64.deb
4. Установка скаченных deb пакетов. Task - Install.
5. Перезагрузка гостевой машины. Task - Reboot.
6. Перечитывание версии ядра. Task - read_version

