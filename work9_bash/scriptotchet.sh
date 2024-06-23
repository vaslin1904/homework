#!/bin/bash
#Скрипт в файле access.log делает выборку данных во вновь создаваемый файл otchet.log                                  
# и отсылает его на указанный e-mail                                                                                   
#____________________________________________________________________________________#                                 
#
#Проверка существует ли файл otchet.log. Если он существует, то очистить его, иначе создать пустой файл.               
    FILE=otchet.log                                                                                                        
    if [ ! -f "$FILE" ]; then                                                                                              
            echo -en 'Отчет по работе nginx\n\n' >> otchet.log                                                         
#lastrun - время последней модификации файла                                                                           
#launch - Текущее время                                                                                                
            lastrun=$(stat -t --format="%x" otchet.log | cut -d '.' -f1)                                               
            launch=$lastrun                                                                                            
            echo Отчет составляется впервые. Время создания отчета: $launch >> otchet.log                             
            echo $lastrun                                                                                              
    else                                                                                                               
            echo "Файл существует"                                                                                     
            lastrun=$(stat -t --format="%x" otchet.log | cut -d '.' -f1)
#сохраняем предыдущий файл перед внесением изменений			
            sed -i.old -e '2,$d' otchet.log                                                                            
            launch=$(date +'%Y-%m-%d-%H:%M:%S') 
#заполняем файл отчета 			
            echo Последний раз отчет менялся: $lastrun  >> otchet.log                                                   
            echo Текущее время отчета: $launch >> otchet.log                                                           
    fi 
# Так как используется access файл не в режиме реального времени, то переменным назначаются даты для парсинга файла, которые присутствуют в нем.
# Для режима онлайн необходимо убрать назначенные значения и раскомментировать команды.
    lastrun="20190814235026" #$(date +'%Y%m%d%H%M%S')
    launch="20190815000154" #$(date +'%Y%m%d%H%M%S')
#Из файла берутся данные из временного промежутка от lustrun до launch
    awk -F'[[/ :]+' -vawlastrun=$lastrun -vawlaunch=$launch -vmon=$(LC_ALL=C locale abmon) 'BEGIN {for(n=split(mon, M, ";"); n; n--) nM[M[n]] = sprintf("%02d", n)} line = $6nM[$5]$4$7$8$9 line >= awlastrun && line <= awlaunch' access.log > temp.txt
# Выборка ip   адресов
   echo "************************************" >> otchet.log
    echo -en '-------IP адреса, которые обращались к nginx после последнего запуска скрипта-------\n\n' >> otchet.log
    sed -i 's/^ *//g' temp.txt
    cut temp.txt -d ' ' -f1| sort| uniq -c| sort -nr| head -n 5 >> otchet.log
    echo "************************************" >> otchet.log
# Выборка URL адреса с наибольшим кол-вом запросов  
	echo -en "-------URL адреса с наибольшим кол-вом запросов-------\n\n" >> otchet.log
    echo -e "\n"
    cut temp.txt -d ' ' -f7| sort| uniq -c| sort -nr| head -n 5 >> otchet.log
    echo "************************************" >> otchet.log
# Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта
    echo -en "-------Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта-----\n\n" >> otchet.log
    awk '{print $9}' temp.txt | sort | uniq -c | sort -rn >> otchet.log
#Выборка ошибок веб-сервера/приложения c момента последнего запуска
    echo "************************************" >> otchet.log
    echo -en "-------Ошибки веб-сервера/приложения c момента последнего запуска-----\n\n" >> otchet.log
    awk '{if ($9 >= 404 && $9 <= 499 || $9 >= 500 && $9 <= 510) print $9}' temp.txt | sort | uniq -c | sort -rn >> otchet.log
    rm temp.txt
# Отправка почты на временный адрес почты
echo "Отчет за $(date)" | mailx -s "Обработка файла access.log" -a /vagrant/otchet.log otusgalkina@yandex.ru
