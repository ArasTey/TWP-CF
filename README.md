# A-RTP — Railway Telegram WEB Proxy

A direct Railway service for the Telegram WEB Proxy proof-of-concept based on RTHeLL/tg-web-proxy.

This repository is intentionally **proxy-only**. There is no admin panel, FastAPI, Uvicorn, Python runtime, Railway API token UI, or provisioning dashboard.

## Railway

1. Create a Railway service from this GitHub repository.
2. Railway detects the root `Dockerfile`.
3. Generate a public Railway domain in Networking.
4. Add `TPROXY_SECRET` as a 32-character lowercase hexadecimal secret.
5. Redeploy.

Generate a secret locally:

```bash
openssl rand -hex 16
```

The service uses `RAILWAY_PUBLIC_DOMAIN` automatically when available. You can override it with `TPROXY_HOSTNAME`. Railway's public `$PORT` is terminated by Caddy and forwarded internally to the relay on `127.0.0.1:18080`; these ports are intentionally different to avoid a bind collision.

### Required variables

- `TPROXY_SECRET`: 32 lowercase hex characters.
- `TPROXY_HOSTNAME`: optional; defaults to Railway's public domain.

### Optional

- `CARRIER_MODE=websocket`
- `MTPROXY_WORKERS=1`
- `MTPROXY_MAX_CONNECTIONS=4096`
- `TPROXY_LISTEN=127.0.0.1:18080` (optional; keep private/internal)

## Important

This is a proof-of-concept WEB proxy implementation, not an official Telegram server product. The upstream project documents a reference deployment on a dedicated Linux host with public 80/443. Railway changes the edge/networking model, so actual Telegram compatibility must be tested on the deployed Railway domain.

No "unlimited" bandwidth is promised; Railway and the underlying service have resource limits.

## Upstream

https://github.com/RTHeLL/tg-web-proxy
