# QA Report

Workflow schema: `agentic-workflow/v2`
Project: greenhouse-proj
Repository profile: software
Initialized: 2026-09-02

## Current cycle

- Batch: PHASE2-GREENHOUSE-B1
- Verdict: PASS_WITH_RISKS
- Evidence: Local rewrite verification and independent post-publication GitHub clone verification completed on 2026-09-02.

## Bootstrap validation

Run the repository audit script and record the result here or in `docs/BOOTSTRAP_AUDIT.md`.

## History and secret-removal verification

- `git-filter-repo`: 2.47.0.
- Pre-evidence commit map: 208 rows; 207 changed identifiers; no removed commits.
- Refs: 12 before and after (`main` plus 11 pull-request heads).
- Metadata comparison: zero author, committer, timestamp, encoding, or message mismatches.
- Topology comparison: zero parent mismatches.
- Tree equivalence: zero unexpected path, mode, type, or content mismatches.
- Known-value scan: zero long exact matches and zero revoked values in credential-bearing assignments.
- Project-owned private-key headers: zero.
- Generic vendored private-key fixtures: 11, all confined to historical `API/node_modules/` objects and unchanged from the original history.
- Short numeric strings matching two revoked test passwords remain incidentally in vendored source, but zero occur in credential-bearing assignments.
- `git fsck --full --no-dangling`: pass on the tainted backup and rewritten mirror.

## Independent scan

- Gitleaks 8.30.1 scanned all refs through Git log.
- Firebase/GCP API-key findings: zero.
- Service-account-path findings: zero.
- Project-owned private-key findings: zero.
- Six `generic-api-key` alerts remain in iOS/macOS `Podfile.lock`; each is a CocoaPods `SPEC CHECKSUMS` value and is retained as dependency integrity metadata.

## Post-publication verification

- Public repository: `AFR0011/greenhouse-proj`, still public and rearchived.
- Fresh remote clone tip: `1912a2ed82aa39593ba8b7abca2bb4feec07d823`, exactly matching the reviewed successor at publication.
- Fresh remote `main` commit count: 204.
- Fresh remote `git fsck --full --strict`: pass.
- Fresh remote working tree: clean.
- Fresh remote current-tree Gitleaks result: the same six verified CocoaPods checksum alerts and no Firebase/GCP API-key findings.
- Full-history equivalence: the public tip's commit identity matches the locally verified full-history mirror, whose all-history Gitleaks and exact/context scans are recorded above.
- Residual GitHub-controlled refs: all 11 pull-request heads still resolve to their original pre-rewrite identifiers; Support cleanup is pending.

## Clean-checkout checks

- `npm ci --ignore-scripts`: pass (257 packages installed).
- `node --check backend/app.js`: pass.
- Backend without `FIREBASE_DATABASE_URL`: exits nonzero with the expected fail-closed message.
- YAML, Android JSON, and iOS plist parsing: pass.
- Working tree after checks: clean.
- `npm test`: unavailable by repository design; the script exits 1 with `Error: no test specified`.
- Flutter, Dart, and Arduino CLI: unavailable in the verification environment.
- `npm audit`: 19 existing findings (3 critical, 6 high, 9 moderate, 1 low); dependency remediation is outside this security-history batch.

## Verdict rationale

The credential-removal, history-preservation, and public publication criteria pass for the owned `main` branch. The verdict remains `PASS_WITH_RISKS` because GitHub-controlled pull-request refs still require Support cleanup, full Flutter/firmware builds are unavailable, and the Node dependency findings remain.
