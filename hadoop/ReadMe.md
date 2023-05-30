# BigData Docker Env For MacOS M1
[BigData Run Env](https://github.com/AlexLiue/bigdata-docker-macos)  (Hadoop, Spark, Hive, Flink, Kafka, Zookeeper, Debezium, Mysql), MacOS M1 环境.

GitHub TAG LIST   
[3.1.3-0.1](https://github.com/AlexLiue/bigdata-docker-macos/releases/tag/3.1.3-0.1)


## Step1. Create  Docker Compose File ` docker-compose.yml`.
### ARGS
USE_CHINA_TUNA_MIRRORS: flag, weather use tsinghua mirror [http://mirrors.tuna.tsinghua.edu.cn]
```shell
networks:
  docker:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 192.168.100.0/24
          gateway: 192.168.100.1

services:
  hadoop:
    build:
      context: hadoop
    container_name: hadoop
    hostname: hadoop
    networks:
      docker:
        ipv4_address: 192.168.100.10
    extra_hosts:
      - "doris:192.168.100.20"
      - "trino:192.168.100.21"
      - "redis:192.168.100.30"
    environment:
      - USER=root
      - JAVA_HOME=/opt/run/jdk
      - ZOOKEEPER_HOME=/opt/run/zookeeper
      - HADOOP_HOME=/opt/run/hadoop
      - HADOOP_CONF_DIR=/opt/run/hadoop/etc/hadoop
      - HBASE_HOME=/opt/run/hbase
      - HIVE_HOME=/opt/run/hive
      - SPARK2_HOME=/opt/run/spark
      - SPARK3_HOME=/opt/run/spark3
      - SPARK_MASTER_WEBUI_PORT=8090
      - FLINK_HOME=/opt/run/flink
      - PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/run/jdk/bin:/opt/run/zookeeper/bin:/opt/run/hadoop/bin:/opt/run/hbase/bin:/opt/run/hive/bin:/opt/run/kafka/bin:/opt/run/spark/bin:/opt/run/flink/bin
      - USE_CHINA_TUNA_MIRRORS=true
    ports:
      # SSH
      - "1022:22"
      # MYSQL
      - "3306:3306"
      # Zookeeper
      - "2181:2181"
      - "2888:2888"
      - "3888:3888"
      - "8080:8080"
      # HDFS
      - "8020:8020"
      - "50070:50070"
      - "50010:50010"
      - "50075:50075"
      - "50475:50475"
      - "50020:50020"
      - "8485:8485"
      - "8480:8480"
      - "9866:9866"
      # YARN
      - "8030:8030"
      - "8031:8031"
      - "8032:8032"
      - "8033:8033"
      - "8040:8040"
      - "8042:8042"
      - "8041:8041"
      - "8088:8088"
      - "10020:10020"
      - "19888:19888"
      # HIVE
      - "9083:9083"
      - "10000:10000"
      # TEZ
      - "8188:8188"
      - "9999:9999"
      # HBASE
      - "16000:16000"
      - "16010:16010"
      - "16020:16020"
      - "16030:16030"
      # KAFKA BOOTSTRAP
      - "9092:9092"
      # CONFLUENT SCHEMA REGISTRY
      - "8081:8081"
      # KAFKA AVRO CONNECTOR
      - "8083:8083"
      # SPARK
      - "8090:8090"
      - "4040:4040"
      - "18080:18080"
      # FLINK
      - "6123:6123"
      - "8082:8082"

```
## Step2. Launch Docker Compose
```
docker compose up
```

## Step3. Check  Run Status

```
# docker ps
CONTAINER ID   IMAGE            COMMAND                   CREATED          STATUS                            PORTS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NAMES
c142ce36241f   bigdata-hadoop   "/usr/bin/bash /opt/…"   About an hour ago   Up 12 minutes (healthy)   localhost:2181->2181/tcp, localhost:2888->2888/tcp, localhost:3888->3888/tcp, localhost:4040->4040/tcp, localhost:6123->6123/tcp, localhost:8020->8020/tcp, localhost:8030-8033->8030-8033/tcp, localhost:8040-8042->8040-8042/tcp, localhost:8080-8083->8080-8083/tcp, localhost:8088->8088/tcp, localhost:8090->8090/tcp, localhost:8188->8188/tcp, localhost:8480->8480/tcp, localhost:8485->8485/tcp, localhost:9083->9083/tcp, localhost:9092->9092/tcp, localhost:9866->9866/tcp, localhost:9999-10000->9999-10000/tcp, localhost:10020->10020/tcp, localhost:16000->16000/tcp, localhost:16010->16010/tcp, localhost:16020->16020/tcp, localhost:16030->16030/tcp, localhost:18080->18080/tcp, localhost:19888->19888/tcp, localhost:50010->50010/tcp, localhost:50020->50020/tcp, localhost:50070->50070/tcp, localhost:50075->50075/tcp, localhost:50475->50475/tcp, localhost:1022->22/tcp   hadoop
```

## Step4. Add IP Host Route , Edit `/etc/hosts`
```shell
192.168.100.10 hadoop
```

## Container Compose List
```
root@localhost:/opt/run# ls -lrt /opt/run/
total 0
lrwxrwxrwx 1 root  root   23 May 28 16:19 jdk8 -> /opt/installs/jdk-8u312
lrwxrwxrwx 1 root  root   25 May 28 16:19 jdk11 -> /opt/installs/jdk-11.0.13
lrwxrwxrwx 1 root  root   13 May 28 16:19 jdk -> /opt/run/jdk8
lrwxrwxrwx 1 root  root   36 May 28 16:19 zookeeper -> /opt/installs/apache-zookeeper-3.7.1
lrwxrwxrwx 1 root  root   26 May 28 16:19 mysql -> /opt/installs/mysql-8.0.33
lrwxrwxrwx 1 root  root   25 May 28 16:20 scala -> /opt/installs/scala-3.2.2
lrwxrwxrwx 1 root  root   26 May 28 16:20 hadoop -> /opt/installs/hadoop-3.1.3
lrwxrwxrwx 1 hdfs  hadoop 34 May 28 16:20 tomcat -> /opt/installs/apache-tomcat-9.0.74
lrwxrwxrwx 1 hdfs  hadoop 24 May 28 16:20 tez -> /opt/installs/tez-0.10.1
lrwxrwxrwx 1 hdfs  hadoop 24 May 28 16:20 hive -> /opt/installs/hive-3.1.3
lrwxrwxrwx 1 hbase hadoop 25 May 28 16:20 hbase -> /opt/installs/hbase-1.4.9
lrwxrwxrwx 1 root  root   44 May 28 16:20 spark2 -> /opt/installs/spark-2.4.8-bin-without-hadoop
lrwxrwxrwx 1 root  root   39 May 28 16:20 spark3 -> /opt/installs/spark-3.2.4-bin-hadoop3.2
lrwxrwxrwx 1 spark hadoop 15 May 28 16:20 spark -> /opt/run/spark3
lrwxrwxrwx 1 flink hadoop 26 May 28 16:20 flink -> /opt/installs/flink-1.17.0
lrwxrwxrwx 1 root  root   30 May 28 16:20 kafka -> /opt/installs/kafka_2.12-2.6.3
lrwxrwxrwx 1 root  root   29 May 28 16:20 confluent -> /opt/installs/confluent-7.0.1
lrwxrwxrwx 1 root  root   28 May 28 16:20 debezium -> /opt/installs/debezium-1.9.4
```
