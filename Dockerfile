FROM alpine:3.5

################################################################################
# 1. SETUP GLIBC
#
################################################################################
# blatantly stolen from: https://github.com/frol/docker-alpine-glibc
#   Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
################################################################################
ENV LANG=C.UTF-8

RUN \
  ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
  ALPINE_GLIBC_PACKAGE_VERSION="2.25-r0" && \
  ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
  ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
  ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
  apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
  wget \
      "https://raw.githubusercontent.com/andyshinn/alpine-pkg-glibc/master/sgerrand.rsa.pub" \
      -O "/etc/apk/keys/sgerrand.rsa.pub" && \
  wget \
      "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
  apk add --no-cache \
      "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
  \
  rm "/etc/apk/keys/sgerrand.rsa.pub" && \
  /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
  echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
  \
  apk del glibc-i18n && \
  \
  rm "/root/.wget-hsts" && \
  apk del .build-dependencies && \
  rm \
      "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
################################################################################
# 2. SETUP SHINY
#    https://github.com/rstudio/shiny-server/wiki/Building-Shiny-Server-from-Source
################################################################################
  apk add --no-cache --virtual=.build-dependencies2 bash cmake gcc g++ git linux-headers R-dev python unzip && \
  cd /usr/local && \
  git clone https://github.com/rstudio/shiny-server.git && \
  mkdir -p /usr/local/shiny-server/tmp && \
  cd /usr/local/shiny-server/tmp && \
  PATH=$(pwd)/../bin:$PATH && \
  PYTHON=`which python` && \
  cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DPYTHON="$PYTHON" ../ && \
  make && \
  mkdir ../build && \
  (cd .. && ./bin/npm --python="$PYTHON" install) && \
  (cd .. && ./bin/node ./ext/node/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js --python="$PYTHON" rebuild) && \
  apk del .build-dependencies2
