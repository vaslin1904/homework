# Пользователи и группы. Авторизация и аутентификация.
_______________________________________________________
## Задание 1
Настройка запрета для всех пользователей кроме группы Admin) логина в выходные дни (Праздники не учитываются
**Выполнение**
##### Создаём пользователя otusadm и otus  под  root
  **sudo useradd otusadm && sudo useradd otus**
- Создаём пользователям пароли:
**echo "Otus2022!" | sudo passwd --stdin otusadm && echo "Otus2022!" | sudo passwd --stdin otus** <br>
  ![img](images/1%20add%20users.png)
##### Создаём группу admin
**sudo groupadd -f admin**
- Добавляем пользователей vagrant,root и otusadm в группу admin
**sudo usermod otusadm -a -G admin <br>
  sudo usermod root -a -G admin <br>
  sudo usermod vagrant -a -G admin**<br>
- Проверяем, что otusadm и otus могут подключаться по SSH к нашей ВМ. Для этого пытаемся 
подключиться к хостовой машине
**ssh otus@192.168.57.10 <br>
  ssh otusadm@192.168.57.10**<br>
![img](images/2%20users%20ssh.png)
##### Далее настроим правило, по которому все пользователи <br>
##### кроме тех, что указаны в группе admin не смогут подключаться в выходные дни: <br>
- Проверим, что пользователи root, vagrant и otusadm есть в группе admin:<br>
**cat /etc/group | grep admin**
  ![img](images/3%20check%20admin.png)
#### Создадим файл-скрипт /usr/local/bin/login.sh (используем аутентитфикацию  PAM) <br>
![login.sh ](login.sh)<br>
-Добавим права на исполнение файла <br>
**chmod +x /usr/local/bin/login.sh** <br>
-Укажем в файле /etc/pam.d/sshd модуль pam_exec и наш скрипт: <br>
**vi /etc/pam.d/sshd** <br>
 ![img](images/4%20sshd.png)<br>
-Для проверки установим дату системы на выходной день вручную <br>
**sudo date 082712302022.00** <br>
 ![img](images/5%20itog.png)
