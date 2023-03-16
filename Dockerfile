FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

ARG MITMPROXY_RELEASE

# set version label
LABEL maintainer="roxedus"

# global environment settings
ENV DEBIAN_FRONTEND="noninteractive"


RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y \
    iptables && \
  echo "**** install mitmproxy ****" && \
  if [ -z ${MITMPROXY_RELEASE+x} ]; then \
    MITMPROXY_RELEASE=$(curl -sX GET https://api.github.com/repos/mitmproxy/mitmproxy/releases/latest \
      | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
  fi && \
  mkdir -p /app/mitmproxy && \
  curl -o \
    /tmp/mitmproxy.tar.gz -L \
        "https://snapshots.mitmproxy.org/${MITMPROXY_RELEASE}/mitmproxy-${MITMPROXY_RELEASE}-linux.tar.gz" && \
  tar xf /tmp/mitmproxy.tar.gz -C \
    /app/mitmproxy  && \
  chmod +x /app/mitmproxy/mitmdump /app/mitmproxy/mitmproxy /app/mitmproxy/mitmweb && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 42070/tcp 42069/tcp
VOLUME /mitm