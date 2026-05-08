# ADR 0003 — Use sentinela-email wrapper

## Status

Accepted

## Context

Future monitoring scripts should not need to know SMTP details or construct full email headers repeatedly.

Generic mail utilities may add local behavior that is not required for SentinelOps.

## Decision

Create a project wrapper named `sentinela-email`.

## Consequences

Benefits:

- Standardizes subject, sender and message body.
- Keeps future monitoring scripts simple.
- Uses `msmtp` directly.
- Makes tests repeatable.

Trade-offs:

- The wrapper must be installed and maintained on each server.
