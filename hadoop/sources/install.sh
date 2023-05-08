#!/usr/bin/bash
## Create by PcLiu at 2022/01/25

HADOOP_VERSION="3.1.3"
HIVE_VERSION="3.1.3"
TEZ_VERSION="0.10.1"
TOMCAT_VERSION="9.0.74"
HBASE_VERSION="1.4.9"

SPARK2_VERSION="2.4.8"
SPARK3_VERSION="3.2.4"
FLINK_VERSION="1.17.0"

set -x

########################################################################################
#####################          Install  Bigdata Docker  Env        #####################
########################################################################################

SLEEP_SECOND=5

wait_for() {
  echo "Waiting $3" started, waiting for "$1" to listen on "$2"...
  while ! nc -z "$1" "$2"; do echo waiting...; sleep "$SLEEP_SECOND"; done
}

cp -f /opt/sources/*.sh /opt
chmod 755 /opt/*.sh
mv /etc/apt/sources.list /etc/apt/sources.list.back
cp /opt/sources/sources.list /etc/apt

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

  # For root login
  sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
fi

if [ ! -d "/opt/installs" ] ;then
  mkdir /opt/installs
fi
if [ ! -d "/opt/run" ] ;then
  mkdir /opt/run
fi

## Install JAVA ENV
if [ ! -f  "/opt/run/jdk/bin/java" ] ;then
    tar -xvf /opt/sources/packages/OpenJDK8U-jdk_aarch64_linux_8u312b07.tar.gz -C "/opt/installs"
    mv /opt/installs/openjdk-8u312-b07 /opt/installs/jdk-8u312;
    ln -s /opt/installs/jdk-8u312 /opt/run/jdk8

    tar -xvf /opt/sources/packages/OpenJDK11U-jdk_aarch64_linux_11.0.13_8.tar.gz -C "/opt/installs"
    mv /opt/installs/openjdk-11.0.13_8/ /opt/installs/jdk-11.0.13;
    ln -s /opt/installs/jdk-11.0.13 /opt/run/jdk11

    ln -s /opt/run/jdk8 /opt/run/jdk
    echo "" >> /etc/profile
    echo "export JAVA_HOME=/opt/run/jdk" >> /etc/profile
    echo "export PATH=\"\$PATH:/opt/run/jdk/bin\"" >> /etc/profile
    export JAVA_HOME=/opt/run/jdk

    chown -R  root:root /opt/run/jdk
    chown -R  root:root /opt/installs/jdk-*
fi

if [ ! -d  "/opt/run/scala" ] ;then
  tar -zxvf /opt/sources/packages/scala-3.2.2.tar.gz -C /opt/installs
  ln -s /opt/installs/scala-3.2.2 /opt/run/scala
  echo "" >> /etc/profile
  echo "export SCALA_HOME=/opt/run/scala" >> /etc/profile
  echo "export PATH=\"\$PATH:/opt/run/scala\"" >> /etc/profile
fi



if [ ! -d "/opt/run/hadoop" ] ;then
    VERSION="$HADOOP_VERSION"
    tar -zxf "/opt/sources/packages/hadoop-$VERSION.tar.gz" -C "/opt/installs"
    ln -s "/opt/installs/hadoop-$VERSION"  /opt/run/hadoop
    cp -f /opt/sources/configs/hadoop/* /opt/run/hadoop/etc/hadoop
    # Fix snappy-java
    rm -f /opt/run/hadoop/share/hadoop/common/lib/snappy-java*
    cp /opt/sources/packages/libs/snappy-java-1.1.8.4.jar /opt/run/hadoop/share/hadoop/common/lib/
    rm -f /opt/run/hadoop/share/hadoop/hdfs/lib/snappy-java*
    cp -f /opt/sources/packages/libs/snappy-java-1.1.8.4.jar /opt/run/hadoop/share/hadoop/hdfs/lib/
    # Fix leveldbjni-all https://issues.apache.org/jira/browse/HADOOP-16614
    rm /opt/run/hadoop/share/hadoop/hdfs/lib/leveldbjni-all-1.8.jar
    cp /opt/sources/packages/libs/leveldbjni-all-1.8.jar /opt/run/hadoop/share/hadoop/hdfs/lib/

    ## Set Hadoop System ENV
    echo "export HADOOP_HOME=/opt/run/hadoop" >> /etc/profile
    echo "export HADOOP_CONF_DIR=/opt/run/hadoop/etc/hadoop" >> /etc/profile
    echo "export HADOOP_CLASSPATH=\`/opt/run/hadoop/bin/hadoop classpath\`" >> /etc/profile
    echo "export PATH=\"\$PATH:/opt/run/hadoop/bin\"" >> /etc/profile
    echo "" >> /etc/profile

    ## Set Hadoop Java ENV
    JAVA_HOME_ORG="export JAVA_HOME=\${JAVA_HOME}"
    JAVA_HOME_NEW="export JAVA_HOME=${JAVA_HOME}"
    sed -i "/$JAVA_HOME_ORG/a $JAVA_HOME_NEW" "/opt/run/hadoop/etc/hadoop/hadoop-env.sh"
    sed -i "/$JAVA_HOME_ORG/d" "/opt/run/hadoop/etc/hadoop/hadoop-env.sh"

    ## Add User And Groups
    groupadd hadoop
    useradd -d /home/hadoop -g hadoop -m -s /bin/bash hadoop
    chown -R  hadoop:hadoop /opt/run/hadoop
    chown -R  hadoop:hadoop "/opt/installs/hadoop-$VERSION"

    useradd -d /home/hdfs -g hadoop -m -s /bin/bash hdfs
    su -c "mkdir ~/.ssh" hdfs
    su -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa -q" hdfs
    su -c "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys" hdfs
    su -c "chmod 600 ~/.ssh/authorized_keys" hdfs

    useradd -d /home/yarn -g hadoop -m -s /bin/bash yarn
    su -c "mkdir ~/.ssh" yarn
    su -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa -q" yarn
    su -c "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys" yarn
    su -c "chmod 600 ~/.ssh/authorized_keys" yarn

    # Create Data  Dir
    mkdir -p /opt/run/hadoop/data/tmp
    chown hadoop:hadoop -R /opt/run/hadoop/data
    chmod 775 -R /opt/run/hadoop/data

    # Create Logs  Dir
    mkdir /opt/run/hadoop/logs
    chown  hadoop:hadoop /opt/run/hadoop/logs
    chmod 775 -R /opt/run/hadoop/logs

    ## Format
    su -c "/opt/run/hadoop/bin/hdfs namenode -format" hdfs
fi



if [ ! -d "/opt/run/tomcat" ] ;then
    VERSION="$TOMCAT_VERSION"
    tar -zxf "/opt/sources/packages/apache-tomcat-$VERSION.tar.gz" -C "/opt/installs"
    ln -s "/opt/installs/apache-tomcat-$VERSION" /opt/run/tomcat
    sed -i 's/8080/9999/g' /opt/run/tomcat/conf/server.xml
    chmod 755 -R /opt/run/tomcat/bin/*.sh
    chown -R hdfs:hadoop "/opt/installs/apache-tomcat-$VERSION"
    chown -R hdfs:hadoop /opt/run/tomcat
fi


if [ ! -d "/opt/run/tez" ] ;then
    VERSION="$TEZ_VERSION"
    tar -zxf "/opt/sources/packages/apache-tez-$VERSION-bin.tar.gz" -C "/opt/installs"
    mv "/opt/installs/apache-tez-$VERSION-bin" "/opt/installs/tez-$VERSION"
    ln -s "/opt/installs/tez-$VERSION" /opt/run/tez
    cd /opt/run/tez || ! echo "Failure"
    rm -rf share

    rm -f /opt/run/tez/lib/leveldbjni-all*
    cp /opt/sources/packages/libs/leveldbjni-all-1.8.jar /opt/run/tez/lib/
    rm -f /opt/run/tez/lib/snappy-java-*
    cp /opt/sources/packages/libs/snappy-java-1.1.8.4.jar /opt/run/tez/lib/
    rm /opt/run/tez/lib/hadoop-mapreduce-client-core*
    cp /opt/run/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-core* /opt/run/tez/lib/
    rm /opt/run/tez/lib/hadoop-mapreduce-client-common*
    cp /opt/run/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-common* /opt/run/tez/lib/
    rm /opt/run/tez/lib/hadoop-hdfs-client*
    cp /opt/run/hadoop/share/hadoop/hdfs/hadoop-hdfs-client* /opt/run/tez/lib/
    rm /opt/run/tez/lib/hadoop-yarn-server-timeline-pluginstorage*
    cp /opt/run/hadoop/share/hadoop/yarn/hadoop-yarn-server-timeline-pluginstorage* /opt/run/tez/lib/

    ## Set Hive System ENV
    echo "export TEZ_HOME=/opt/run/tez" >> /etc/profile
    echo "" >>/etc/profile

    rm -rf /opt/run/tomcat/webapps/*
    mkdir -p /opt/run/tomcat/webapps/tez-ui
    cd /opt/run/tomcat/webapps/tez-ui || ! echo "Failure"
    cp "/opt/sources/packages/libs/tez-ui-$VERSION.war" .
    /opt/run/jdk/bin/jar -xvf "tez-ui-$VERSION.war"
    rm -f "tez-ui-$VERSION.war"

    sed -i 's+8080+9999+g' /opt/run/tomcat/conf/server.xml
    sed -i 's+localhost+hadoop+g' /opt/run/tomcat/conf/server.xml
    sed -i 's+//timeline: "http://localhost:8188"+timeline: "http://hadoop:8188"+g' /opt/run/tomcat/webapps/tez-ui/config/configs.js
    sed -i 's+//rm: "http://localhost:8088"+rm: "http://hadoop:8088"+g' /opt/run/tomcat/webapps/tez-ui/config/configs.js

    chown -R hdfs:hadoop /opt/run/tomcat

    chown -R hdfs:hadoop "/opt/installs/tez-$VERSION"
    chown -R hdfs:hadoop /opt/run/tez
fi


if [ ! -d "/opt/run/hive" ] ;then
    VERSION="$HIVE_VERSION"
    tar -zxf "/opt/sources/packages/apache-hive-$VERSION-bin.tar.gz" -C "/opt/installs"
    mv "/opt/installs/apache-hive-$VERSION-bin" "/opt/installs/hive-$VERSION"
    ln -s "/opt/installs/hive-$VERSION"  /opt/run/hive
    cp /opt/sources/configs/hive/* /opt/run/hive/conf

    echo "export HIVE_HOME=/opt/run/hive" >> /etc/profile
    echo "export PATH=\"\$PATH:/opt/run/hive/bin\"" >> /etc/profile
    echo "" >>/etc/profile

    # Copy JDBC Driver
    cp /opt/sources/packages/libs/mysql-connector-java-8.0.28.jar /opt/run/hive/lib

   # Fix Guava Version Conflict
    rm -f /opt/run/hive/lib/guava*
    cp /opt/run/hadoop/share/hadoop/common/lib/guava* /opt/run/hive/lib/
    rm -f /opt/run/hive/lib/snappy-java*
    cp -f /opt/sources/packages/libs/snappy-java-1.1.8.4.jar /opt/run/hive/lib/

    useradd -d /home/hive -g hadoop -m -s /bin/bash hive
    su -c "mkdir ~/.ssh" hive
    su -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa -q" hive
    su -c "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys" hive
    su -c "chmod 600 ~/.ssh/authorized_keys" hive

    chown -R hdfs:hadoop "/opt/installs/hive-$VERSION"
    chown -R hdfs:hadoop /opt/run/hive
fi


if [ ! -d "/opt/run/hbase" ] ;then
    VERSION="$HBASE_VERSION"
    tar -zxf "/opt/sources/packages/hbase-$VERSION-bin.tar.gz" -C "/opt/installs"
    ln -s "/opt/installs/hbase-$VERSION"  /opt/run/hbase

    ## Set HBase System ENV
    echo "export HBASE_HOME=/opt/run/hbase" >> /etc/profile
    echo "export PATH=\"\$PATH:/opt/run/hbase/bin\"" >> /etc/profile
    echo "" >>/etc/profile

    ## Set HBase Config
    HBASE_JAVA_HOME_ORG="export JAVA_HOME"
    HBASE_JAVA_HOME_SET="export JAVA_HOME=${JAVA_HOME}"
    sed -i "/$HBASE_JAVA_HOME_ORG/a $HBASE_JAVA_HOME_SET" /opt/run/hbase/conf/hbase-env.sh
    sed -i 's/# export HBASE_MANAGES_ZK=true/export HBASE_MANAGES_ZK=false/' /opt/run/hbase/conf/hbase-env.sh
    sed -i "s/localhost/hadoop/" /opt/run/hbase/conf/regionservers
    cp -f /opt/sources/configs/hbase/hbase-site.xml /opt/run/hbase/conf

    rm -f /opt/run/hbase/lib/leveldbjni-all-1.8.jar
    cp /opt/sources/packages/libs/leveldbjni-all-1.8.jar /opt/run/hbase/lib/

    rm -f /opt/run/hbase/lib/snappy-java-*
    cp /opt/sources/packages/libs/snappy-java-1.1.8.4.jar /opt/run/hbase/lib/

    useradd -d /home/hbase -g hadoop -m -s /bin/bash hbase
    su -c "mkdir ~/.ssh" hbase
    su -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa -q" hbase
    su -c "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys" hbase
    su -c "chmod 600 ~/.ssh/authorized_keys" hbase

    chown -R hbase:hadoop /opt/run/hbase
    chown -R hbase:hadoop "/opt/installs/hbase-$VERSION"

fi


if [ ! -d "/opt/run/spark" ] ;then
    tar -zxf "/opt/sources/packages/spark-$SPARK2_VERSION-bin-without-hadoop.tgz" -C "/opt/installs"
    ln -s "/opt/installs/spark-$SPARK2_VERSION-bin-without-hadoop" /opt/run/spark2
    tar -zxf "/opt/sources/packages/spark-$SPARK3_VERSION-bin-hadoop3.2.tgz" -C "/opt/installs"
    ln -s "/opt/installs/spark-$SPARK2_VERSION-bin-without-hadoop" /opt/run/spark2
    ln -s "/opt/installs/spark-$SPARK3_VERSION-bin-hadoop3.2" /opt/run/spark3

    rm -f /opt/run/spark2/jars/snappy-java*
    cp /opt/sources/packages/libs/snappy-java-1.1.8.4.jar /opt/run/spark2/jars/
    rm -f /opt/run/spark3/jars/snappy-java*
    cp /opt/sources/packages/libs/snappy-java-1.1.8.4.jar /opt/run/spark3/jars/

    rm /opt/run/spark2/jars/leveldbjni-all-1.8.jar
    cp /opt/sources/packages/libs/leveldbjni-all-1.8.jar /opt/run/spark2/jars
    rm /opt/run/spark3/jars/leveldbjni-all-1.8.jar
    cp /opt/sources/packages/libs/leveldbjni-all-1.8.jar /opt/run/spark3/jars/

    cp /opt/run/spark2/conf/spark-env.sh.template /opt/run/spark2/conf/spark-env.sh
    echo "SPARK_CONF_DIR=/opt/run/spark2/conf" >> /opt/run/spark2/conf/spark-env.sh
    echo "HADOOP_CONF_DIR=/opt/run/hadoop/etc/hadoop" >> /opt/run/spark2/conf/spark-env.sh
    echo "YARN_CONF_DIR=/opt/run/hadoop/etc/hadoop" >> /opt/run/spark2/conf/spark-env.sh
    echo "SPARK_DIST_CLASSPATH=\$(/opt/run/hadoop/bin/hadoop classpath):/opt/run/hive/lib/*" >> /opt/run/spark2/conf/spark-env.sh

    cp /opt/run/spark3/conf/spark-env.sh.template /opt/run/spark3/conf/spark-env.sh
    echo "SPARK_CONF_DIR=/opt/run/spark3/conf" >> /opt/run/spark3/conf/spark-env.sh
    echo "HADOOP_CONF_DIR=/opt/run/hadoop/etc/hadoop" >> /opt/run/spark3/conf/spark-env.sh
    echo "YARN_CONF_DIR=/opt/run/hadoop/etc/hadoop" >> /opt/run/spark3/conf/spark-env.sh
    echo "SPARK_DIST_CLASSPATH=\$(/opt/run/hadoop/bin/hadoop classpath):/opt/run/hive/lib/*" >> /opt/run/spark3/conf/spark-env.sh

    ln -s /opt/run/spark3 /opt/run/spark
    echo "export SPARK_HOME=/opt/run/spark" >> /etc/profile
    echo "export PATH=\"\$PATH:/opt/run/spark/bin\"" >> /etc/profile
    echo "" >>/etc/profile

    useradd -d /home/spark -g hadoop -m -s /bin/bash spark
    su -c "mkdir ~/.ssh" spark
    su -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa -q" spark
    su -c "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys" spark
    su -c "chmod 600 ~/.ssh/authorized_keys" spark

    chown -R spark:hadoop /opt/run/spark
    chown -R spark:hadoop "/opt/installs/spark-$SPARK2_VERSION-bin-without-hadoop"
    chown -R spark:hadoop "/opt/installs/spark-$SPARK3_VERSION-bin-hadoop3.2"
fi

if [ ! -d "/opt/run/flink" ] ;then
    tar -zxf "/opt/sources/packages/flink-$FLINK_VERSION-bin-scala_2.12.tgz" -C "/opt/installs"
    ln -s "/opt/installs/flink-$FLINK_VERSION" /opt/run/flink

    echo "export FLINK_HOME=/opt/run/flink" >> /etc/profile
    echo "export PATH=\"\$PATH:/opt/run/flink/bin\"" >> /etc/profile
    echo "" >>/etc/profile

    useradd -d /home/flink -g hadoop -m -s /bin/bash flink
    su -c "mkdir ~/.ssh" flink
    su -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa -q" flink
    su -c "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys" flink
    su -c "chmod 600 ~/.ssh/authorized_keys" flink

    chown -R flink:hadoop /opt/run/flink
    chown -R flink:hadoop "/opt/installs/flink-$FLINK_VERSION"
fi








