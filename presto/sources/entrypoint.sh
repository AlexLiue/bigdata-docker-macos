#!/usr/bin/bash

set -e

rm -rf /var/lib/presto/data/var/log/*

/opt/presto-server/bin/launcher start

tail -f /var/lib/presto/data/var/log/*





