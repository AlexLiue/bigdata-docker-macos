FROM ubuntu:20.04

WORKDIR /opt
ADD sources /opt/sources
ADD sources/*.sh /opt

RUN ["sh", "/opt/install.sh"]

HEALTHCHECK CMD /opt/healthcheck.sh
ENTRYPOINT ["./entrypoint.sh"]

