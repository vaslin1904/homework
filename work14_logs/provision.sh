#/bin/bash!
#Установка одинакового времени
#Укажем часовой пояс (Московское время):
cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime
#Перезупустим службу NTP Chrony: 
systemctl restart chronyd