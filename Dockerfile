# syntax=docker/dockerfile:1

ARG DEBIAN_REL=bookworm
FROM debian:${DEBIAN_REL}-slim

ARG DEBIAN_REL
ARG BIND_VER=9.20.5

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get -qq update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests ca-certificates wget \
    && wget -q -O /usr/share/keyrings/bind.gpg https://bind.debian.net/bind/apt.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/bind.gpg] https://bind.debian.net/bind ${DEBIAN_REL} main" > /etc/apt/sources.list.d/bind9.list \
    && apt-get -qq update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests "?and(?name(^bind9-dnsutils$), ?version(${BIND_VER}-))" \
    && apt-get purge --autoremove -y wget

ENTRYPOINT ["/usr/bin/dig"]
