# TWP-CF Deployer — Account Error Diagnostics

Single-file Cloudflare Worker deployer. Paste `TWP-CF-DEPLOYER.js` into a Cloudflare Worker and deploy it.

## Error handling included
- Shows readable explanations for invalid/expired API tokens, insufficient permissions, account scope/access problems, workers.dev setup, duplicate Worker names, Durable Object/SQLite provisioning, rate/resource limits, billing restrictions, and network errors.
- Displays Cloudflare's original error text, HTTP status, and returned Cloudflare error code when available.
- Gives a next step the user can follow rather than only showing a generic “failed” message.
- Applies to token verification, deployment, worker deletion, and API requests made by the UI.
- Never displays or logs the submitted API token in the error message.

## Important
This is client-side diagnosis based on the HTTP status and text returned by Cloudflare. It cannot inspect account settings directly or guarantee the precise cause when Cloudflare returns an ambiguous error. The original API error is retained so support can diagnose cases that do not match a known category.

## Deploy
1. Open Cloudflare Dashboard → Workers & Pages.
2. Create or open the TWP-CF deployer Worker.
3. Paste the full contents of `TWP-CF-DEPLOYER.js` into the editor and deploy.
4. Open the Worker URL and verify with a Cloudflare API token.
