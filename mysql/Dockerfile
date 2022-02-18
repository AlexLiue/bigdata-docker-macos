FROM mysql/mysql-server:8.0.28

# Config files
COPY sources/config/my.cnf /etc/my.cnf.d
RUN echo '!includedir /etc/my.cnf.d' >>/etc/my.cnf

ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK CMD /healthcheck.sh
EXPOSE 3306 33060 33061
CMD ["mysqld"]
