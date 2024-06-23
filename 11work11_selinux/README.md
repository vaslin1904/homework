# **Задание 1:**
## **Запустить nginx на нестандартном порту 3-мя разными способами:**
- переключатели setsebool;
- добавление нестандартного порта в имеющийся тип;
- формирование и установка модуля SELinux.
____________________________________________________________-
## **Выполнение Задания 1**
1. Проверим, что в ОС отключен файервол: <br>
**systemctl status firewalld**

![img](images/1status%20firewall.png)

2. Проверим, что конфигурация nginx настроена без ошибок: <br>
**nginx -t**

![img](images/2check%20nginx.png)

3. Проверим режим работы SELinux: <br>
 **getenforce**
 
 ![img](images/3check%20selinux.png) <br>

SELinux будет блокировать запрещенную активность
### **1 способ**
##### *Разрешим в SELinux работу nginx на порту TCP 4881 c помощью переключателей setsebool* 
1. Установим утилиту audit2why для просмотра логов <br>
**yum install policycoreutils-python**
2. Определяем время создания лога /var/log/audit/audit.log<br>
**cat /var/log/audit/audit.log**

![img](images/4time%20log.png)

4. Смотрим информацию о блокировании порта <br>
**grep nginx /var/log/audit/audit.log | audit2why**<br>
![img](images/5%20log.png)
Система сообщает, что параметр nis_enabled не корректен. 
5. Включим параметр nis_enabled и перезапустим nginx<br>
**setsebool -P nis_enabled on**<br>
**systemctl restart nginx**<br>
**systemctl status nginx**<br>
![img](images/6setsebool.png)
6. Проверить статус параметра можно с помощью команды <br>
**getsebool -a | grep nis_enabled**<br>
Для выполнения задания 2-м способом вернем параметр nis_enabled <br>
в первоначальное состояние <br>
**setsebool -P nis_enabled off**<br>
### **2 Способ**
#### *Разрешим в SELinux работу nginx на порту TCP 4881 c помощью добавления <br> нестандартного порта в имеющийся тип*
1. Поиск имеющегося типа, для http трафика <br>
**semanage port -l | grep http**<br>
![img](images/8%20semanage%20port.png)<br>
2. Добавим порт в тип http_port_t 4881 <br>
**emanage port -a -t http_port_t -p tcp 4881**<br>
![img](images/9%20hhtpt%20port%204881.png)<br>
3. Перезапустим службу nginx и проверим её работу <br>
**systemctl restart nginx && systemctl status nginx** <br>
![img](images/10%20nginx%20active.png)<br>
Для выполнения задания 3-м способом удалим нестандартный порт из имеющегося типа <br>
**semanage port -d -t http_port_t -p tcp 4881**
### **3 Способ**
#### **Разрешим в SELinux работу nginx на порту TCP 4881 c помощью формирования и установки модуля SELinux:**
1. Посмотрим логи SELinux, которые относятся к nginx <br>
**grep nginx /var/log/audit/audit.log** <br>
![img](images/11audit.log%20nginx.png)<br>
   Воспользуемся утилитой audit2allow для того, чтобы на основе логов SELinux сделать модуль, разрешающий работу nginx на нестандартном порту:<br>
**grep nginx /var/log/audit/audit.log | audit2allow -M nginx** <br>
2.  Audit2allow сформировал модуль, и сообщил нам команду, с помощью которой можно применить данный модуль: <br>
**semodule -i nginx.pp** <br>
![img](images/12%20audit2allow.png)<br>
3.  Запускаем и проверяем  nginx <br>
**systemctl start nginx && systemctl status nginx** <br>
![img](images/12semodule%20nginx.png) <br>
  После добавления модуля nginx запустился без ошибок. При использовании модуля изменения сохранятся после перезагрузки. <br>
 Просмотр всех установленных модулей: <br>
 **semodule -l**<br>
 Для удаления модуля воспользуемся командой:<br>
 **semodule -r nginx**<br>


