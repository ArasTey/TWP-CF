# TWP-CF Deployer

**A single-file Cloudflare Worker deployer for TWP-CF, with integrated deployment controls and Cloudflare API error diagnostics.**

[**Open Live Deployer**](https://deployer.imarastey.workers.dev/) · [GitHub Repository](https://github.com/ArasTey/TWP-CF) · [Report an Issue](https://github.com/ArasTey/TWP-CF/issues)

---

## Overview

TWP-CF Deployer provides a browser-based interface for deploying and managing TWP-CF Workers through the Cloudflare API.

The deployer is designed around a single JavaScript source file. You can deploy it directly as a Cloudflare Worker without setting up a separate Node.js application, package manager, or build pipeline.

The live deployer is available at:

**https://deployer.imarastey.workers.dev/**

## Features

* **Single-file deployment:** The deployer source is provided in `TWP-CF-DEPLOYER.js`.
* **Cloudflare API integration:** Performs supported account and Worker operations through Cloudflare's API.
* **Token verification:** Reports API responses when verifying a submitted Cloudflare API token.
* **Worker deployment:** Provides a web interface for the deployment workflow.
* **Worker management:** Includes deletion and other management actions implemented by the deployer.
* **Readable error diagnostics:** Explains common API failures instead of displaying only a generic error.
* **Original error details:** Preserves Cloudflare's returned message, HTTP status, and error code when available.
* **Account and permission diagnostics:** Helps identify token permissions, account access, and account-scope problems.
* **Resource diagnostics:** Helps investigate Worker-name conflicts, Durable Object provisioning, SQLite configuration, rate limits, and resource restrictions.
* **Network error reporting:** Distinguishes API and network failures where the available response information permits.
* **No separate application build:** The Worker source can be pasted directly into the Cloudflare editor.

> Diagnostic messages are based on the information returned by Cloudflare. They cannot guarantee the exact cause of every failure.

## Live Demo

Use the deployed version to access the current web interface:

**[Launch TWP-CF Deployer →](https://deployer.imarastey.workers.dev/)**

The live service and the source code in this repository are separate: publishing a change to GitHub does not automatically update the deployed Worker unless an automatic deployment workflow has been configured.

## Repository Structure

```text
TWP-CF/
├── README.md
└── TWP-CF-DEPLOYER.js
```

* `README.md` — Project documentation and deployment instructions.
* `TWP-CF-DEPLOYER.js` — The deployer Worker source.

## Requirements

* A Cloudflare account.
* Access to Cloudflare Workers.
* A Cloudflare API token with the permissions required for the operations you intend to perform.
* A browser to access the deployer interface.

Some features may also require account-level access, appropriate Worker configuration, and supported Durable Object storage capabilities.

## Getting Started

### Option 1 — Use the Live Deployer

1. Open the [TWP-CF Live Deployer](https://deployer.imarastey.workers.dev/).
2. Follow the instructions displayed by the interface.
3. Provide your Cloudflare API token when requested.
4. Verify the token and account access.
5. Configure the requested deployment options.
6. Start deployment and review the result returned by Cloudflare.
7. If an operation fails, read the diagnostic message and follow the suggested corrective steps.

Only enter your API token on a deployer instance you trust. Review the source code before submitting credentials to any hosted instance.

### Option 2 — Deploy Your Own Instance

1. Sign in to the [Cloudflare Dashboard](https://dash.cloudflare.com/).
2. Navigate to **Workers & Pages**.
3. Create a Worker or open the Worker you want to use for the deployer.
4. Open the code editor.
5. Copy the complete contents of `TWP-CF-DEPLOYER.js` from this repository.
6. Replace the editor contents with the source code.
7. Save and deploy the Worker.
8. Open the assigned Worker URL and test the interface.

For the latest source, open [`TWP-CF-DEPLOYER.js`](https://github.com/ArasTey/TWP-CF/blob/main/TWP-CF-DEPLOYER.js).

**Important:** Deploying the deployer is different from deploying a Worker through the deployer interface. Follow the application's configuration instructions for the second step.

## Cloudflare API Token

The token must have the permissions required by the actions you plan to use. Insufficient permissions can prevent verification, deployment, or Worker management.

Use the official [Cloudflare API Tokens page](https://dash.cloudflare.com/profile/api-tokens) to create or manage a token.

Security recommendations:

* Use a dedicated token with the minimum permissions necessary.
* Restrict account access whenever possible.
* Never commit API tokens to GitHub.
* Never include tokens in screenshots, public issue reports, or shared logs.
* Revoke a token immediately if you suspect it has been exposed.
* Review the source code before using an unfamiliar or third-party deployment instance.

The deployer is intended to report errors without exposing the submitted API token in diagnostic messages. Avoid assuming that any website is safe solely because it uses HTTPS.

## Error Diagnostics

The interface is designed to provide useful information for common Cloudflare API failures.

| Error category                   | What to check                                                        |
| -------------------------------- | -------------------------------------------------------------------- |
| Invalid or expired token         | Confirm the token is valid and has not been revoked.                 |
| Insufficient permissions         | Review the token's permissions and account access.                   |
| Account scope or access          | Confirm that the selected account is accessible to the token.        |
| Worker-name conflict             | Check whether the requested Worker name is already in use.           |
| Workers.dev configuration        | Review the account's Workers.dev settings and hostname availability. |
| Durable Object errors            | Check the Durable Object configuration and deployment response.      |
| SQLite provisioning              | Review the storage configuration and the original Cloudflare error.  |
| Rate limits                      | Review the response and retry after the restriction allows.          |
| Resource or billing restrictions | Check the account's usage limits, plan, and billing status.          |
| Network or API failure           | Check connectivity and the returned HTTP status and error message.   |

These categories are troubleshooting guidance, not proof of the underlying cause. Cloudflare may return ambiguous, incomplete, or unexpected responses.

### Recommended Troubleshooting Procedure

1. Read the complete error message.
2. Note the HTTP status and Cloudflare error code, if present.
3. Confirm that the API token is valid.
4. Verify the token's permissions and account access.
5. Check the relevant Worker, account, or storage configuration.
6. Retry only after correcting the suspected issue.
7. If the error persists, report the original error message and relevant status information without including credentials.

## Deployment and Updates

The source of truth for this repository is the `main` branch.

To update an existing deployer instance:

1. Review the latest changes in the [repository](https://github.com/ArasTey/TWP-CF).
2. Open the latest [`TWP-CF-DEPLOYER.js`](https://github.com/ArasTey/TWP-CF/blob/main/TWP-CF-DEPLOYER.js).
3. Copy the complete source into your Cloudflare Worker editor.
4. Save and deploy.
5. Test token verification and the relevant management actions.

Updating the GitHub file alone does not update an already deployed Worker unless your repository is connected to an automated deployment pipeline.

## Security and Limitations

* Cloudflare account operations depend on the permissions and access granted to the API token.
* Error explanations are derived from the returned API response and may not identify every underlying account restriction.
* Cloudflare API availability, account limits, and platform behavior are outside the deployer's control.
* A successful API request does not necessarily guarantee that every subsequent application-level operation will work.
* Treat API tokens and generated proxy credentials as sensitive.
* If a deployed panel displays a proxy URL or its associated secret, anyone who can access that information may be able to use it. Restrict access or rotate credentials when appropriate.

## Support and Issues

If you encounter a bug or unexpected behavior, open an issue in the repository:

**[Report a GitHub Issue](https://github.com/ArasTey/TWP-CF/issues)**

Include:

* A short description of the problem.
* The operation that failed.
* The HTTP status and Cloudflare error code, if available.
* Relevant non-sensitive error text.
* The expected behavior and actual result.

**Never include API tokens, passwords, private credentials, or other secrets in an issue.**

## Links

* **Live Deployer:** https://deployer.imarastey.workers.dev/
* **GitHub Repository:** https://github.com/ArasTey/TWP-CF
* **Source File:** https://github.com/ArasTey/TWP-CF/blob/main/TWP-CF-DEPLOYER.js
* **Issues:** https://github.com/ArasTey/TWP-CF/issues
* **Cloudflare Dashboard:** https://dash.cloudflare.com/
* **Cloudflare API Tokens:** https://dash.cloudflare.com/profile/api-tokens

---

*Project: TWP-CF Deployer*
*Source: ArasTey/TWP-CF*
