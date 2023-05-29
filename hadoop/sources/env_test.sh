#!/bin/bash

## Test Hive ENV
/opt/run/hive/bin/beeline -u jdbc:hive2://hadoop:10000/default -nhive -phive_password -e"
create database test;
use test;
create table test.tbl_test(id int, name string, score int);
insert into test.tbl_test(id, name, score) values(1, 'tom', 80);
insert into test.tbl_test(id, name, score) values(2, 'tom', 81);
insert into test.tbl_test(id, name, score) values(3, 'lisa', 90);
insert into test.tbl_test(id, name, score) values(4, 'lisa', 91);
select name, sum(score) as total_score from test.tbl_test group by name;
"

# Test Hbase ENV
/opt/run/hbase/bin/hbase shell <<EOF
    create_namespace 'test'
    create 'test:tbl_test', 'f1', 'f2'
    describe 'test:tbl_test'
    put 'test:tbl_test', 'r1', 'f1:name', 'tom'
    put 'test:tbl_test', 'r1', 'f1:score', '80'
    put 'test:tbl_test', 'r2', 'f1:name', 'tom'
    put 'test:tbl_test', 'r2', 'f1:score', '81'
    put 'test:tbl_test', 'r3', 'f1:name', 'lisa'
    put 'test:tbl_test', 'r3', 'f1:score', '90'
    put 'test:tbl_test', 'r4', 'f1:name', 'lisa'
    put 'test:tbl_test', 'r4', 'f1:score', '91'
    scan 'test:tbl_test'
EOF



/opt/run/spark/bin/spark-sql --master yarn --packages org.apache.iceberg:iceberg-spark-runtime-3.2_2.12:1.2.0\
    --conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions \
    --conf spark.sql.catalog.spark_catalog=org.apache.iceberg.spark.SparkCatalog \
    --conf spark.sql.catalog.spark_catalog.type=hadoop \
    --conf spark.sql.catalog.spark_catalog.warehouse=hdfs://hadoop:8020/user/iceberg/warehouse <<EOF

    CREATE TABLE spark_catalog.iceberg.tbl_test (id bigint, name string, score int) USING iceberg;
    INSERT INTO spark_catalog.iceberg.tbl_test VALUES (1, 'tom', 80), (2, 'tom', 81), (3, 'lisa', 90), (4, 'lisa', 91);
    SELECT name, sum(score) as total_score  FROM  spark_catalog.iceberg.tbl_test GROUP BY name;

   SET iceberg.catalog.spark_catalog.type=hadoop;
   SET iceberg.catalog.spark_catalog.warehouse=hdfs://hadoop:8020/user/iceberg/warehouse;

   CREATE
   EXTERNAL TABLE iceberg.tbl_test
   STORED BY 'org.apache.iceberg.mr.hive.HiveIcebergStorageHandler'
   TBLPROPERTIES ('iceberg.catalog'='hadoop');


EOF



/opt/run/spark/bin/spark-shell --master yarn \
    --packages org.apache.iceberg:iceberg-spark-runtime-3.2_2.12:1.2.1,org.apache.iceberg:iceberg-hive-runtime:1.2.1 <<EOF

    spark.stop()

    val spark = org.apache.spark.sql.SparkSession.builder().
      master("local[3]").
      config("spark.sql.sources.partitionOverwriteMode", "dynamic").
      config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions").
      config("spark.sql.catalog.spark_catalog", "org.apache.iceberg.spark.SparkCatalog").
      config("spark.sql.catalog.spark_catalog.type", "hadoop").
      config("spark.sql.catalog.spark_catalog.warehouse", "hdfs://hadoop:8020/user/iceberg/warehouse").
      config("spark.sql.warehouse.dir", "hdfs://hadoop:8020/user/hive/warehouse").
      enableHiveSupport().
      appName("IcebergTest").getOrCreate()
    spark.sql("show databases").show


    spark.sql("select * from test.tbl_test").show
    val hiveDDL = """
      CREATE EXTERNAL TABLE iceberg.tbl_test
      STORED BY 'org.apache.iceberg.mr.hive.HiveIcebergStorageHandler'
      LOCATION 'hdfs://hadoop:8020/user/iceberg/warehouse/iceberg/tbl_test'
      TBLPROPERTIES ('iceberg.catalog'='hadoop');
    """
    spark.sql(hiveDDL)








EOF












