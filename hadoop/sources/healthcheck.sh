#!/bin/bash

# SSH Server Port : 22
# Hadoop HDFS File System Port : 8020
# Hadoop Yarn Port : 8088
# Hive Metastore Port : 9083
# Hive HiveServer2  Port : 10000
# Hbase Master Port : 16000
# Hbase RegionServer Port : 16020

if nc -z hadoop 22 && nc -z hadoop 8020 && nc -z hadoop 8088 && nc -z hadoop 9083 && nc -z hadoop 10000 && nc -z hadoop 16000  && nc -z hadoop 16020
then
  exit 0
else
  exit 1
fi
