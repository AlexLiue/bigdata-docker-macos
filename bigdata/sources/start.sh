#!/bin/bash
## Create by PcLiu at 2022/01/25

########################################################################################
#####################          Start  Bigdata Docker  Env          #####################
########################################################################################

## Clean History logs
rm -rf /opt/run/hadoop/logs/*
rm -rf /opt/run/hbase/logs/*
rm -rf /opt/run/kafka/logs/*
rm -rf /opt/run/zookeeper/logs/*

service ssh start

## Source Env
sh /etc/profile

## Start Zookeeper
/opt/run/zookeeper/bin/zkServer.sh --config /opt/run/zookeeper/conf start

## Start Hadoop
/opt/run/hadoop/sbin/start-dfs.sh
/opt/run/hadoop/sbin/start-yarn.sh
sleep 10

## Start HBase
/opt/run/hbase/bin/start-hbase.sh

## Start Kafka
/opt/run/kafka/bin/kafka-server-start.sh -daemon /opt/run/kafka/config/server.properties
sleep 5
/opt/run/confluent/bin/schema-registry-start -daemon /opt/run/confluent/etc/schema-registry/schema-registry.properties
sleep 5
/opt/run/kafka/bin/connect-distributed.sh -daemon /opt/run/kafka/config/connect-avro-distributed.properties
sleep 5
curl -XGET http://bigdata:8083/connector-plugins
curl -X GET bigdata:8083/connectors/db_utf8 | jq
curl -X POST bigdata:8083/connectors/db_utf8/restart
curl -X GET bigdata:8083/connectors/db_utf8/status | jq

# curl -XDELETE  bigdata:8083/connectors/db_utf8

# curl -X POST -H "Content-Type:application/json" bigdata:8083/connectors -d @/opt/run/kafka/config/connect-instances/db_utf8_test.json
# curl -X POST -H "Content-Type:application/json" bigdata:8083/connectors -d @/opt/run/kafka/config/connect-instances/db_gbk_test.json
# curl -X POST -H "Content-Type:application/json" bigdata:8083/connectors -d @/opt/run/kafka/config/connect-instances/db_gb18030_test.json
