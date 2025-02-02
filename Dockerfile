FROM php:7.1-fpm-alpine
LABEL maintainer="Simon Erhardt <hello@rootlogin.ch>"

ARG ZPUSH_URL=http://download.z-push.org/final/2.3/z-push-2.3.9.tar.gz
ARG ZPUSH_CSUM=07290996f00b988a95ff66932d2b8127
ARG UID=1513
ARG GID=1513

ENV TZ=Europe/Zurich \
  IMAP_SERVER=localhost \
  IMAP_PORT=143 \
  SMTP_SERVER=localhost \
  SMTP_PORT=25

ADD root /

RUN set -ex \

  # Install important stuff
  && apk add --update --no-cache \
  alpine-sdk \
  autoconf \
  bash \
  imap \
  imap-dev \
  nginx \
  openssl \
  openssl-dev \
  pcre \
  pcre-dev \
  supervisor \
  tar \
  tini \
  wget \

  # Install confd
  && wget -q -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.13.0/confd-0.13.0-linux-amd64 \
  && chmod +x /usr/local/bin/confd \

  # Install php
  && docker-php-ext-configure imap --with-imap --with-imap-ssl \
  && docker-php-ext-install imap pcntl sysvmsg sysvsem sysvshm \
  && pecl install APCu-5.1.8 \
  && docker-php-ext-enable apcu \

  # Remove dev packages
  && apk del --no-cache \
  alpine-sdk \
  autoconf \
  openssl-dev \
  pcre-dev \

  # Add user for z-push
  && addgroup -g ${GID} zpush \
  && adduser -u ${UID} -h /opt/zpush -H -G zpush -s /sbin/nologin -D zpush \
  && mkdir -p /opt/zpush \

  # Install z-push
  && wget -q -O /tmp/zpush.tgz "$ZPUSH_URL" \
  && tar -zxf /tmp/zpush.tgz -C /opt/zpush --strip-components=1 \
  && rm /tmp/zpush.tgz \
  && chmod +x /usr/local/bin/docker-run.sh

VOLUME ["/data"]
EXPOSE 80

ENTRYPOINT ["/sbin/tini", "--"]
CMD /usr/local/bin/docker-run.sh
