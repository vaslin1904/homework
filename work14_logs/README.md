# Описание домашнего задания
1. В Vagrant разворачиваются 2 виртуальные машины web и log. </br>
2. На web настраиваем nginx.</br>
3. Наlog настраиваем центральный лог сервер на любой системе на выбор:</br>
- journald;</br>
- rsyslog;</br>
- elk.</br>
4. Настраиваем аудит, следящий за изменением конфигов nginx.</br>
Все критичные логи с web должны собираться и локально и удаленно.</br>
Все логи с nginx должны уходить на удаленный сервер (локально только критичные).</br>
Логи аудита должны также уходить на удаленную систему.</br>
_______________________________________________________________________________
# Выполнение задания
### Настройка времени
Для правильной работы c логами, нужно, чтобы на всех хостах было настроено одинаковое время.</br>
Укажем часовой пояс (Московское время):</br>
**cp/usr/share/zoneinfo/Europe/Moscow /etc/localtime**</br>
Перезупустим службу NTP Chrony: </br>
**systemctl restart chronyd**</br>
Проверим, что служба работает корректно: </br>
**systemctl status chronyd**</br>
![img](images/1%20setup%20time.png)</br>
### Установка nginx на виртуальной машине web
Для установки nginx сначала нужно установить epel-release: </br>
**yum install epel-release**</br>
Установим nginx: </br>
**yum install -y nginx**</br>
![img](images/2web_nginx.png)</br>
### Настройка центрального сервера сбора логов ntp</br>
rsyslog должен быть установлен по умолчанию в нашёй ОС, проверим это:</br>
**yum list rsyslog**</br>
![img](images/3log_check%20rsyslog.png)</br>
Все настройки Rsyslog хранятся в файле /etc/rsyslog.conf</br>
Для того, чтобы наш сервер мог принимать логи, нам необходимо внести следующие изменения в файл:</br>
### Открываем порт 514 (TCP и UDP):</br>
В конец файла /etc/rsyslog.conf добавляем правила приёма сообщений от хостов:</br>
**$template RemoteLogs,"/var/log/rsyslog/%HOSTNAME%/%PROGRAMNAME%.log"</br>
*.* ?RemoteLogs</br>
& ~**</br>
Далее сохраняем файл и перезапускаем службу rsyslog:</br>
 **systemctl restart rsyslog**</br>
Проверяем настройки: будут видны открытые порты TCP,UDP 514:</br>
 ss -tuln</br>
 ![img](images/6%20log_check%20port%20514.png)</br>
 ### Настроим отправку логов с web-сервера</br>
 Версия nginx должна быть 1.7 или выше. </br>
 **rpm -qa | grep nginx**</br>
  У нас nginx-1.20.1-10.el7.x86_64</br>
 Находим в файле /etc/nginx/nginx.conf раздел с логами и приводим их к следующему виду:</br>
*error_log /var/log/nginx/error.log;*</br>
*error_log syslog:server=192.168.56.15:514,tag=nginx_error;*</br>
*access_log syslog:server=192.168.56.15:514,tag=nginx_access,severity=info combined;*</br>
![img](images/7%20web%20_nginx.conf.png)</br>
Для Access-логов указываем удаленный сервер и уровень логов, которые нужно отправлять. Для</br>
error_log добавляем удаленный сервер. Если требуется чтобы логи хранились локально и отправлялись</br>
на удаленный сервер, требуется указать 2 строки.</br>
Tag нужен для того, чтобы логи записывались в разные файлы.</br>
По умолчанию, error-логи отправляют логи, которые имеют severity: error, crit, alert и emerg.</br>
Далее проверяем, что конфигурация nginx указана правильно: </br>
**nginx -t**</br>
![img](images/8%20web_check%20nginx.png)</br>
Чтобы проверить, что логи ошибок также улетают на удаленный сервер, можно удалить картинку, к</br>
которой будет обращаться nginx во время открытия веб-сраницы:</br>
**rm /usr/share/nginx/html/img/header-background.png**</br>
Попробуем несколько раз зайти по адресу http://192.168.56.10</br>
![img](images/9%20log_nginx%20logs.png)</br>
Видим, что логи отправляются корректно.</br>
### Настройка аудита, контролирующего изменения конфигурации nginx</br>
-Проверим  пред установку утилиты auditd:</br>
 **rpm -qa | grep audit**</br>
 --audit-2.8.5-4.el7.x86_64</br>
--audit-libs-2.8.5-4.el7.x86_64</br>
### Настроим аудит изменения конфигурации nginx:</br>
Добавим правило, которое будет отслеживать изменения в конфигруации nginx. Для этого в конец</br>
файла /etc/audit/rules.d/audit.rules добавим следующие строки:</br>
*-w /etc/nginx/nginx.conf -p wa -k nginx_conf*</br>
*-w /etc/nginx/default.d/ -p wa -k nginx_conf*</br>
Данные правила позволяют контролировать запись (w) и измения атрибутов (a) в:</br>
● /etc/nginx/nginx.conf</br>
● Всех файлов каталога /etc/nginx/default.d/</br>
Для более удобного поиска к событиям добавляется метка nginx_conf</br>
Перезапускаем службу auditd:</br>
 **service auditd restart**</br>
 После данных изменений у нас начнут локально записываться логи аудита. Чтобы проверить, что</br>
логи аудита начали записываться локально, нужно внести изменения в файл /etc/nginx/nginx.conf</br>
или поменять его атрибут, потом посмотреть информацию об изменениях:</br>
**ausearch -f /etc/nginx/nginx.conf**</br>

Также можно воспользоваться поиском по файлу /var/log/audit/audit.log, указав наш тэг:</br>
**grep nginx_conf /var/log/audit/audit.log**</br>

### Далее настроим пересылку логов на удаленный сервер.</br>
Auditd по умолчанию не умеет пересылать логи, для пересылки на web-сервере потребуется установить пакет audispd-plugins:</br>
 **yum -y install audispd-plugins**</br>
Найдем и поменяем следующие строки в файле /etc/audit/auditd.conf:</br>
![img](images/12%20web_auditd.conf.png)</br>
В файле /etc/audisp/plugins.d/au-remote.conf поменяем параметр active на yes:</br>
![img](images/13%20web_au_remove.conf.png)</br>
В файле /etc/audisp/audisp-remote.conf требуется указать адрес сервера и порт, на который будут</br>
отправляться логи:</br>
![img](images/14%20web%20audisp_remote.conf.png)</br>
Далее перезапускаем службу auditd: </br>
**service auditd restart**</br>
### Настроим Log-сервер.</br>
Откроем порт TCP 60, для этого уберем значки комментария в файле /etc/audit/auditd.conf:</br>
![img](images/15%20log_auditd.conf.png)</br>
Перезапускаем службу auditd:</br>
**service auditd restart**</br>
## Результат</br>
На этом настройка пересылки логов аудита закончена. Можем попробовать поменять атрибут у файла</br>
/etc/nginx/nginx.conf и проверить на log-сервере, что пришла информация об изменении атрибута:</br>
**ls -l /etc/nginx/nginx.conf**</br>
**chmod +x /etc/nginx/nginx.conf**</br>
![img](16%20web_change%20atribut.png) </br>
проверить на log-сервере, что пришла информация об изменении атрибута</br>
**grep web /var/log/audit/audit.log**</br>
![img](images/17%20log_chancge%20atribut%20logs.png) </br>
## Итог
Весь процесс настроек логов автоматизирован с помощью ансибл.</br>
