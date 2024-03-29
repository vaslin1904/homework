
 #**Docker**
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
2. Добавляем репозиторий Docker 
3. Устанавливаем последнюю версию пакетов docker
4. Запускаем docker:
            **sudo systemctl start docker**
5. Проверяем работоспособность docker
            **sudo docker run hello-world**
![Проверка docker](images/1run_docker.png)<br>
            **sudo systemctl status docker**
 ![Статус docker](images/2status_docker.png)<br>           
6. Так как docker запускается под root или под пользователем, входящим в группу docker, то
добавим пользователя vagrant в эту группу:
          **sudo usermod -a -G docker vagrant**
![groups docker](images/3groups.png)<br> 
7. Создаем html файл
8. Запускаем контейнер nginx на базе alpine с подключением volume
   **docker run -d -p 80:80 -v ~/html/://usr/share/nginx/html:rw nginx:alpine**
![alpine docker](images/5 nginx alpine.png)<br>  
9. Обращаемся к nginx с кастомной страницей<br> 
         **curl localhost:8080** <br>
![curl nginx](images/6 curl nginx.png)<br>
______________________________
#### **Создание собственного образа контейнера**
Для создания образа контейнера необходимо создать [dockerfile](Dockerfile)         
 Создаем кастомный образ nginx my_nginx: <br>
 **docker build -t my_nginx**
Смотрим имеющиеся образы docker: <br>
**docker images**
![images](images/9docker_image.png) <br>
Создадаем контейнер из созданного образа <br>
**docker run -it -p 8080:80 --name my_webserver my_nginx** <br>
Запустим контейнер <br>
**docker run -d -p 8080:80 --name my_webserver my_nginx** <br>
Проверяем работу контейнера:
**curl localhost:8080**
![images](images/11work_my_nginx.png) <br>
__________________________________________________
#### **Размещение созданного образа на докер хабе**
1. Залогонимся в докер <br>
**docker login** <br>
2. Пометим изображение: ,br>
**docker image tag my_nginx vaslin/my_nginx:1.0**
![images](images/13tag_image.png) <br>
3. Запушим изображение в репозиторий докер <br>
**docker image push vaslin/my_nginx:1.0**
![images](images/14push.png) <br>
Мой образ: https://hub.docker.com/r/vaslin/my_nginx/tags
Скачать образ: docker pull vaslin/my_nginx:1.0
___________________________________________________
## Ответы на вопросы
_______________________
**1. Определить разницу между контейнером и образом**
Контейнером является среда в которой разворачивается образ, содержащий необходимые ресурсы для запуска приложения (процесса). 
Контейнер является полноценной средой с развернутым образом, в которой образ может подвергаться изменениям.
Образ же является готовым продуктом и по своей сути является неизменяемым шаблоном среды. <br>
**2. Можно ли в контейнере собрать ядро?**
Контейнер использует ядро домашней системы и поэтому внутри него собрать ядро не возможно.
