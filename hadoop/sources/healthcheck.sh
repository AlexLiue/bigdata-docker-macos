#!/bin/bash

# SSH Server Port : 22
# localhost HDFS File System Port : 8020
# localhost Yarn Port : 8088
# Hive Metastore Port : 9083
# Hive HiveServer2  Port : 10000
# Hbase Master Port : 16000
# Hbase RegionServer Port : 16020

if nc -z localhost 22 && nc -z localhost 8020 && nc -z localhost 8088 && nc -z localhost 9083 && nc -z localhost 9999 && nc -z localhost 10000 && nc -z localhost 16000 && nc -z localhost 16020 && nc -z localhost 9092 && nc -z localhost 8081 && nc -z localhost 8083 && nc -z localhost 8084
then
  exit 0
else
  exit 1
fi
