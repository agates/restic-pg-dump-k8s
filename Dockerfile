FROM docker.io/restic/restic:0.16.4

RUN apk update \
    && apk upgrade \
    && apk add \
        bash \
        postgresql-client \
    && apk add --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main \
        util-linux \
    && rm -rf /var/cache/apk/*

ENV PATH="$PATH:/opt/restic-pg-dump/bin"

COPY . /opt/restic-pg-dump/
WORKDIR /opt/restic-pg-dump/

ENTRYPOINT ["/opt/restic-pg-dump/bin/entrypoint.sh"]
CMD ["backup.sh"]