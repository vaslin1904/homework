#!/bin/bash
yum update -y
yum install -y mailx flock cronie vim wget	
chmod +x /vagrant/scriptotchet.sh
sed -i 's/\r//g' /vagrant/scriptotchet.sh
crontab /etc/crontab
crontab -l | { cat; echo "0 */1 * * * /usr/bin/flock -xn /var/lock/scriptotchet.lock -c 'sh /vagrant/scriptotchet.sh'"; } | crontab -
		