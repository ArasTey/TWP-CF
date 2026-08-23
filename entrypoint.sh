#!/bin/sh
set -eu

log() { printf '[A-RTP] %s\n' "$1" >&2; }

HOST="${TPROXY_HOSTNAME:-${RAILWAY_PUBLIC_DOMAIN:-}}"
if [ -z "$HOST" ]; then
  echo "Missing TPROXY_HOSTNAME and RAILWAY_PUBLIC_DOMAIN" >&2
  exit 1
fi
if [ -z "${PORT:-}" ]; then
  PORT=8080
fi
TPROXY_LISTEN="${TPROXY_LISTEN:-127.0.0.1:18080}"
export PORT TPROXY_LISTEN
SECRET="${TPROXY_SECRET:-}"
if [ -z "$SECRET" ]; then
  echo "Missing TPROXY_SECRET. Generate with: openssl rand -hex 16" >&2
  exit 1
fi
case "$SECRET" in
  *[!0-9a-fA-F]*)
    echo "TPROXY_SECRET must be exactly 32 hexadecimal characters" >&2
    exit 1 ;;
esac
[ "${#SECRET}" -eq 32 ] || { echo "TPROXY_SECRET must be exactly 32 hexadecimal characters" >&2; exit 1; }

: "${CARRIER_MODE:=websocket}"
: "${MTPROXY_WORKERS:=1}"
: "${MTPROXY_MAX_CONNECTIONS:=4096}"

mkdir -p /etc/mtproxy /etc/tproxy-server /etc/caddy /srv/tproxy-site

if [ ! -f /etc/mtproxy/proxy-secret ]; then
  curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 \
    -o /etc/mtproxy/proxy-secret https://core.telegram.org/getProxySecret
fi
if [ ! -f /etc/mtproxy/proxy-multi.conf ]; then
  curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 \
    -o /etc/mtproxy/proxy-multi.conf https://core.telegram.org/getProxyConfig
fi
chmod 0640 /etc/mtproxy/proxy-secret /etc/mtproxy/proxy-multi.conf

export TPROXY_HOSTNAME="$HOST" TPROXY_SECRET="$SECRET" CARRIER_MODE TPROXY_LISTEN PORT
envsubst '${TPROXY_HOSTNAME} ${TPROXY_LISTEN}' < /etc/tproxy-server/config.template.json > /etc/tproxy-server/config.json
envsubst '${TPROXY_SECRET} ${CARRIER_MODE}' < /etc/tproxy-server/profiles.template.json > /etc/tproxy-server/profiles.json
cp /etc/caddy/Caddyfile.template /etc/caddy/Caddyfile

# Fail fast if template expansion did not happen. This prevents a Railway
# restart loop caused by literal ${...} placeholders reaching tproxy-server.
if grep -qE '\$\{TPROXY_(HOSTNAME|LISTEN)\}|\$\{TPROXY_SECRET\}|\$\{CARRIER_MODE\}' /etc/tproxy-server/config.json /etc/tproxy-server/profiles.json; then
  echo "Template expansion failed: unresolved A-RTP variables remain" >&2
  exit 1
fi

chmod 0640 /etc/tproxy-server/config.json
chmod 0400 /etc/tproxy-server/profiles.json

log "hostname=$HOST port=$PORT carrier=$CARRIER_MODE"
log "starting official MTProxy backend on 127.0.0.1:2398"
mtproto-proxy -u nobody -p 8888 -H 2398 -S "$SECRET" \
  --aes-pwd /etc/mtproxy/proxy-secret \
  /etc/mtproxy/proxy-multi.conf \
  -M "$MTPROXY_WORKERS" -C "$MTPROXY_MAX_CONNECTIONS" &
BACKEND_PID=$!
RELAY_PID=""

cleanup() {
  [ -z "$RELAY_PID" ] || kill "$RELAY_PID" 2>/dev/null || true
  [ -z "$BACKEND_PID" ] || kill "$BACKEND_PID" 2>/dev/null || true
  [ -z "$RELAY_PID" ] || wait "$RELAY_PID" 2>/dev/null || true
  [ -z "$BACKEND_PID" ] || wait "$BACKEND_PID" 2>/dev/null || true
}
trap cleanup INT TERM EXIT

i=0
while ! nc -z 127.0.0.1 2398 2>/dev/null; do
  i=$((i+1)); [ "$i" -lt 90 ] || { echo "MTProxy backend failed to start" >&2; exit 1; }
  sleep 1
done

log "starting tproxy-server"
tproxy-server -config /etc/tproxy-server/config.json -profiles-file /etc/tproxy-server/profiles.json &
RELAY_PID=$!

i=0
until curl --fail --silent http://127.0.0.1:8081/readyz >/dev/null 2>&1; do
  i=$((i+1)); [ "$i" -lt 60 ] || { echo "tproxy-server did not become ready" >&2; exit 1; }
  sleep 1
done

log "relay ready; starting Caddy on :$PORT -> $TPROXY_LISTEN"
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
