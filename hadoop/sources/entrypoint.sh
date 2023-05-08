#!/usr/bin/bash
## Create by PcLiu at 2022/01/25


set -x
SLEEP_SECOND=3

wait_for() {
  echo "Waiting $3" started, waiting for "$1" to listen on "$2"...
  while ! nc -z "$1" "$2"; do echo waiting...; sleep "$SLEEP_SECOND"; done
}

## Alter Mysql-8 Password Plugin to mysql_native_password
alter_mysql_user_plugin(){
  mysql -hmysql -uroot -palex <<EOF
    ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'alex';
    ALTER USER 'hive'@'%' IDENTIFIED WITH mysql_native_password BY 'alex';
    FLUSH PRIVILEGES;
EOF
}

## Clean logs
rm -rf /opt/run/hadoop/logs/*
rm -rf /opt/run/hive/logs/*
rm -rf /opt/run/hbase/logs/*

## Wait for Dependencies Started
wait_for mysql 3306 "mysql"
wait_for zoo 2181 "zookeeper"

## Start SSH Server
service ssh start
wait_for hadoop 22

## Source Env
sh /etc/profile


## Start Hadoop HDFS
su -c "/opt/run/hadoop/sbin/start-dfs.sh" hdfs
wait_for hadoop 8020 "hadoop-hdfs"
wait_for hadoop 50070 "hadoop-hdfs"


## Start YARN
su -c "/opt/run/hadoop/sbin/start-yarn.sh" yarn
wait_for hadoop 8088 "hadoop-yarn"

## Start Job history

# shellcheck disable=SC2006
# shellcheck disable=SC2126
dir_created=`/opt/run/hadoop/bin/hdfs dfs -ls / | grep tmp | wc -l`
if [ "$dir_created" == "0" ] ;then
    ## Create Dirs
    su -c "/opt/run/hadoop/bin/hdfs dfs -chmod 775 /" hdfs
    su -c "/opt/run/hadoop/bin/hdfs dfs -chown -R hdfs:hadoop /" hdfs
    su -c "/opt/run/hadoop/bin/hdfs dfs -mkdir -p /user" hdfs
    su -c "/opt/run/hadoop/bin/hdfs dfs -mkdir -p /user/hive" hdfs
    su -c "/opt/run/hadoop/bin/hdfs dfs -chown -R hdfs:hadoop /user/hive" hdfs
    su -c "/opt/run/hadoop/bin/hdfs dfs -ls /user" hdfs
    su -c "/opt/run/hadoop/bin/hdfs dfs -ls /user/hive" hdfs

    su -c "/opt/run/hadoop/bin/hdfs dfs -mkdir -p /tmp" hdfs
    su -c "/opt/run/hadoop/bin/hdfs dfs -chmod 775 /tmp" hdfs
    su -c "/opt/run/hadoop/bin/hdfs dfs -chown -R hdfs:hadoop /tmp" hdfs
    su -c "/opt/run/hadoop/bin/hdfs dfs -mkdir -p /tmp/hive" hdfs
    su -c "/opt/run/hadoop/bin/hdfs dfs -chown -R hdfs:hadoop /tmp/hive" hdfs
    su -c "/opt/run/hadoop/bin/hdfs dfs -chmod 777 /tmp/hive" hdfs

    su -c "/opt/run/hadoop/bin/hdfs dfs -ls /tmp" hdfs
    su -c "/opt/run/hadoop/bin/hdfs dfs -ls /tmp/hive" hdfs

    ## Init Mysql Database for Hive Schema
    su -c "mkdir -p /opt/run/hive/logs" hdfs
    alter_mysql_user_plugin
    su -c "/opt/run/hive/bin/schematool -dbType mysql -initSchema --verbose" hdfs

    su -c "cd /opt/run/tez  && tar -czvf tez.tar.gz ./*" hdfs
    su -c "/opt/run/hadoop/bin/hdfs dfs -mkdir -p /apps/tez" hdfs
    su -c "/opt/run/hadoop/bin/hdfs dfs -put /opt/run/tez/tez.tar.gz /apps/tez" hdfs

fi

su -c "/opt/run/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver" yarn
wait_for hadoop 19888 "hadoop-history-server"

## Start Yarn TimelineServer
su -c "/opt/run/hadoop/bin/yarn --daemon start  timelineserver" yarn
wait_for hadoop 8188 "hadoop-yarn-timelineserver"

## Start hive metastore
su -c "nohup /opt/run/hive/bin/hive --service metastore 2>&1 > /opt/run/hive/logs/hive-metastore.log &" hdfs
wait_for hadoop 9083 "hive-metastore"

## Start hive hiveserver2
su -c "nohup /opt/run/hive/bin/hive --service hiveserver2 2>&1 > /opt/run/hive/logs/hive-hiveserver2.log &" hdfs
wait_for hadoop 10000 "hive-server2"

## Start hive TEZ UI
su -c "nohup /opt/run/tomcat/bin/startup.sh 2>&1 >/opt/run/tomcat/bin/startup.log &" hdfs

## Start hive hbase
su -c "/opt/run/hbase/bin/start-hbase.sh" hbase
wait_for hadoop 16000 "hbase"
wait_for hadoop 16020 "hbase"

tail -f /opt/run/hadoop/logs/* /opt/run/hive/logs/* /opt/run/hbase/logs/*

