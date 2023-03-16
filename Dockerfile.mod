## Buildstage ##
FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy as buildstage

# copy local files
COPY custom-cont-init.d/install-cert.sh /install-cert

RUN \
  chmod +x /install-cert && \
  mkdir -p \
    /root-layer && \
  mkdir -p \
    /root-layer/etc/cont-init.d && \
  cp /install-cert /root-layer/etc/cont-init.d/99-install-mitm && \
  mkdir -p \
    /root-layer/etc/s6-overlay/s6-rc.d/init-install-mitm/dependencies.d && \
  touch /root-layer/etc/s6-overlay/s6-rc.d/init-install-mitm/dependencies.d/init-mods && \
  mkdir -p \
    /root-layer/etc/s6-overlay/s6-rc.d/user/contents.d/ && \
  touch /root-layer/etc/s6-overlay/s6-rc.d/user/contents.d/install-mitm && \
  echo -n "/etc/s6-overlay/s6-rc.d/init-install-mitm/run" > /root-layer/etc/s6-overlay/s6-rc.d/init-install-mitm/up && \
  echo -n "oneshot" > /root-layer/etc/s6-overlay/s6-rc.d/init-install-mitm/type && \
  cp /install-cert /root-layer/etc/s6-overlay/s6-rc.d/init-install-mitm/run

## Single layer deployed image ##
FROM scratch

# Add files from buildstage
COPY --from=buildstage /root-layer/ /