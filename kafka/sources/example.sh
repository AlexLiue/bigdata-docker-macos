#!/bin/bash
## Create by PcLiu at 2022/01/25

## For Kafka Connector
mysql -hmysql -uroot -palex <<EOF
  CREATE DATABASE IF NOT EXISTS db_utf8_test;
  CREATE DATABASE IF NOT EXISTS db_gbk_test;
  CREATE DATABASE IF NOT EXISTS db_gb18030_test;
EOF

## Init Test Data
mysql -hmysql -uroot -palex <<EOF
  USE db_gb18030_test;
  CREATE TABLE tbl_test (
    ID int NOT NULL AUTO_INCREMENT,
    C1 varchar(45) DEFAULT NULL,
    C2 varchar(45) NOT NULL DEFAULT 'CV2',
    C3 int DEFAULT NULL,
    C4 bigint DEFAULT NULL,
    CREATE_TIME datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (ID)
  ) ENGINE=InnoDB DEFAULT CHARSET=gb18030 COLLATE=gb18030_bin;
  INSERT INTO tbl_test (C1, C2, C3, C4) VALUES ('v1', 'v2', '1', '12');
EOF


# curl -X GET kafka:8083/connectors/db_utf8 | jq
# curl -X GET kafka:8083/connectors/db_gbk | jq
# curl -X GET kafka:8083/connectors/db_gb18030 | jq

# curl -X POST kafka:8083/connectors/db_utf8/restart
# curl -X POST kafka:8083/connectors/db_gbk/restart
# curl -X POST kafka:8083/connectors/db_gb18030/restart

# curl -X GET kafka:8083/connectors/db_utf8/status | jq
# curl -X GET kafka:8083/connectors/db_gbk/status | jq
# curl -X GET kafka:8083/connectors/db_gb18030/status | jq

# curl -XDELETE  kafka:8083/connectors/db_utf8

# curl -X POST -H "Content-Type:application/json" kafka:8083/connectors -d @/opt/run/kafka/config/connect-instances/db_utf8_test.json
# curl -X POST -H "Content-Type:application/json" kafka:8083/connectors -d @/opt/run/kafka/config/connect-instances/db_gbk_test.json
# curl -X POST -H "Content-Type:application/json" kafka:8083/connectors -d @/opt/run/kafka/config/connect-instances/db_gb18030_test.json

# /opt/run/kafka/bin/kafka-topics.sh --bootstrap-server kafka:9092 --list

# /opt/run/confluent/bin/kafka-avro-console-consumer  --bootstrap-server kafka:9092 --property schema.registry.url=http://kafka:8081 --topic test.db_gb18030_test.tbl_test --from-beginning

# /opt/run/confluent/bin/kafka-topics --describe --zookeeper kafka:2181 --topic dbserver1.test.tbl_test

# curl -X GET http://kafka:8081/subjects
