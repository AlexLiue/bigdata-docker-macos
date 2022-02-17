#!/bin/bash
## Check Zookeeper Status

set -x
SLEEP_SECOND=5

wait_for() {
    echo "Waiting $3" started, waiting for "$1" to listen on "$2"...
    while ! nc -z "$1" "$2"; do echo waiting...; sleep "$SLEEP_SECOND"; done
}

## Clean History logs
rm -rf /opt/run/kafka/logs/*
rm -rf /opt/run/confluent/logs/*

## Source Env
sh /etc/profile

## Wait Zookeeper
wait_for "zoo" "2181" "zookeeper"
sleep 20  # Wait last kafka connection timeout, for new connection session

## Start Kafka
/opt/run/kafka/bin/kafka-server-start.sh -daemon /opt/run/kafka/config/server.properties
wait_for "kafka" "9092" " kafka-server"

/opt/run/confluent/bin/schema-registry-start -daemon /opt/run/confluent/etc/schema-registry/schema-registry.properties
wait_for "kafka" "8081" "schema-registry"

/opt/run/kafka/bin/connect-distributed.sh -daemon /opt/run/kafka/config/connect-avro-distributed.properties
wait_for "kafka" "8083" "connect-distributed-avro"

/opt/run/kafka/bin/connect-distributed.sh -daemon /opt/run/kafka/config/connect-json-distributed.properties
wait_for "kafka" "8084" "connect-distributed-json"

curl -XGET http://bigdata:8083/connector-plugins

tail -f /opt/run/kafka/logs/* /opt/run/confluent/logs/*
