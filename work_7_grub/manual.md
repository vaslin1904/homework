# **Работа с загрузчиком GRUB**
___________________________________________
## **Зайти в систему через загрузчик**
___________________________________________
1. Для того, чтобы попасть в загрузчик системы при ее загрузке, необходимо нажать "e"(edit) при появлении окна выбора ядра системы:
![Редактирование Grub во время загрузки](/images/way1.png)
2. Устанавливаем нужные пакеты для работы с репозиторием и rpm пакетами:
- yum install -y \redhat-lsb-core \wget \rpmdevtools \rpm-build \createrepo \yum-utils \gcc \lynx
3. Загружаем пакет nginx:
- wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
4. Устанавливаем скаченный пакет nginx: 
- rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
5. Скачиваем исходники openssl:
- wget --no-check-certificate https://www.openssl.org/source/openssl-1.1.1o.tar.gz
6. Распакуем скаченный архив в текущий каталог : 
- tar -xvf /home/vagrant/openssl-1.1.1o.tar.gz
7. Поставим все необходимые зависимости:
- yum-builddep rpmbuild/SPECS/nginx.spec
8. Отредактируем файл nginx.spec - укажем путь  до openssl: **--with-openssl=/root/openssl-1.1.1o**
- sed '/--with-debug/ i --with-openssl=/root/openssl-1.1.1o \\' /root/rpmbuild/SPECS/nginx.spec
9. Выполняем сборку rpm пакета: 
- rpmbuild -bb rpmbuild/SPECS/nginx.spec
______________________________________________
## **Создание своего репозитория**
______________________________________________
1. Установим пакет nginx:  
- yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
2. Запускаем nginx и проверяем его работу:
- systemctl start nginx
- systemctl status nginx
3. Создадим каталог repo в каталоге по умолчанию для статики nginx /usr/share/nginx/html:
- mkdir /usr/share/nginx/html/repo
4. Копируем репозиторий nginx-1.14.1-1.el7_4.ngx.x86_64.rpm: 
- cp nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
5. Скачаем еще один пакет rpm в наш репозиторий:
- wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -O /usr/share/nginx/html/repo/repcona-release-0.1-noarch.rpm
6. Инициализируем репозиторий командой:
- createrepo /usr/share/nginx/html/repo/
7. Настроим в NGINX доступ к листингу каталога в файле /etc/nginx/conf.d/default.conf и блоке location: 
- sed -i '10 a \\tautoindex on;' /etc/nginx/conf.d/default.conf
8. Проверāем синтаксис и перезапускаем NGINX:
- nginx -t
- nginx -s reload
9. Проверить доступ к списку к репозиторию можно командами:
- lynx http://localhost/repo
- curl -a http://localhost/repo/
10. Добавим репозиторий в /etc/yum.repos.d:
- cat>>/etc/yum.repos.d/otus.repo<<EOF
> [otus]
> name=otus-linux
> baseurl=http://localhost/repo
> gpgcheck=0
> enabled=1
> EOF                                
11. Проверяем подключение к репозиторию:
- yum repolist enabled|grep otus
- yum list|grep otus
12. Установим из репозитория пакет percona-release:
-  yum install percona-release -y 
13. Репозиторий работает. 
____________________________________________
## **Вывод**
_____________________________________________
Все шаги по сборке пакета rpm и созданию своего репозитория развернуты в скрипте **script.sh**.
Скрипт добавлен в файл Vagrant на исполнение при запуске.


