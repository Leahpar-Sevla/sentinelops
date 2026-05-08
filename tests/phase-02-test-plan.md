# Phase 2 Test Plan

## Required lab validation

| Test | Expected status | Expected exit |
|---|---:|---:|
| Clean state | OK | 0 |
| Fallback file in `main` job | WARNING | 1 |
| Missing `secondary` backup folder | CRITICAL | 3 |
| Archived disk remounted read-write | HIGH | 2 |
| Warning email to support | WARNING | 1 |
| Critical email to management and support | CRITICAL | 3 |

## Notes

Phase 2 intentionally does not implement alert cooldown. Cooldown and recovery notifications belong to Phase 3.
