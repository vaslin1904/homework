# **Обновление ядра в системе**
______________________________________
## Программное обеспечение, используемое для выполнение работы
Домашняя система - ОС Windows 11
Vagrant     - 2.2.19
Packer      - 1.8.0
client GIT  - 2.36.0
Virtual Box - 6.1
Виртуальная система - centos 7
Командная строка Windows
______________________________________
## 1 часть. Обновление ядра.
- На платформе GIT HUB был склонирован готовый репозиторий
dmitry-lyutenko/manual_kernel_update.
Ссылка на склонированный образ:<br>
 <https://github.com/vaslin1904/kernel_update.git>.
- Клонируем удаленный репозиторий на локальную машину:<br>
 **git clone https://github.com/vaslin1904/kernel_update.git**.
  *Команда выполняется из директории где будет размещаться
 *локальный репозиторий.*
- Из директории установки Vagrant запускаем его.
- Запускаем виртуальную машину в директории с VagrantFile и логинимся:
   vagrant up
   vagrant ssh
- Смотрим версию ядра системы: [vagrant@kernel-update ~]$ **uname -r**.
Результат: 3.10.0-1127.el7.x86_64
- Подключаем репозиторий, откуда возьмем необходимую версию ядра:
**sudo yum install -y http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm**
- Включаем репозиторий и ставим последнее ядро:
**sudo yum --enablerepo elrepo-kernel install kernel-ml -y**
- Выполняем перезагрузку системы: **sudo reboot**
- Обновляем конфигурацию загрузчика:
 **sudo grub2-mkconfig -o /boot/grub2/grub.cfg**
- Выбираем загрузку с новым ядром по-умолчанию:
 **sudo grub2-set-default 0**
 - Перезагружаем виртуальную машину.
 - Проверяем результат обновления ядра: **uname -r**.
Результат: *5.17.5-1.el7.elrepo.x86_64*.
__________________________________________________
## 2 часть. Создание \*.box системы с помощью Packer.
- Для корректной работы Packer, исключения ошибки не загрузки образа с интернет ресурса<br>
и исключения ошибки не получения прав пользователем vagrant на исполнение команд под sudo<br>
выполним редактирование файла centos.json и файла /http/vagrant.ks.
**centos.json**: выставляем параметр **"iso_checksum": 
                  "sha256:07b94e6b1a0b0260b94c83d6bb76b26bf7a310dc78d7a9c7432809fb9bc6194a"**.<br>
**vagrant.ks**.
1. комментируем строки: 
\# Add vagrant to sudoers
\# cat > /etc/sudoers.d/vagrant << EOF_sudoers_vagrant
\# vagrant        ALL=(ALL)       NOPASSWD: ALL
\# EOF_sudoers_vagrant.
2.Добавляем строку:
**echo "vagrant ALL=(ALL) NOPASSWD:ALL">/etc/sudoers.d/vagrant**.
- Переходим в директорию Packer и запускаем команду:
                      **packer build centos.json**.
-В результе выполнения Packer получаем образ системы:
*centos-7-5 centos-7.7.1908-kernel-5-x86_64-Minimal.box*.
- Проверяем его работоспособность, а также версию ядра:
vagrant ini
vagrant up
uname -r
- подсоединемся к облаку vagrant:**vagrant cloud auth login **.
- Размещает в облаке Vagrant свой box^ 
**vagrant cloud publish release kaa/centos-7-5 1.0 virtuskbox "N:\Linux\Git repo\kernel_update
\packer\centos-7.7.1998-kelnelx-86_64-Minimal.box"**.
Размещаем vagrantFile с облака в директорию box.
Проверяем работу с Vagrant/
Образ скачивается, VagrantFile -рабочий, все ок.
Получаем систему с ядром.
