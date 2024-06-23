1. Скорируем гитхаб с настроенным Prometheus, node-exporter, grafana...<br>
 git clone https://github.com/vegasbrianc/prometheus.git <br>
 ![git clone](images/1clone%20git.png)<br>
2. запускаем docker<br>
 *sudo systemctl start docker*<br>
3. запускаем docker compose<br>
 *docker compose up*<br>
![docker](images/2docker%20compose.png)<br> 
 4. Проверяем работу контейнеров:
 Prometheus - ![Prometheus](images/3page%20prometheus.png)<br> 
 Node-exporter- ![Node-exporter](images/5node%20exporter.png)<br> 
 cAdviser- ![cAdviser](images/4cAviser.png)<br>  
5. Собственный Dashboard <br>
![Dashboard](images/dashboard.png)<br>

