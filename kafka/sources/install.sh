#!/bin/bash
## Create by PcLiu at 2022/01/25

## Create Dir
mkdir /opt/installs
mkdir /opt/run

## Install Java
if [ ! -d "/opt/run/jdk" ] ;then
  tar -xvf /opt/sources/packages/OpenJDK8U-jdk_aarch64_linux_8u312b07.tar.gz -C "/opt/installs" >/dev/null
  rm -f /opt/sources/packages/OpenJDK8U-jdk_aarch64_linux_8u312b07.tar.gz
  ln -s /opt/installs/openjdk-8u312-b07 /opt/run/jdk8
  ln -s /opt/run/jdk8 /opt/run/jdk

  echo "" >>/etc/profile
  echo "export JAVA_HOME=/opt/run/jdk" >>/etc/profile
  echo "export PATH=\"\$PATH:/opt/run/jdk/bin\"" >>/etc/profile
fi

## Install Kafka
if [ ! -d "/opt/run/kafka" ] ;then
  tar -xvf /opt/sources/packages/kafka_2.12-2.6.3.tgz -C /opt/installs >/dev/null
  ln -s /opt/installs/kafka_2.12-2.6.3 /opt/run/kafka
  cp -rf /opt/sources/config/* /opt/run/kafka/config

  echo "" >>/etc/profile
  echo "export KAFKA_HOME=/opt/run/kafka" >> /etc/profile
  echo "export PATH=\"\$PATH:/opt/run/kafka/bin\"" >> /etc/profile
fi

## Install Confluent Community
if [ ! -d "/opt/run/confluent" ] ;then
    tar -zxf /opt/sources/packages/confluent-community-7.0.1.tar.gz -C /opt/installs >/dev/null
    ln -s /opt/installs/confluent-7.0.1 /opt/run/confluent

    sed -i "s/0.0.0.0:8081/kafka:8081/" /opt/run/confluent/etc/schema-registry/schema-registry.properties
    sed -i "s/localhost:9092/kafka:9092/" /opt/run/confluent/etc/schema-registry/schema-registry.properties
fi


## Install Kafka Connector Plugins: Debezium
if [ ! -d "/opt/run/debezium" ] ;then
  mkdir /opt/installs/debezium-1.8.0
  tar -zxf /opt/sources/packages/debezium-connector-mysql-1.8.0.Final-plugin.tar.gz -C /opt/installs/debezium-1.8.0 >/dev/null
  ln -s /opt/installs/debezium-1.8.0 /opt/run/debezium
fi

apt-get update
apt-get install -y netcat curl jq net-tools lsof vim

if [ -d "/opt/sources" ] ;then
  rm -f /opt/sources
fi

chmod 755 /opt/*.sh