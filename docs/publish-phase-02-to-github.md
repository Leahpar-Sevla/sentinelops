# Publish Phase 2 to GitHub

After copying these files into the repository root:

```bash
git status
git add .
git commit -m "feat: add SentinelOps phase 2 core availability sentinel"
git tag -a v0.2.0-phase-02-core-sentinel -m "Phase 2: core availability sentinel validated in lab"
git push
git push origin v0.2.0-phase-02-core-sentinel
```

Recommended release title:

```text
v0.2.0-phase-02-core-sentinel
```

Recommended release notes:

```text
Adds dynamic mount classification, multi-job backup validation, fallback monitoring and email escalation validated in lab.
```
