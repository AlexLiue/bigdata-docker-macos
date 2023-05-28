
# BigData Docker Env For MacOS M1 
大数据平台 Docker 集成基础环境(Hadoop, Spark, Hive, Flink, Kafka, Zookeeper, Debezium, Mysql), MacOS M1 环境.


###  Docker 运行示列
```shell
 > docker ps
CONTAINER ID   IMAGE             COMMAND                  CREATED         STATUS                   PORTS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                NAMES
761f0ac96d8e   bigdata_hadoop    "./entrypoint.sh"        2 minutes ago   Up 2 minutes (healthy)   0.0.0.0:4040->4040/tcp, 0.0.0.0:6123->6123/tcp, 0.0.0.0:8020->8020/tcp, 0.0.0.0:8030-8033->8030-8033/tcp, 0.0.0.0:8040-8042->8040-8042/tcp, 0.0.0.0:8082->8082/tcp, 0.0.0.0:8088->8088/tcp, 0.0.0.0:8090->8090/tcp, 0.0.0.0:8480->8480/tcp, 0.0.0.0:8485->8485/tcp, 0.0.0.0:9083->9083/tcp, 0.0.0.0:10000->10000/tcp, 0.0.0.0:10020->10020/tcp, 0.0.0.0:16000->16000/tcp, 0.0.0.0:16010->16010/tcp, 0.0.0.0:16020->16020/tcp, 0.0.0.0:16030->16030/tcp, 0.0.0.0:18080->18080/tcp, 0.0.0.0:19888->19888/tcp, 0.0.0.0:50010->50010/tcp, 0.0.0.0:50020->50020/tcp, 0.0.0.0:50070->50070/tcp, 0.0.0.0:50075->50075/tcp, 0.0.0.0:50475->50475/tcp, 0.0.0.0:1022->22/tcp   hadoop
917fc1be0613   bigdata_kafka     "./entrypoint.sh"        2 minutes ago   Up 2 minutes (healthy)   0.0.0.0:8081->8081/tcp, 0.0.0.0:8083->8083/tcp, 0.0.0.0:9092->9092/tcp                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               kafka
8a66ecb75149   bigdata_mysql     "/entrypoint.sh mysq…"   2 minutes ago   Up 2 minutes (healthy)   0.0.0.0:3306->3306/tcp, 0.0.0.0:33060-33061->33060-33061/tcp                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         mysql
dbee109f50b6   zookeeper:3.5.9   "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes             0.0.0.0:2181->2181/tcp, 0.0.0.0:2888->2888/tcp, 0.0.0.0:3888->3888/tcp, 0.0.0.0:8080->8080/tcp                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       zoo
```
### 环境IP地址总汇
- `mysql`: 192.168.100.10  
- `zoo`: 192.168.100.20
- `kafka`: 192.168.100.30  
- `hadoop`: 192.168.100.60

### Hadoop 环境
```shell
root@hadoop:/opt/run# ls -lrt
total 0
lrwxrwxrwx 1 root root 23 Feb 17 14:58 jdk8 -> /opt/installs/jdk-8u312
lrwxrwxrwx 1 root root 25 Feb 17 14:58 jdk11 -> /opt/installs/jdk-11.0.13
lrwxrwxrwx 1 root root 13 Feb 17 14:58 jdk -> /opt/run/jdk8
lrwxrwxrwx 1 root root 26 Feb 17 14:58 hadoop -> /opt/installs/hadoop-2.7.5
lrwxrwxrwx 1 root root 25 Feb 17 14:58 hbase -> /opt/installs/hbase-1.4.9
lrwxrwxrwx 1 root root 24 Feb 17 14:58 hive -> /opt/installs/hive-3.1.1
lrwxrwxrwx 1 root root 39 Feb 17 14:58 spark2 -> /opt/installs/spark-2.4.8-bin-hadoop2.7
lrwxrwxrwx 1 root root 39 Feb 17 14:59 spark3 -> /opt/installs/spark-3.1.2-bin-hadoop2.7
lrwxrwxrwx 1 root root 15 Feb 17 14:59 spark -> /opt/run/spark3
lrwxrwxrwx 1 root root 26 Feb 17 14:59 flink -> /opt/installs/flink-1.14.3
```

### Kafka 环境
```shell
root@hadoop:/opt/run# ls -rlt
total 0
lrwxrwxrwx 1 root root 31 Feb 17 07:18 jdk8 -> /opt/installs/openjdk-8u312-b07
lrwxrwxrwx 1 root root 13 Feb 17 07:18 jdk -> /opt/run/jdk8
lrwxrwxrwx 1 root root 30 Feb 17 07:18 kafka -> /opt/installs/kafka_2.12-2.6.3
lrwxrwxrwx 1 root root 29 Feb 17 07:18 confluent -> /opt/installs/confluent-7.0.1
lrwxrwxrwx 1 root root 28 Feb 17 07:18 debezium -> /opt/installs/debezium-1.8.0
```

### 清理 Docker 所有内容
```shell
docker system prune --all --volumes 
```
### Rebuild 重新编译

```shell
docker compose stop hadoop
docker rm hadoop
docker rmi bigdata-hadoop



docker compose stop presto
docker rm presto
docker compose stop hadoop
docker rm hadoop
docker compose stop kafka
docker rm kafka
docker compose stop zoo
docker rm zoo
docker compose stop mysql
docker rm mysql



docker compose up -d hadoop




docker rmi bigdata_kafka
docker rmi bigdata-mysql
docker rmi bigdata_redis
docker rmi bigdata_presto
docker rmi bigdata-hadoop

docker compose up -d

```



create table tbl_test(id int, name string);
insert into tbl_test(id,name) values(1,'a');
insert into tbl_test(id,name) values(2,'b');
insert into tbl_test(id,name) values(3,'c');
select * from default.tbl_test;
select sum(id) from default.tbl_test;


### 目录结构 
```text
bigdata
├── README.md
├── bigdata-docker.iml
├── docker-compose.yml
├── hadoop
│   ├── Dockerfile
│   └── sources
│       ├── configs
│       │   ├── hadoop
│       │   │   ├── core-site.xml
│       │   │   ├── hdfs-site.xml
│       │   │   └── yarn-site.xml
│       │   ├── hbase
│       │   │   └── hbase-site.xml
│       │   └── hive
│       │       ├── hive-env.sh
│       │       └── hive-site.xml
│       ├── entrypoint.sh
│       ├── healthcheck.sh
│       ├── install.sh
│       └── packages
│           ├── OpenJDK11U-jdk_aarch64_linux_11.0.13_8.tar.gz
│           ├── OpenJDK8U-jdk_aarch64_linux_8u312b07.tar.gz
│           ├── apache-hive-3.1.1-bin.tar.gz
│           ├── flink-1.14.3-bin-scala_2.11.tgz
│           ├── hadoop-2.7.5.tar.gz
│           ├── hbase-1.4.9-bin.tar.gz
│           ├── libs
│           │   └── mysql-connector-java-8.0.28.jar
│           ├── spark-2.4.8-bin-hadoop2.7.tgz
│           └── spark-3.1.2-bin-hadoop2.7.tgz
├── kafka
│   ├── Dockerfile
│   └── sources
│       ├── config
│       │   ├── connect-avro-distributed.properties
│       │   ├── connect-instances
│       │   │   ├── db_gb18030_test.json
│       │   │   ├── db_gbk_test.json
│       │   │   └── db_utf8_test.json
│       │   ├── connect-json-distributed.properties
│       │   └── server.properties
│       ├── entrypoint.sh
│       ├── example
│       │   ├── create_test_table.sh
│       │   └── example.sh
│       ├── healthcheck.sh
│       ├── install.sh
│       └── packages
│           ├── OpenJDK8U-jdk_aarch64_linux_8u312b07.tar.gz
│           ├── confluent-community-7.0.1.tar.gz
│           ├── debezium-connector-mysql-1.8.0.Final-plugin.tar.gz
│           └── kafka_2.12-2.6.3.tgz
└── mysql
    ├── Dockerfile
    └── sources
        └── config
            └── my.cnf
```
###  进入容器
```shell
docker exec -it bigdata bash 
```

### 启动 & 停止  
```shell
docker compose up
docker-compose stop
```

### 查询网络
```shell
docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
bbc5355eeded   bridge    bridge    local
7de317fed643   host      host      local
7b2b36c2cc6c   none      null      local

docker network inspect bridge
[
    {
        "Name": "bridge"
    }
]


 docker network rm cd88a6fb7584
 docker network rm 37d600a17aa4
 
cd88a6fb7584   bigdata_bridge-net   bridge    local
37d600a17aa4   bigdata_default      bridge    local
19b9116def54   bridge               bridge    local


```

### 查询 volume
```shell
docker volume ls
DRIVER    VOLUME NAME
```


## Mysql GTID 设置查询

```shell
show variables like 'log_bin';
```



## Hive 

```shell
beeline -u jdbc:hive2://hadoop:10000/default -nhive -phive

```

### Presto

```shell
docker rm presto
docker rmi bigdata_presto


presto-cli --server hadoop:8080 --catalog hive --schema test


git clone https://github.com/prestodb/presto prestodb

/opt/run/hive/bin/beeline -u jdbc:hive2://hadoop:10000/default -nhive -phive

 hive --hiveconf hive.root.logger=DEBUG,console

```



## 问题说明
```text
HDFS  需要 开放 9866 端口,否则会报错
23/05/09 10:57:31 DEBUG DataStreamer: pipeline = [DatanodeInfoWithStorage[hadoop:9866,DS-a5440298-d121-4b60-af50-ff5c1e028305,DISK]], blk_1073741942_1118
23/05/09 10:57:31 DEBUG DataStreamer: Connecting to datanode hadoop:9866
23/05/09 10:57:31 WARN DataStreamer: Exception in createBlockOutputStream blk_1073741942_1118
java.net.ConnectException: Connection refused
	at sun.nio.ch.SocketChannelImpl.checkConnect(Native Method)
	at sun.nio.ch.SocketChannelImpl.finishConnect(SocketChannelImpl.java:716)
	at org.apache.hadoop.net.SocketIOWithTimeout.connect(SocketIOWithTimeout.java:206)
	at org.apache.hadoop.net.NetUtils.connect(NetUtils.java:586)
	at org.apache.hadoop.hdfs.DataStreamer.createSocketForPipeline(DataStreamer.java:253)
	at org.apache.hadoop.hdfs.DataStreamer.createBlockOutputStream(DataStreamer.java:1757)
	at org.apache.hadoop.hdfs.DataStreamer.nextBlockOutputStream(DataStreamer.java:1711)
	at org.apache.hadoop.hdfs.DataStreamer.run(DataStreamer.java:707)
org.apache.hadoop.ipc.RemoteException(java.io.IOException): File /user/hdfs/.sparkStaging/application_1683539618806_0010/__spark_conf__.zip could only be written to 0 of the 1 minReplication nodes. There are 1 datanode(s) running and 1 node(s) are excluded in this operation.
	at org.apache.hadoop.hdfs.server.blockmanagement.BlockManager.chooseTarget4NewBlock(BlockManager.java:2205)
	at org.apache.hadoop.hdfs.server.namenode.FSDirWriteFileOp.chooseTargetForNewBlock(FSDirWriteFileOp.java:294)

```
