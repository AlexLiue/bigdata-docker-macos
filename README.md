
# BigData Docker Env For MacOS M1 
大数据平台 Docker 集成基础环境(Hadoop, Spark, Hive, Flink, Kafka, Zookeeper, Debezium, Mysql), MacOS M1 环境.

### 清理 Docker 所有内容
```shell
docker system prune --all --volumes 
```
### Rebuild 重新编译

```shell
docker compose stop 
docker rm bigdata
docker rm mysql
docker rmi bigdata:1.0
docker rmi mysql:1.0
docker compose up -d
docker logs -f bigdata

docker compose stop 
docker compose up 
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

### 安装说明

