# syntax=docker/dockerfile:1
FROM debian:bookworm-slim AS mtproxy-builder
ARG MTPROXY_COMMIT=f36d8af769ffaeac36978d38c2c0f6d1104c2137
ARG MTPROXY_SHA256=919795c416b870670841a21d1930ad97a24c7b84b9eb8c6f9e3de32f2fdf4655
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl build-essential libssl-dev zlib1g-dev git && rm -rf /var/lib/apt/lists/*
WORKDIR /build
RUN curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 -o MTProxy.tar.gz "https://github.com/TelegramMessenger/MTProxy/archive/${MTPROXY_COMMIT}.tar.gz" \
 && echo "${MTPROXY_SHA256}  MTProxy.tar.gz" | sha256sum -c - \
 && tar --strip-components=1 -xzf MTProxy.tar.gz \
 && make -j"$(nproc)" \
 && test -x objs/bin/mtproto-proxy

FROM golang:1.23-bookworm AS tproxy-builder
ARG TPROXY_REPO=https://github.com/RTHeLL/tg-web-proxy.git
WORKDIR /src
RUN git clone --depth 1 --branch main "$TPROXY_REPO" .
RUN CGO_ENABLED=0 go test ./... && CGO_ENABLED=0 go build -trimpath -ldflags='-s -w' -o /tproxy-server ./cmd/tproxy-server

FROM debian:bookworm-slim
ARG CADDY_VERSION=2.11.4
ARG CADDY_SHA512=8220d1f013b6f27510247b2360c9e0ca9f018feebd82515f07635318b34ff9777ccc8fd0b6e6f2486ce3a33fe389fbb7db12d05baa474f4587509fb4f5ebf1c9
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl gettext-base netcat-openbsd git && rm -rf /var/lib/apt/lists/*
RUN curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 \
 -o /tmp/caddy.tar.gz "https://github.com/caddyserver/caddy/releases/download/v${CADDY_VERSION}/caddy_${CADDY_VERSION}_linux_amd64.tar.gz" \
 && echo "${CADDY_SHA512}  /tmp/caddy.tar.gz" | sha512sum -c - \
 && tar -C /usr/local/bin -xzf /tmp/caddy.tar.gz caddy \
 && rm -f /tmp/caddy.tar.gz

COPY --from=mtproxy-builder /build/objs/bin/mtproto-proxy /usr/local/bin/mtproto-proxy
COPY --from=tproxy-builder /tproxy-server /usr/local/bin/tproxy-server
COPY entrypoint.sh /entrypoint.sh
COPY config.template.json /etc/tproxy-server/config.template.json
COPY profiles.template.json /etc/tproxy-server/profiles.template.json
COPY Caddyfile.template /etc/caddy/Caddyfile.template
COPY site /srv/tproxy-site

RUN chmod +x /entrypoint.sh /usr/local/bin/mtproto-proxy /usr/local/bin/tproxy-server /usr/local/bin/caddy
ENV CARRIER_MODE=websocket BACKEND=mtproxy MTPROXY_WORKERS=1 MTPROXY_MAX_CONNECTIONS=4096
ENTRYPOINT ["/entrypoint.sh"]
