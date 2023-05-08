FROM ahanaio/prestodb-sandbox:0.275

EXPOSE 8080

WORKDIR /opt
ADD sources /opt/sources
ADD sources/*.sh /opt/

RUN /usr/bin/bash /opt/install.sh 2>&1 | tee /opt/install.log

HEALTHCHECK CMD /opt/healthcheck.sh

ENTRYPOINT ["/opt/entrypoint.sh"]







