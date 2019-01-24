# vim: set noexpandtab ts=4 sw=4 nolist:

FROM postgres:11-alpine

RUN apk add --no-cache --update py2-pip
RUN pip install awscli

COPY docker-entrypoint.sh /usr/local/bin/
COPY backup.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["run-cron"]
