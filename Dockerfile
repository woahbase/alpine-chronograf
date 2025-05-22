# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
ARG SRCARCH
ARG VERSION
#
ENV \
    BASE_PATH=/chronograf \
    BOLT_PATH=/var/lib/chronograf/chronograf-v1.db \
    CANNED_PATH=/usr/share/chronograf/canned \
    PROTOBOARDS_PATH=/usr/share/chronograf/protoboards \
    REPORTING_DISABLED=true \
    RESOURCES_PATH=/usr/share/chronograf/resources
#
RUN set -xe \
    && apk add -Uu --purge --no-cache \
        curl \
        ca-certificates \
    && update-ca-certificates \
#
    # && curl \
    #     -o /tmp/chronograf.tar.gz \
    #     -jSLN https://dl.influxdata.com/chronograf/releases/chronograf-${VERSION}-static_${SRCARCH}.tar.gz \
    # # && tar xzf /tmp/chronograf.tar.gz -C /tmp \
    # # && cp -r /tmp/chronograf-${VERSION}-1/* / \
    # && tar xzf /tmp/chronograf.tar.gz -C /usr/local/bin --strip 2 \
    # && chmod +x /usr/local/bin/chrono* \
#
    && curl \
        -o /tmp/chronograf.tar.gz \
        -jSLN https://dl.influxdata.com/chronograf/releases/chronograf-${VERSION}_${SRCARCH}.tar.gz \
    && tar xzf /tmp/chronograf.tar.gz -C / --strip 2 \
    && chmod +x \
        /usr/bin/chronograf \
        /usr/bin/chronoctl \
#
    && apk del --purge curl \
    && rm -rf /var/cache/apk/* /tmp/*
#
COPY root/ /
#
VOLUME  ["/usr/share/chronograf", "/var/lib/chronograf", "/var/log/chronograf"]
#
EXPOSE 8888
#
HEALTHCHECK \
    --interval=2m \
    --retries=5 \
    --start-period=5m \
    --timeout=10s \
    CMD \
    wget --quiet --tries=1 --no-check-certificate --spider ${HEALTHCHECK_URL:-"http://localhost:8888$BASE_PATH"} || exit 1
#
ENTRYPOINT ["/init"]
