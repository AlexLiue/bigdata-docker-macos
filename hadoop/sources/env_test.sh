#!/bin/bash

## Test Hive ENV
/opt/run/hive/bin/beeline -u jdbc:hive2://0.0.0.0:10000/default -nhive -phive_password -e"
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
