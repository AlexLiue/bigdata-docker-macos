#!/bin/bash
## Create by PcLiu at 2022/01/25

service ssh start

## For Hive Schema
mysql -h192.168.10.5 -uroot -palex <<EOF
  ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'alex';
  ALTER USER 'hive'@'%' IDENTIFIED WITH mysql_native_password BY 'alex';
  FLUSH PRIVILEGES;
EOF
/opt/run/hive/bin/schematool -dbType mysql -initSchema --verbose

## For hive.metastore.warehouse.dir
/opt/run/hadoop/sbin/start-dfs.sh
sleep 10
/opt/run/hadoop/bin/hdfs dfs -mkdir /tmp
/opt/run/hadoop/bin/hdfs dfs -mkdir -p /user/hive/warehouse
/opt/run/hadoop/bin/hdfs dfs -chmod g+w /tmp
/opt/run/hadoop/bin/hdfs dfs -chmod g+w /user/hive/warehouse
/opt/run/hadoop/sbin/stop-dfs.sh

## For Kafka Connector
mysql -h192.168.10.5 -uroot -palex <<EOF
  CREATE DATABASE IF NOT EXISTS db_utf8_test;
  CREATE DATABASE IF NOT EXISTS db_gbk_test;
  CREATE DATABASE IF NOT EXISTS db_gb18030_test;
  FLUSH PRIVILEGES;
EOF
