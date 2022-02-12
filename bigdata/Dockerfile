FROM ubuntu:20.04

MAINTAINER "pcliu"

WORKDIR /opt
ADD sources /tmp/sources
ADD sources/*.sh /opt

RUN ["sh", "/opt/entrypoint.sh"]
ENTRYPOINT ["tail", "-f", "/dev/null"]

