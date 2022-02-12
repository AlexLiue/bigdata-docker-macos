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
HADOOP_HOME=/opt/run/hadoop

# Hive Configuration Directory can be controlled by:
 export HIVE_CONF_DIR=/opt/run/hadoop/hive/conf

# Folder containing extra libraries required for hive compilation/execution can be controlled by:
# export HIVE_AUX_JARS_PATH=

export JAVA_HOME=/opt/run/jdk