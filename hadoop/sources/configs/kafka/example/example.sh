#!/bin/bash
## Create by PcLiu at 2022/01/25

set -x

/bin/bash create_test_table.sh

curl -X GET hadoop:8083/connector-plugins | jq

curl -X GET hadoop:8083/connectors/db_utf8 | jq
curl -X GET hadoop:8083/connectors/db_gbk | jq
curl -X GET hadoop:8083/connectors/db_gb18030 | jq

curl -X POST hadoop:8083/connectors/db_utf8/tasks/0/restart
curl -X POST hadoop:8083/connectors/db_gbk/tasks/0/restart
curl -X POST hadoop:8083/connectors/db_gb18030/tasks/0/restart

curl -X GET hadoop:8083/connectors/db_utf8/status | jq
curl -X GET hadoop:8083/connectors/db_gbk/status | jq
curl -X GET hadoop:8083/connectors/db_gb18030/status | jq

curl -XDELETE hadoop:8083/connectors/db_utf8
curl -XDELETE hadoop:8083/connectors/db_gbk
curl -XDELETE hadoop:8083/connectors/db_gb18030

curl -X POST -H "Content-Type:application/json" hadoop:8083/connectors -d @/opt/run/kafka/config/connect-instances/db_utf8_test.json
curl -X POST -H "Content-Type:application/json" hadoop:8083/connectors -d @/opt/run/kafka/config/connect-instances/db_gbk_test.json
curl -X POST -H "Content-Type:application/json" hadoop:8083/connectors -d @/opt/run/kafka/config/connect-instances/db_gb18030_test.json

curl -X GET -H "Content-Type:application/json" hadoop:8083/connectors

/opt/run/kafka/bin/kafka-topics.sh --bootstrap-server hadoop:9092 --list

/opt/run/confluent/bin/kafka-avro-console-consumer --max-messages 1 --bootstrap-server hadoop:9092 --property schema.registry.url=http://hadoop:8081 --topic test.db_utf8_test.tbl_test_1 --from-beginning
/opt/run/confluent/bin/kafka-avro-console-consumer --max-messages 1 --bootstrap-server hadoop:9092 --property schema.registry.url=http://hadoop:8081 --topic test.db_gbk_test.tbl_test_1 --from-beginning
/opt/run/confluent/bin/kafka-avro-console-consumer --max-messages 1 --bootstrap-server hadoop:9092 --property schema.registry.url=http://hadoop:8081 --topic test.db_gb18030_test.tbl_test_1 --from-beginning


/opt/run/confluent/bin/kafka-topics --describe --bootstrap-server hadoop:9092 --topic test.db_gb18030_test.tbl_test_1
/opt/run/confluent/bin/kafka-topics --describe --bootstrap-server hadoop:9092 --topic test.db_gb18030_test.tbl_test_1
/opt/run/confluent/bin/kafka-topics --describe --bootstrap-server hadoop:9092 --topic test.db_gb18030_test.tbl_test_1

curl -X GET http://hadoop:8081/subjects
