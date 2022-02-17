#!/bin/bash
## Create by PcLiu at 2022/01/25

set -x
SLEEP_SECOND=5

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

## Init Hive Environment For Schema
init_hive_env(){
  ## Init Mysql Database for Hive Schema
  alter_mysql_user_plugin
  /opt/run/hive/bin/schematool -dbType mysql -initSchema --verbose

  ## Init Hive Warehouse in HDFS
  /opt/run/hadoop/bin/hdfs dfs -mkdir /tmp
  /opt/run/hadoop/bin/hdfs dfs -mkdir -p /user/hive/warehouse
  /opt/run/hadoop/bin/hdfs dfs -chmod g+w /tmp
  /opt/run/hadoop/bin/hdfs dfs -chmod g+w /user/hive/warehouse

  ## For Logs Dir
  mkdir /opt/run/hive/logs
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
/opt/run/hadoop/sbin/start-dfs.sh
wait_for hadoop 8020 "hadoop-hdfs"
wait_for hadoop 50070 "hadoop-hdfs"


## Start YARN Hive  HBase
/opt/run/hadoop/sbin/start-yarn.sh
if [ ! -d "/opt/run/hive/logs" ] ;then  ## Hive 未曾启动, 初始化 Hive Environment.
  init_hive_env
fi
nohup /opt/run/hive/bin/hive --service metastore >/opt/run/hive/logs/hive-metastore.log 2>&1 &
nohup /opt/run/hive/bin/hive --service hiveserver2 >/opt/run/hive/logs/hive-hiveserver2.log 2>&1 &
/opt/run/hbase/bin/start-hbase.sh
wait_for hadoop 8088 "hadoop-yarn"
wait_for hadoop 9083 "hive-metastore"
wait_for hadoop 10000 "hive-server2"
wait_for hadoop 16000 "hbase"
wait_for hadoop 16020 "hbase"

tail -f /opt/run/hadoop/logs/* /opt/run/hive/logs/* /opt/run/hbase/logs/*
