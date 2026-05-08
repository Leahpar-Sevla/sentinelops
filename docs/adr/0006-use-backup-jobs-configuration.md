# ADR — Use backup_jobs.conf

## Status

Accepted

## Decision

Represent each backup routine as one config line so servers can have one, two, three or more jobs without changing the script.

## Consequences

This improves operational clarity and keeps SentinelOps portable across servers.
