# ADR 0001 — Use msmtp for SMTP delivery

## Status

Accepted

## Context

SentinelOps needs a lightweight and auditable way to send alert emails from Linux servers.

Running a full mail server on each monitored host would add unnecessary operational complexity.

## Decision

Use `msmtp` as the SMTP client.

## Consequences

Benefits:

- Small footprint.
- Standard Linux package.
- Works with external SMTP providers.
- Compatible with sendmail-style workflows.
- Easy to test from standard input.

Trade-offs:

- Requires SMTP credentials on the server.
- Needs careful file permission handling.
