ARG DEBIAN_REL

FROM debian:${DEBIAN_REL}-slim as builder

ARG ROCKY_REL
ARG BIND_VER

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ca-certificates \
  wget \
  build-essential \
  libssl-dev \
  libuv1-dev \
  libnghttp2-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN wget https://ftp.iij.ad.jp/pub/network/isc/bind9/${BIND_VER}/bind-${BIND_VER}.tar.xz
RUN tar xf bind-${BIND_VER}.tar.xz

WORKDIR bind-${BIND_VER}
RUN ./configure --prefix=/usr/local/bind-${BIND_VER} \
 --disable-geoip --enable-doh --disable-linux-caps --disable-dnstap \
 && make -j12 && make install

RUN cd /usr/local/bind-${BIND_VER} \
 && strip -g bin/dig bin/delv lib/lib*.so \
 && rm -r lib/*.la lib/bind/

FROM debian:${DEBIAN_REL}-slim

ARG BIND_VER

LABEL maintainer="Mitsuru Shimamura <smbd.jp@gmail.com>" \
      org.opencontainers.image.title="smbd/dig" \
      org.opencontainers.image.version=${BIND_VER} \
      org.opencontainers.image.authors="Mitsuru Shimamura" \
      org.opencontainers.image.vendor="Mitsuru Shimamura" \
      org.opencontainers.image.description="dig and delv from BIND9" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.url="https://github.com/smbd/docker-debian-dig" \
      org.opencontainers.image.source="https://github.com/smbd/docker-debian-dig/blob/main/Dockerfile"

ENV LD_LIBRARY_PATH=/usr/local/bind-${BIND_VER}/lib

COPY --from=builder /usr/local/bind-${BIND_VER}/lib/  /usr/local/bind-${BIND_VER}/lib/
COPY --from=builder /usr/local/bind-${BIND_VER}/bin/dig /usr/local/bind-${BIND_VER}/bin/
COPY --from=builder /usr/local/bind-${BIND_VER}/bin/delv /usr/local/bind-${BIND_VER}/bin/

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  openssl \
  libuv1 \
  libnghttp2-14 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN for command in dig delv ; do ln -s /usr/local/bind-${BIND_VER}/bin/${command} /usr/local/bin/${command} ; done

ENTRYPOINT ["/usr/local/bin/dig"]
