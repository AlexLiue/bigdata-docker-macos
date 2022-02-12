#!/bin/bash
## Create by PcLiu at 2022/01/25

ZOOKEEPER_VERSION="3.5.9"
HADOOP_VERSION="2.7.5"
HBASE_VERSION="1.4.9"
HIVE_VERSION="3.1.1"


## Install Base Env
InstallSystemBaseEnv() {
  apt-get update
  ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  echo "Asia/Shanghai" > /etc/timezone
  apt-get install -y openssh-server openssh-client vim mysql-client curl jq

  ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa -q
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config

  mkdir /opt/installs
  mkdir /opt/run
}

## Install Java
InstallJava(){
  tar -xvf /tmp/sources/packages/OpenJDK8U-jdk_aarch64_linux_8u312b07.tar.gz -C "/opt/installs" >/dev/null;
  mv /opt/installs/openjdk-8u312-b07 /opt/installs/jdk-8u312;
  ln -s /opt/installs/jdk-8u312 /opt/run/jdk8

  tar -xvf /tmp/sources/packages/OpenJDK11U-jdk_aarch64_linux_11.0.13_8.tar.gz -C "/opt/installs" >/dev/null;
  mv /opt/installs/openjdk-11.0.13_8/ /opt/installs/jdk-11.0.13;
  ln -s /opt/installs/jdk-11.0.13 /opt/run/jdk11

  ln -s /opt/run/jdk8 /opt/run/jdk
  echo "" >> /etc/profile
  echo "export JAVA_HOME=/opt/run/jdk" >> /etc/profile
  echo "export PATH=\"\$PATH:/opt/run/jdk/bin\"" >> /etc/profile
  export JAVA_HOME=/opt/run/jdk
}

## Install Hadoop
InstallZookeeper(){
  VERSION="$ZOOKEEPER_VERSION"
  tar -xvf "/tmp/sources/packages/apache-zookeeper-$VERSION-bin.tar.gz" -C "/opt/installs" >/dev/null
  mv "/opt/installs/apache-zookeeper-$VERSION-bin" "/opt/installs/apache-zookeeper-$VERSION"
  ln -s "/opt/installs/apache-zookeeper-$VERSION"  /opt/run/zookeeper
  mv -f /tmp/sources/configs/zookeeper/* /opt/run/zookeeper/conf
  mkdir -p /opt/run/zookeeper/data/data-dir
  echo "1" > /opt/run/zookeeper/data/data-dir/myid

  echo "" >> /etc/profile
  echo "export ZOOKEEPER_HOME=/opt/run/zookeeper" >> /etc/profile
  echo "export PATH=\"\$PATH:/opt/run/zookeeper/bin\"" >> /etc/profile
  echo "" >> /etc/profile
}

## Install Hadoop
InstallHadoop(){
  VERSION="$HADOOP_VERSION"
  tar -zxf "/tmp/sources/packages/hadoop-$VERSION.tar.gz" -C "/opt/installs" >/dev/null
  ln -s "/opt/installs/hadoop-$VERSION"  /opt/run/hadoop
  cp -f /tmp/sources/configs/hadoop/* /opt/run/hadoop/etc/hadoop

  ## Set Hadoop System ENV
  echo "export HADOOP_HOME=/opt/run/hadoop" >> /etc/profile
  echo "export HADOOP_CONF_DIR=/opt/run/hadoop/etc/hadoop" >> /etc/profile
  echo "export PATH=\"\$PATH:/opt/run/hadoop/bin\"" >> /etc/profile
  echo "" >> /etc/profile

  ## Set Hadoop Java ENV
  JAVA_HOME_ORG="export JAVA_HOME=\${JAVA_HOME}"
  JAVA_HOME_NEW="export JAVA_HOME=${JAVA_HOME}"
  sed -i "/$JAVA_HOME_ORG/a $JAVA_HOME_NEW" "/opt/run/hadoop/etc/hadoop/hadoop-env.sh"
  sed -i "/$JAVA_HOME_ORG/d" "/opt/run/hadoop/etc/hadoop/hadoop-env.sh"

  ## Format
  /opt/run/hadoop/bin/hdfs namenode -format
}


## Install HBase
InstallHBase(){
  VERSION="$HBASE_VERSION"
  tar -zxf "/tmp/sources/packages/hbase-$VERSION-bin.tar.gz" -C "/opt/installs" >/dev/null
  ln -s "/opt/installs/hbase-$VERSION"  /opt/run/hbase

  ## Set HBase System ENV
  # shellcheck disable=SC2129
  echo "export HBASE_HOME=/opt/run/hbase" >> /etc/profile
  # shellcheck disable=SC2028
  echo "export PATH=\"\$PATH:/opt/run/hbase/bin\"" >> /etc/profile
  echo "" >>/etc/profile

  ## Set HBase Config
  HBASE_JAVA_HOME_ORG="export JAVA_HOME"
  HBASE_JAVA_HOME_SET="export JAVA_HOME=${JAVA_HOME}"
  sed -i "/$HBASE_JAVA_HOME_ORG/a $HBASE_JAVA_HOME_SET" /opt/run/hbase/conf/hbase-env.sh
  sed -i 's/# export HBASE_MANAGES_ZK=true/export HBASE_MANAGES_ZK=false/' /opt/run/hbase/conf/hbase-env.sh
  cp -f /tmp/sources/configs/hbase/hbase-site.xml /opt/run/hbase/conf
}


## Install Hive
InstallHive(){
  VERSION="$HIVE_VERSION"
  tar -zxf "/tmp/sources/packages/apache-hive-$VERSION-bin.tar.gz" -C "/opt/installs" >/dev/null
  mv "/opt/installs/apache-hive-$VERSION-bin" "/opt/installs/hive-$VERSION"
  ln -s "/opt/installs/hive-$VERSION"  /opt/run/hive
  cp /tmp/sources/configs/hive/* /opt/run/hive/conf

  ## Set Hive System ENV
  # shellcheck disable=SC2129
  echo "export HIVE_HOME=/opt/run/hive" >> /etc/profile
  # shellcheck disable=SC2028
  echo "export PATH=\"\$PATH:/opt/run/hive/bin\"" >> /etc/profile
  echo "" >>/etc/profile

  cp /tmp/sources/packages/libs/mysql-connector-java-8.0.28.jar /opt/run/hive/lib

}

## Install Kafka
InstallKafka(){
  tar -zxf "/tmp/sources/packages/kafka_2.12-2.6.3.tgz" -C "/opt/installs" >/dev/null
  ln -s /opt/installs/kafka_2.12-2.6.3 /opt/run/kafka
  # shellcheck disable=SC2129
  echo "export KAFKA_HOME=/opt/run/kafka" >> /etc/profile
  # shellcheck disable=SC2028
  echo "export PATH=\"\$PATH:/opt/run/kafka/bin\"" >> /etc/profile
  echo "" >>/etc/profile

  cp -rf /tmp/sources/configs/kafka/* /opt/run/kafka/config
}

## Install Kafka
InstallConfluent (){
  tar -zxf "/tmp/sources/packages/confluent-community-7.0.1.tar.gz" -C "/opt/installs" >/dev/null
  ln -s /opt/installs/confluent-7.0.1 /opt/run/confluent

  sed -i "s/0.0.0.0:8081/bigdata:8081/" /opt/run/confluent/etc/schema-registry/schema-registry.properties
  sed -i "s/localhost:9092/bigdata:9092/" /opt/run/confluent/etc/schema-registry/schema-registry.properties
}

## Install Kafka
InstallDebezium(){
  mkdir /opt/installs/debezium-1.8.0
  tar -zxf "/tmp/sources/packages/debezium-connector-mysql-1.8.0.Final-plugin.tar.gz" -C "/opt/installs/debezium-1.8.0" >/dev/null
  ln -s /opt/installs/debezium-1.8.0 /opt/run/debezium
}

InstallSpark() {
  tar -zxf "/tmp/sources/packages/spark-2.4.8-bin-hadoop2.7.tgz" -C "/opt/installs" >/dev/null
  mv /opt/installs/spark-2.4.8-bin-hadoop2.7 /opt/installs/spark-2.4.8
  ln -s /opt/installs/spark-2.4.8 /opt/run/spark2

  tar -zxf "/tmp/sources/packages/spark-3.2.1-bin-hadoop2.7.tgz" -C "/opt/installs" >/dev/null
  mv /opt/installs/spark-3.2.1-bin-hadoop2.7 /opt/installs/spark-3.2.1
  ln -s /opt/installs/spark-3.2.1 /opt/run/spark3

  ln -s /opt/run/spark2 /opt/run/spark
  # shellcheck disable=SC2129
  echo "export SPARK_HOME=/opt/run/spark" >> /etc/profile
  # shellcheck disable=SC2028
  echo "export PATH=\"\$PATH:/opt/run/spark/bin\"" >> /etc/profile
  echo "" >>/etc/profile
}

InstallFlink() {
  tar -zxf "/tmp/sources/packages/flink-1.14.3-bin-scala_2.11.tgz" -C "/opt/installs" >/dev/null
  ln -s /opt/installs/flink-1.14.3 /opt/run/flink

  # shellcheck disable=SC2129
  echo "export FLINK_HOME=/opt/run/flink" >> /etc/profile
  # shellcheck disable=SC2028
  echo "export PATH=\"\$PATH:/opt/run/flink/bin\"" >> /etc/profile
  echo "" >>/etc/profile

}
########################################################################################
#####################          Install  Bigdata Docker  Env        #####################
########################################################################################

## Prepare System Env
if [ ! -f  "/usr/bin/vim" ] ;then
  InstallSystemBaseEnv
fi

## Install JAVA ENV
if [ ! -f  "/opt/run/jdk/bin/java" ] ;then
  InstallJava
fi

if [ ! -d "/opt/run/zookeeper" ] ;then
  InstallZookeeper
fi

if [ ! -d "/opt/run/hadoop" ] ;then
  InstallHadoop
fi

if [ ! -d "/opt/run/hbase" ] ;then
  InstallHBase
fi

if [ ! -d "/opt/run/hive" ] ;then
  InstallHive
fi

if [ ! -d "/opt/run/kafka" ] ;then
  InstallKafka
fi

if [ ! -d "/opt/run/confluent" ] ;then
  InstallConfluent
fi

if [ ! -d "/opt/run/debezium" ] ;then
  InstallDebezium
fi

if [ ! -d "/opt/run/spark" ] ;then
  InstallSpark
fi

if [ ! -d "/opt/run/flink" ] ;then
  InstallFlink
fi

########################################################################################
#####################          Clean  Bigdata Docker  Env        #####################
########################################################################################

rm -rf /tmp/sources
apt-get clean && apt-get autoclean

