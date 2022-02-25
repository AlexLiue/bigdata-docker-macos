#!/bin/bash
## Create by PcLiu at 2022/01/25

curl -X GET kafka:8083/connector-plugins | jq

curl -X GET kafka:8083/connectors/db_utf8 | jq
curl -X GET kafka:8083/connectors/db_gbk | jq
curl -X GET kafka:8083/connectors/db_gb18030 | jq

curl -X POST kafka:8083/connectors/db_utf8/tasks/0/restart
curl -X POST kafka:8083/connectors/db_gbk/tasks/0/restart
curl -X POST kafka:8083/connectors/db_gb18030/tasks/0/restart

curl -X GET kafka:8083/connectors/db_utf8/status | jq
curl -X GET kafka:8083/connectors/db_gbk/status | jq
curl -X GET kafka:8083/connectors/db_gb18030/status | jq

curl -XDELETE kafka:8083/connectors/db_utf8
curl -XDELETE kafka:8083/connectors/db_gbk
curl -XDELETE kafka:8083/connectors/db_gb18030

curl -X POST -H "Content-Type:application/json" kafka:8083/connectors -d @/opt/run/kafka/config/connect-instances/db_utf8_test.json
curl -X POST -H "Content-Type:application/json" kafka:8083/connectors -d @/opt/run/kafka/config/connect-instances/db_gbk_test.json
curl -X POST -H "Content-Type:application/json" kafka:8083/connectors -d @/opt/run/kafka/config/connect-instances/db_gb18030_test.json

/opt/run/kafka/bin/kafka-topics.sh --bootstrap-server kafka:9092 --list

/opt/run/confluent/bin/kafka-avro-console-consumer --bootstrap-server kafka:9092 --property schema.registry.url=http://kafka:8081 --topic test.db_gb18030_test.tbl_test --from-beginning

/opt/run/confluent/bin/kafka-topics --describe --zookeeper kafka:2181 --topic dbserver1.test.tbl_test

curl -X GET http://kafka:8081/subjects
