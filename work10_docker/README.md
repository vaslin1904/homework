
 **Docker**
___________________________________________
## **Задание**
___________________________________________
1. Создать свой кастомный образ nginx на базе alpine. 
2. После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx).
3. Определить разницу между контейнером и образом.
4. Ответить на вопрос: Можно ли в контейнере собрать ядро?
5. Собранный образ необходимо запушить в docker hub и дать ссылку на репозиторий.
_____________________________________________________________________
## **Установка и настройка docker**
_____________________________________________________________________
1. Устанавливаем Пакет YUM-Utils - это набор утилит, реализующих дополнительные возможности для управления <\br> 
репозиториями, установки и отладки пакетов, поиска пакетов и т.д.<\br> 
             **sudo yum install -y yum-utils**
2. Добавляем репозиторий Docker: 

3. Устанавливаем последнюю версию пакетов docker
4. Запускаем docker:
            **sudo systemctl start docker**
5. Проверяем работоспособность docker
            **sudo docker run hello-world**
![Проверка docker](images\1run_docker.png)<br>
            **sudo systemctl status docker**
 ![Статус docker](images\2status_docker.png)<br>           
6. Так как docker запускается под root или под пользователем, входящим в группу docker, то
добавим пользователя vagrant в эту группу:
          **sudo usermod -a -G docker vagrant**
![groups docker](images\3groups.png)<br> 
7. Создаем html файл
8. Запускаем контейнер nginx на базе alpine с подключением volume
   **docker run -d -p 80:80 -v ~/html/://usr/share/nginx/html:rw nginx:alpine**
![alpine docker](images\5 nginx alpine.png)<br>  
9. Обращаемся к nginx с кастомной страницей
         **curl localhost:8080**
![curl nginx](images\6 curl nginx.png)<br>
         


______________________________________________
## **Отправка почтой**
______________________________________________
1. Для отправки почтой отчета, созданного скриптом, понадобился пакет **mailx**<br>
*yum install mailx*<br>
2. Настройка почты была произведена с помощью пакета postfix.<br>
**Настройка postfix на отправку локальных писем через внешний сервер с авторизацией по smtp**<br>
1) Добавляем новые строки в файл настроек *cat /etc/postfix/main.cf*<br>

2) Создаем файл с информацией об имени пользователя и пароле для авторизации. */etc/postfix/sasl_passwd*<br>
![Правка файла sasl_passwd](картинки/2.png)<br>
Указывается почта и пароль для ее авторизации, на которую будет отсылаться файл отчета.<br>
3)Создаем  файл postfix db.<br>
*sudo postmap /etc/postfix/sasl_passwd*<br>
4)Перезапускаем postfix<br>
*sudo postfix reload*<br>
5)Почта отправляет файл отчета на адрес otusgalkina@yandex.ru командой из скрипта<br>
*echo "Отчет за $(date)" | mailx -s "Обработка файла access.log" -a /vagrant/otchet.log otusgalkina@yandex.ru*<br>
______________________________________________
## **Задание CRON**
______________________________________________
https://docs.docker.com/engine/install/

2.Добавляем репозиторий Docker: 
3. Устанавливаем последнюю версию пакетов docker
4. Запускаем docker

5. 
6. 
7. Создаем папку html с файлом не стандартной страницы nginx index.html
8. Запускаем контейнер nginx на базе alpine с подключением volume

docker run -d -p 80:80 -v ~/html/://usr/share/nginx/html:rw nginx:alpine

9. Для создания образа контейнера необходимо создать dockerfile
10. Создаем кастомный образ nginx my_nginx
docker build -t my_nginx .
11. Просмотрим имеющиеся образы
docker images
12.Создадим контейнер из созданного образа
docker run -it -p 8080:80 --name my_webserver my_nginx
13. Запустим контейнер
docker run -d -p 8080:80 --name my_webserver my_nginx
14. Проверим работу контейнера
curl localhost:8080
15. Образ разместить на докер хабе
1. залогинимся в докер
docker login
2.Сначало пометим изображение
docker image tag my_nginx vaslin/my_nginx:1.0
3. Запушим изображение в репозиторий докер
docker image push vaslin/my_nginx:1.0
https://hub.docker.com/r/vaslin/my_nginx/tags
docker pull vaslin/my_nginx:1.0


Удаление контейнеров:
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
Удаление образа
 docker rmi my_nginx
 Запуск в интерактивном режиме 
 docker run -it -p 8080:80 --name webserver my_nginx
 Просмотр всех контейнеров 
 docker ps -a
 
____________________________________________
## **Итог**
Файл отчета отправлен на почту яндекс.<br>
![Итог](картинки/3.png)