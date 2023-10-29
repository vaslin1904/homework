# Описание домашнего задания
1. В Vagrant разворачиваются 2 виртуальные машины web и log.
2. На web настраиваем nginx.
3. Наlog настраиваем центральный лог сервер на любой системе на выбор:
- journald;
- rsyslog;
- elk.
4. Настраиваем аудит, следящий за изменением конфигов nginx.
Все критичные логи с web должны собираться и локально и удаленно.
Все логи с nginx должны уходить на удаленный сервер (локально только критичные).
Логи аудита должны также уходить на удаленную систему.
_______________________________________________________________________________
# Выполнение задания
### Настройка времени
Для правильной работы c логами, нужно, чтобы на всех хостах было настроено одинаковое время.
Укажем часовой пояс (Московское время):
**cp/usr/share/zoneinfo/Europe/Moscow /etc/localtime**
Перезупустим службу NTP Chrony: 
**systemctl restart chronyd**
Проверим, что служба работает корректно: 
**systemctl status chronyd**
![img](images/1%20setup%20time.png)
### Установка nginx на виртуальной машине web
Для установки nginx сначала нужно установить epel-release: 
**yum install epel-release**
Установим nginx: 
**yum install -y nginx**
![img](images/2web_nginx.png)
### Настройка центрального сервера сбора логов ntp
rsyslog должен быть установлен по умолчанию в нашёй ОС, проверим это:
**yum list rsyslog**
![img](images/3log_check%20rsyslog.png)
Все настройки Rsyslog хранятся в файле /etc/rsyslog.conf
Для того, чтобы наш сервер мог принимать логи, нам необходимо внести следующие изменения в файл:
### Открываем порт 514 (TCP и UDP):
В конец файла /etc/rsyslog.conf добавляем правила приёма сообщений от хостов:
**$template RemoteLogs,"/var/log/rsyslog/%HOSTNAME%/%PROGRAMNAME%.log"
*.* ?RemoteLogs
& ~**
Далее сохраняем файл и перезапускаем службу rsyslog:
 **systemctl restart rsyslog**
Проверяем настройки: будут видны открытые порты TCP,UDP 514:
 ss -tuln
 ![img](images/6%20log_check%20port%20514.png)
 ### Настроим отправку логов с web-сервера
 Версия nginx должна быть 1.7 или выше. 
 **rpm -qa | grep nginx**
  У нас nginx-1.20.1-10.el7.x86_64
 Находим в файле /etc/nginx/nginx.conf раздел с логами и приводим их к следующему виду:
*error_log /var/log/nginx/error.log;*
*error_log syslog:server=192.168.56.15:514,tag=nginx_error;*
*access_log syslog:server=192.168.56.15:514,tag=nginx_access,severity=info combined;*
![img](images/7%20web%20_nginx.conf.png)
Для Access-логов указываем удаленный сервер и уровень логов, которые нужно отправлять. Для
error_log добавляем удаленный сервер. Если требуется чтобы логи хранились локально и отправлялись
на удаленный сервер, требуется указать 2 строки.
Tag нужен для того, чтобы логи записывались в разные файлы.
По умолчанию, error-логи отправляют логи, которые имеют severity: error, crit, alert и emerg.
Далее проверяем, что конфигурация nginx указана правильно: 
**nginx -t**
![img](images/8%20web_check%20nginx.png)
Чтобы проверить, что логи ошибок также улетают на удаленный сервер, можно удалить картинку, к
которой будет обращаться nginx во время открытия веб-сраницы:
**rm /usr/share/nginx/html/img/header-background.png**
Попробуем несколько раз зайти по адресу http://192.168.56.10
![img](images/9%20log_nginx%20logs.png)
Видим, что логи отправляются корректно.
### Настройка аудита, контролирующего изменения конфигурации nginx
-Проверим  пред установку утилиты auditd,:
 **rpm -qa | grep audit**
 --audit-2.8.5-4.el7.x86_64
--audit-libs-2.8.5-4.el7.x86_64
### Настроим аудит изменения конфигурации nginx:
Добавим правило, которое будет отслеживать изменения в конфигруации nginx. Для этого в конец
файла /etc/audit/rules.d/audit.rules добавим следующие строки:
*-w /etc/nginx/nginx.conf -p wa -k nginx_conf*
*-w /etc/nginx/default.d/ -p wa -k nginx_conf*
Данные правила позволяют контролировать запись (w) и измения атрибутов (a) в:
● /etc/nginx/nginx.conf
● Всех файлов каталога /etc/nginx/default.d/
Для более удобного поиска к событиям добавляется метка nginx_conf
Перезапускаем службу auditd:
 **service auditd restart**
 После данных изменений у нас начнут локально записываться логи аудита. Чтобы проверить, что
логи аудита начали записываться локально, нужно внести изменения в файл /etc/nginx/nginx.conf
или поменять его атрибут, потом посмотреть информацию об изменениях:
**ausearch -f /etc/nginx/nginx.conf**

Также можно воспользоваться поиском по файлу /var/log/audit/audit.log, указав наш тэг:
**grep nginx_conf /var/log/audit/audit.log**

### Далее настроим пересылку логов на удаленный сервер.
Auditd по умолчанию не умеет пересылать логи, для пересылки на web-сервере потребуется установить пакет audispd-plugins:
 **yum -y install audispd-plugins**
Найдем и поменяем следующие строки в файле /etc/audit/auditd.conf:
![img](images/12%20web_auditd.conf.png)
В файле /etc/audisp/plugins.d/au-remote.conf поменяем параметр active на yes:
![img](images/13%20web_au_remove.conf.png)
В файле /etc/audisp/audisp-remote.conf требуется указать адрес сервера и порт, на который будут
отправляться логи:
![img](images/14%20web%20audisp_remote.conf.png)
Далее перезапускаем службу auditd: 
**service auditd restart**
### Настроим Log-сервер.
Откроем порт TCP 60, для этого уберем значки комментария в файле /etc/audit/auditd.conf:
![img](images/15%20log_auditd.conf.png)
Перезапускаем службу auditd:
**service auditd restart**
## Результат
На этом настройка пересылки логов аудита закончена. Можем попробовать поменять атрибут у файла
/etc/nginx/nginx.conf и проверить на log-сервере, что пришла информация об изменении атрибута:
**ls -l /etc/nginx/nginx.conf**
**chmod +x /etc/nginx/nginx.conf**
![img](16%20web_change%20atribut.png)
проверить на log-сервере, что пришла информация об изменении атрибута
**grep web /var/log/audit/audit.log**
![img](images/17%20log_chancge%20atribut%20logs.png)
## Итог
Весь процесс настроек логов автоматизирован с пощью ансибл.
