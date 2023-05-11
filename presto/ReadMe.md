
## Presto 查询 Hive Iceberg 表数据
```shell

bash-4.2#  /opt/presto-cli --server localhost:8080 --catalog iceberg --schema db_test
presto:db_test> show tables;
  Table
----------
 tbl_test
(1 row)

Query 20230511_100505_00005_ui6q9, FINISHED, 1 node
Splits: 19 total, 19 done (100.00%)
0:39 [1 rows, 25B] [0 rows/s, 0B/s]

presto:db_test> select * from tbl_test;
 id | name | age |        _op_date         | _op_type
----+------+-----+-------------------------+----------
  1 | Zena |  20 | 2023-01-01 02:10:10.000 | r
  2 | lisa |  21 | 2023-01-01 02:10:12.000 | r
  3 | tom  |  22 | 2023-01-01 02:10:13.000 | r
(3 rows)

Query 20230511_100552_00007_ui6q9, FINISHED, 1 node
Splits: 17 total, 17 done (100.00%)
0:12 [3 rows, 1.79KB] [0 rows/s, 152B/s]

presto:db_test> select name,avg(age)  from db_test.tbl_test group by name order by name desc;
 name | _col1
------+-------
 tom  |  22.0
 lisa |  21.0
 Zena |  20.0
(3 rows)

Query 20230511_100816_00008_ui6q9, FINISHED, 1 node
Splits: 51 total, 51 done (100.00%)
0:20 [3 rows, 1.57KB] [0 rows/s, 80B/s]

presto:db_test>
```