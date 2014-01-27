#!/bin/bash -ex

# Dependencies
yum install git wget -y
[[ -f /etc/yum.repos.d/epel.repo ]] || rpm -i http://mirror.metrocast.net/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
[[ -f /etc/yum.repos.d/erlang-solutions.repo ]] || rpm -i http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm || true
# yum update -y
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
[[ -f /etc/init.d/rabbitmq-server ]] || \
  rpm -i http://www.rabbitmq.com/releases/rabbitmq-server/v3.2.3/rabbitmq-server-3.2.3-1.noarch.rpm
chkconfig --level 345 rabbitmq-server on
/etc/init.d/rabbitmq-server start

# Start Dependency Services
chkconfig --level 345 mysqld on
/etc/init.d/mysqld start

# Maven
cd
[[ -f apache-maven-3.0.5-bin.tar.gz ]] || \
  wget http://www.us.apache.org/dist/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz
cd /usr/local/
[[ -d apache-maven-3.0.5 ]] || \
  tar -zxvf ~/apache-maven-3.0.5-bin.tar.gz
export M2_HOME=/usr/local/apache-maven-3.0.5
export PATH=${M2_HOME}/bin:${PATH}

# CloudStack Build
cd
[[ -d cloudstack ]] || \
  git clone https://github.com/apache/cloudstack.git
cd cloudstack
git checkout 4.2.0
wget https://gist.github.com/justincampbell/8599856/raw/AddingRabbitMQtoCloudStackComponentContext.patch
git apply AddingRabbitMQtoCloudStackComponentContext.patch
mvn -Pdeveloper -Dsimulator -DskipTests -Dmaven.install.skip=true install
cp /vagrant/cloudstack-simulator /etc/init.d/
chkconfig --level 345 cloudstack-simulator on

# CloudStack Create DB
mvn -Pdeveloper -pl developer -Ddeploydb
mvn -Pdeveloper -pl developer -Ddeploydb-simulator

# CloudStack Configuration
/etc/init.d/cloudstack-simulator start
pip install argparse
sleep 60 # Wait for CloudStack to start
mvn -Pdeveloper,marvin.sync -Dendpoint=localhost -pl :cloud-marvin
mvn -Pdeveloper,marvin.setup -Dmarvin.config=setup/dev/advanced.cfg -pl :cloud-marvin integration-test || true
