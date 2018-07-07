FROM python:3-alpine3.7

ENV DEHYDRATED_VERSION 0.6.2

WORKDIR /opt
RUN apk add --no-cache bash curl libressl git tar wget \
  && wget -q -O dehydrated.tar.gz "https://github.com/lukas2511/dehydrated/releases/download/v$DEHYDRATED_VERSION/dehydrated-$DEHYDRATED_VERSION.tar.gz" \
  && tar xf dehydrated.tar.gz "dehydrated-$DEHYDRATED_VERSION/dehydrated" \
  && rm -f dehydrated.tar.gz \
  && apk del --no-cache git tar wget \
  && mkdir -p /etc/dehydrated /acme /certs

VOLUME /acme
VOLUME /certs

ENV PATH "/opt/dehydrated-$DEHYDRATED_VERSION:${PATH}"

COPY config /etc/dehydrated/config
COPY script.sh /usr/local/bin/script.sh

CMD ["/usr/local/bin/script.sh"]
