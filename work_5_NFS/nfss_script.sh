#Настройка сервера
sudo sudo
yum install -y nfs-utils
systemctl enable firewalld --now
firewall-cmd --permanent --add-service="nfs"
firewall-cmd --permanent --add-service="nfs3"
firewall-cmd --permanent --add-service="rpc-bind"
firewall-cmd  --permanent  --add-service="mountd"
firewall-cmd --reload
systemctl enable nfs --now
mkdir -p /srv/share/upload
chown -R nfsnobody:nfsnobody /srv/share 
chmod 0777 /srv/share/upload
cat << EOF > /etc/exports
/srv/share 192.168.50.11/32(rw,sync,root_squash)
EOF
exportfs -r
touch /srv/share/upload/check_file2