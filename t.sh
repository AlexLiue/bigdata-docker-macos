#!/bin/bash
## Check Zookeeper Status

#set -x
SLEEP_SECOND=2
DEPENDS=("zoo:2181")

wait_for() {
    echo Waiting for "$1" to listen on "$2"...
    while ! nc -z "$1" "$2"; do echo waiting...; sleep "$SLEEP_SECOND"; done
}

for var in ${DEPENDS[*]}
do
    host=${var%:*}
    port=${var#*:}
    echo "$host"-"$port"
done
