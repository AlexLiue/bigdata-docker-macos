#!/bin/bash
## Create by PcLiu at 2023/05/01


chmod 755 /opt/*.sh

SLEEP_SECOND=5

wait_for() {
  echo "Waiting $3" started, waiting for "$1" to listen on "$2"...
  while ! nc -z "$1" "$2"; do echo waiting...; sleep "$SLEEP_SECOND"; done
}


yum install -y net-tools telnet procps





