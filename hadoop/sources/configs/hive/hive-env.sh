# Hive Client memory usage can be an issue if a large number of clients
# are running at the same time. The flags below have been useful in
# reducing memory usage:
#
 if [ "$SERVICE" = "cli" ]; then
   if [ -z "$DEBUG" ]; then
     export HADOOP_OPTS="$HADOOP_OPTS -XX:NewRatio=12 -Xms10m -XX:MaxHeapFreeRatio=40 -XX:MinHeapFreeRatio=15 -XX:+UseParNewGC -XX:-UseGCOverheadLimit"
   else
     export HADOOP_OPTS="$HADOOP_OPTS -XX:NewRatio=12 -Xms10m -XX:MaxHeapFreeRatio=40 -XX:MinHeapFreeRatio=15 -XX:-UseGCOverheadLimit"
   fi
 fi

# The heap size of the jvm stared by hive shell script can be controlled via:
export HADOOP_HEAPSIZE=1024

# Set HADOOP_HOME to point to a specific hadoop install directory
# shellcheck disable=SC2034
HADOOP_HOME=/opt/run/hadoop

# Hive Configuration Directory can be controlled by:
export HIVE_CONF_DIR=/opt/run/hive/conf

# Folder containing extra libraries required for hive compilation/execution can be controlled by:
# export HIVE_AUX_JARS_PATH=

export JAVA_HOME=/opt/run/jdk


export TEZ_HOME=/opt/run/tez
export TEZ_CONF_DIR=/opt/run/hive/conf
mapfile -t TEZ_JARS_FILES < <(find "$TEZ_HOME/" -type f -name  '*.jar')
TEZ_JARS=$(IFS=:; echo "${TEZ_JARS_FILES[*]}")

export HIVE_AUX_JARS_PATH=$TEZ_JARS


## shellcheck disable=SC2006
#export HADOOP_CLASSPATH=`/opt/run/hadoop/bin/hadoop classpath`
#export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:${TEZ_CONF_DIR}:${TEZ_HOME}/*:${TEZ_HOME}/lib/*
#









