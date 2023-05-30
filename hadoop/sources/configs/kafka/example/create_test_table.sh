## For Kafka Connector
set -x

mysql -hhadoop -uroot -proot_password <<EOF
  CREATE DATABASE IF NOT EXISTS db_utf8_test;
  CREATE DATABASE IF NOT EXISTS db_gbk_test;
  CREATE DATABASE IF NOT EXISTS db_gb18030_test;
EOF

## Init Test Data
mysql -hhadoop -uroot -proot_password <<EOF
  USE db_utf8_test;
  CREATE TABLE tbl_test_1 (
    ID int NOT NULL AUTO_INCREMENT,
    C1 varchar(45) DEFAULT NULL,
    C2 varchar(45) NOT NULL DEFAULT 'CV2',
    C3 int DEFAULT NULL,
    C4 bigint DEFAULT NULL,
    CREATE_TIME datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (ID)
  ) ENGINE=InnoDB DEFAULT CHARSET=gb18030 COLLATE=gb18030_bin;
  INSERT INTO tbl_test_1 (C1, C2, C3, C4) VALUES ('v1', 'v2', '1', '12');
EOF

mysql -hhadoop -uroot -proot_password <<EOF
  USE db_gbk_test;
  CREATE TABLE tbl_test_1 (
    ID int NOT NULL AUTO_INCREMENT,
    C1 varchar(45) DEFAULT NULL,
    C2 varchar(45) NOT NULL DEFAULT 'CV2',
    C3 int DEFAULT NULL,
    C4 bigint DEFAULT NULL,
    CREATE_TIME datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (ID)
  ) ENGINE=InnoDB DEFAULT CHARSET=gb18030 COLLATE=gb18030_bin;
  INSERT INTO tbl_test_1 (C1, C2, C3, C4) VALUES ('v1', 'v2', '1', '12');
EOF

mysql -hhadoop -uroot -proot_password <<EOF
  USE db_gb18030_test;
  CREATE TABLE tbl_test_1 (
    ID int NOT NULL AUTO_INCREMENT,
    C1 varchar(45) DEFAULT NULL,
    C2 varchar(45) NOT NULL DEFAULT 'CV2',
    C3 int DEFAULT NULL,
    C4 bigint DEFAULT NULL,
    CREATE_TIME datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UPDATE_TIME datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (ID)
  ) ENGINE=InnoDB DEFAULT CHARSET=gb18030 COLLATE=gb18030_bin;
  INSERT INTO tbl_test_1 (C1, C2, C3, C4) VALUES ('v1', 'v2', '1', '12');
EOF

mysql -hhadoop -uroot -proot_password <<EOF
  CREATE USER salve IDENTIFIED  WITH mysql_native_password BY 'salve_password';
  ALTER USER 'salve'@'%' IDENTIFIED WITH mysql_native_password BY 'salve_password';
  GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'salve'@'%';
  FLUSH PRIVILEGES;

EOF