#!/bin/bash -ex

# Dependencies
yum update -y
yum install \
  ant \
  ant-devel \
  gcc \
  git \
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
  wget \
  -y

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
mvn -Pdeveloper -Dsimulator -DskipTests -Dmaven.install.skip=true install

# CloudStack Create DB
/etc/init.d/mysqld start
# TODO: ensure runlevel for mysql
mvn -Pdeveloper -pl developer -Ddeploydb
mvn -Pdeveloper -pl developer -Ddeploydb-simulator

# CloudStack Start
# TODO: wrap this in init.d or upstart
mvn -Dsimulator -pl client jetty:run &

# CloudStack Configuration
yum groupinstall "Development Tools" -y
pip install argparse
sleep 30 # TODO: wait for cloudstack api
mvn -Pdeveloper,marvin.sync -Dendpoint=localhost -pl :cloud-marvin
# TODO: expect next command to fail
mvn -Pdeveloper,marvin.setup -Dmarvin.config=setup/dev/advanced.cfg -pl :cloud-marvin integration-test
