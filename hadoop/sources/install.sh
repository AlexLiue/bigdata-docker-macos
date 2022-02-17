#!/bin/bash
## Create by PcLiu at 2022/01/25


HADOOP_VERSION="2.7.5"
HBASE_VERSION="1.4.9"
HIVE_VERSION="3.1.1"

########################################################################################
#####################          Install  Bigdata Docker  Env        #####################
########################################################################################

## Prepare System Env
if [ ! -f  "/usr/bin/vim" ] ;then
  apt-get update
  ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  echo "Asia/Shanghai" > /etc/timezone
  apt-get install -y openssh-server openssh-client mysql-client curl jq net-tools lsof vim netcat

  ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa -q
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config
  mkdir /opt/installs
  mkdir /opt/run
fi

## Install JAVA ENV
if [ ! -f  "/opt/run/jdk/bin/java" ] ;then
  tar -xvf /opt/sources/packages/OpenJDK8U-jdk_aarch64_linux_8u312b07.tar.gz -C "/opt/installs" >/dev/null;
  mv /opt/installs/openjdk-8u312-b07 /opt/installs/jdk-8u312;
  ln -s /opt/installs/jdk-8u312 /opt/run/jdk8

  tar -xvf /opt/sources/packages/OpenJDK11U-jdk_aarch64_linux_11.0.13_8.tar.gz -C "/opt/installs" >/dev/null;
  mv /opt/installs/openjdk-11.0.13_8/ /opt/installs/jdk-11.0.13;
  ln -s /opt/installs/jdk-11.0.13 /opt/run/jdk11

  ln -s /opt/run/jdk8 /opt/run/jdk
  echo "" >> /etc/profile
  echo "export JAVA_HOME=/opt/run/jdk" >> /etc/profile
  echo "export PATH=\"\$PATH:/opt/run/jdk/bin\"" >> /etc/profile
  export JAVA_HOME=/opt/run/jdk
fi

if [ ! -d "/opt/run/hadoop" ] ;then
    VERSION="$HADOOP_VERSION"
    tar -zxf "/opt/sources/packages/hadoop-$VERSION.tar.gz" -C "/opt/installs" >/dev/null
    ln -s "/opt/installs/hadoop-$VERSION"  /opt/run/hadoop
    cp -f /opt/sources/configs/hadoop/* /opt/run/hadoop/etc/hadoop

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
fi

if [ ! -d "/opt/run/hbase" ] ;then
  VERSION="$HBASE_VERSION"
  tar -zxf "/opt/sources/packages/hbase-$VERSION-bin.tar.gz" -C "/opt/installs" >/dev/null
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
  sed -i "s/localhost/hadoop/" /opt/run/hbase/conf/regionservers
  cp -f /opt/sources/configs/hbase/hbase-site.xml /opt/run/hbase/conf
fi

if [ ! -d "/opt/run/hive" ] ;then
  VERSION="$HIVE_VERSION"
  tar -zxf "/opt/sources/packages/apache-hive-$VERSION-bin.tar.gz" -C "/opt/installs" >/dev/null
  mv "/opt/installs/apache-hive-$VERSION-bin" "/opt/installs/hive-$VERSION"
  ln -s "/opt/installs/hive-$VERSION"  /opt/run/hive
  cp /opt/sources/configs/hive/* /opt/run/hive/conf

  ## Set Hive System ENV
  echo "export HIVE_HOME=/opt/run/hive" >> /etc/profile
  echo "export PATH=\"\$PATH:/opt/run/hive/bin\"" >> /etc/profile
  echo "" >>/etc/profile

  cp /opt/sources/packages/libs/mysql-connector-java-8.0.28.jar /opt/run/hive/lib
fi

if [ ! -d "/opt/run/spark" ] ;then
  tar -zxf "/opt/sources/packages/spark-2.4.8-bin-hadoop2.7.tgz" -C "/opt/installs" >/dev/null
  ln -s /opt/installs/spark-2.4.8-bin-hadoop2.7 /opt/run/spark2

  tar -zxf "/opt/sources/packages/spark-3.1.2-bin-hadoop2.7.tgz" -C "/opt/installs" >/dev/null
  ln -s /opt/installs/spark-3.1.2-bin-hadoop2.7 /opt/run/spark3

  ln -s /opt/run/spark3 /opt/run/spark
  echo "export SPARK_HOME=/opt/run/spark" >> /etc/profile
  echo "export PATH=\"\$PATH:/opt/run/spark/bin\"" >> /etc/profile
  echo "" >>/etc/profile
fi

if [ ! -d "/opt/run/flink" ] ;then
  tar -zxf "/opt/sources/packages/flink-1.14.3-bin-scala_2.11.tgz" -C "/opt/installs" >/dev/null
  ln -s /opt/installs/flink-1.14.3 /opt/run/flink

  echo "export FLINK_HOME=/opt/run/flink" >> /etc/profile
  echo "export PATH=\"\$PATH:/opt/run/flink/bin\"" >> /etc/profile
  echo "" >>/etc/profile
fi

if [ -d "/opt/sources" ] ;then
  rm -f /opt/sources
fi

chmod 755 /opt/*.sh



