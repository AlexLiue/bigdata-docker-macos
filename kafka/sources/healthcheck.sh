#!/bin/bash

# Kafka Server Port : 9092
# Schema registry Server Port : 8081
# Kafka Avro Connector Server Port : 8083
# Kafka Json Connector Server Port : 8084

if nc -z kafka 9092 && nc -z kafka 8081 && nc -z kafka 8083 && nc -z kafka 8084
then
  exit 0
else
  exit 1
fi
