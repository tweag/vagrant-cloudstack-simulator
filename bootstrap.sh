#!/bin/bash -ex

source_dir=/tmp/cloudstack-simulator
destination_dir=/root
cloudstack_dir=$destination_dir/cloudstack

# Dependencies
yum install git wget -y
rpm -i http://mirror.metrocast.net/fedora/epel/6/i386/epel-release-6-8.noarch.rpm || true
rpm -i http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm || true
yum update -y
yum install \
  ant \
  ant-devel \
  erlang \
  gcc \
  java-1.6.0-openjdk \
  java-1.6.0-openjdk-devel \
  mkisofs \
  mysql \
  MySQL-python \
  mysql-server \
  openssh-clients \
  python \
  python-devel \
  python-pip \
  tomcat6 \
  -y

# RabbitMQ
rpm -i http://www.rabbitmq.com/releases/rabbitmq-server/v3.2.3/rabbitmq-server-3.2.3-1.noarch.rpm
chkconfig --level 345 rabbitmq-server on
/etc/init.d/rabbitmq-server start

# Start Dependency Services
chkconfig --level 345 mysqld on
/etc/init.d/mysqld start

# Maven
cd /usr/local
wget http://www.us.apache.org/dist/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz
tar -zxvf apache-maven-3.0.5-bin.tar.gz
export M2_HOME=/usr/local/apache-maven-3.0.5
export PATH=${M2_HOME}/bin:${PATH}

# CloudStack Build
git clone https://github.com/dgrizzanti/cloudstack.git $cloudstack_dir
cd $cloudstack_dir
git checkout 4.2-tag-patches
wget https://gist.github.com/justincampbell/8599856/raw/AddingRabbitMQtoCloudStackComponentContext.patch
git apply AddingRabbitMQtoCloudStackComponentContext.patch
mvn -Pdeveloper -Dsimulator -DskipTests -Dmaven.install.skip=true install
cp $source_dir/cloudstack-simulator /etc/init.d/
chkconfig --level 345 cloudstack-simulator on

# CloudStack Configuration
mvn -Pdeveloper -pl developer -Ddeploydb
mvn -Pdeveloper -pl developer -Ddeploydb-simulator
/etc/init.d/cloudstack-simulator start
pip install argparse
sleep 90 # TODO: Wait for CloudStack to start
mvn -Pdeveloper,marvin.sync -Dendpoint=localhost -pl :cloud-marvin
mvn -Pdeveloper,marvin.setup -Dmarvin.config=setup/dev/advanced.cfg -pl :cloud-marvin integration-test || true
/etc/init.d/cloudstack-simulator stop
mysql -uroot cloud -e "update service_offering set ram_size = 32;"
mysql -uroot cloud -e "update vm_template set enable_password = 1 where name like '%CentOS%';"
mysql -uroot cloud -e "insert into hypervisor_capabilities values (100,'100','Simulator','default',50,1,6,NULL,0,0);"
mysql -uroot cloud -e "update user set api_key = 'F0Hrpezpz4D3RBrM6CBWadbhzwQMLESawX-yMzc5BCdmjMon3NtDhrwmJSB1IBl7qOrVIT4H39PTEJoDnN-4vA' where id = 2;"
mysql -uroot cloud -e "update user set secret_key = 'uWpZUVnqQB4MLrS_pjHCRaGQjX62BTk_HU8uiPhEShsY7qGsrKKFBLlkTYpKsg1MzBJ4qWL0yJ7W7beemp-_Ng' where id = 2;"
/etc/init.d/cloudstack-simulator start

# Cleanup
rm -rf ~/*.tar.gz
rm -rf ~/cloudstack/.git
yum clean all
find /var/log -type f | while read f; do echo -ne '' > $f; done;
dd if=/dev/zero of=wipefile bs=1024x1024 || rm -f wipefile
