#My repo and nginx
sudo su
yum install -y \redhat-lsb-core \wget \rpmdevtools \rpm-build \createrepo \yum-utils \gcc \lynx
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
cd /root
wget --no-check-certificate https://www.openssl.org/source/openssl-1.1.1o.tar.gz
tar -xvf openssl-1.1.1o.tar.gz
yum-builddep rpmbuild/SPECS/nginx.spec<<EOF
yes
EOF
sed '/--with-debug/ i --with-openssl=/root/openssl-1.1.1o \\' /root/rpmbuild/SPECS/nginx.spec
rpmbuild -bb rpmbuild/SPECS/nginx.spec
yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
systemctl start nginx
mkdir /usr/share/nginx/html/repo
cp rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget https://downloads.percona.com/downloads/percona-release/percona-release-0.1-6/redhat/percona-release-0.1-6.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm
createrepo /usr/share/nginx/html/repo/
sed -i '10 a \\tautoindex on;' /etc/nginx/conf.d/default.conf
nginx -t
nginx -s reload
cat>>/etc/yum.repos.d/otus.repo<<EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
yum install percona-release -y