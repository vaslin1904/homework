# **Задание 2:**
## **Обеспечение работоспособности приложения при включенном SELinux:**

____________________________________________________________-
1. Подключимся к клиенту <br>
**systemctl status firewalld**
2. Попробуем внести изменения в зону: nsupdate -k /etc/named.zonetransfer.key <br>
**nsupdate -k /etc/named.zonetransfer.key**
![img](images/part2/1%20change%20nsupdate%20.png)
3. Псмотрим логи SELinux, чтобы понять в чём может быть проблема <br>
 **cat /var/log/audit/audit.log | audit2why**
 Лог пустой!!!
4 Не закрывая сессию на клиенте, подключимся к серверу ns01 и проверим логи SELinux: <br>
**vagrant ssh ns01**<br>
**cat /var/log/audit/audit.log | audit2why**<br>
![img](images/part2/2ns1%20log.png) <br>
В логах мы видим, что ошибка в контексте безопасности. Вместо типа named_t используется тип etc_t
5. Проверим данную проблему в каталоге /etc/named: <br>
**ls -laZ /etc/named** <br>
![img](images/part2/3%20contex%20etc_named.png) 

Тут мы также видим, что контекст безопасности неправильный.<br>
Проблема заключается в том, что конфигурационные файлы лежат в другом каталоге. Посмотреть в каком каталоги должны лежать, файлы, чтобы на них распространялись правильные политики SELinux можно с помощью команды:<br>
**sudo semanage fcontext -l | grep named** <br>
![img](images/part2/4%20grep%20named.png) <br>
6. Изменим тип контекста безопасности для каталога /etc/named:<br>
**sudo chcon -R -t named_zone_t /etc/named**<br>
![img](images/part2/5change%20type%20contex.png)
7. Попробуем снова внести изменения с клиента: <br>
**nsupdate -k /etc/named.zonetransfer.key**<br>
> server 192.168.50.10<br>
> zone ddns.lab<br>
> update add www.ddns.lab. 60 A 192.168.50.15<br>
> send<br>
> quit<br>
-dig www.ddns.lab<br>
![img](images/part2/6%20dig%20before%20reboot.png)
8. Попробуем перезагрузить хосты и ещё раз сделать запрос с помощью dig <br>
![img](images/part2/7%20dig%20after%20reboot.png) <br>
___________
Для того, чтобы вернуть правила обратно, можно ввести команду: <br>
**restorecon -v -R /etc/named** <br>
![img](images/part2/8%20reset%20settings.png) <br>
