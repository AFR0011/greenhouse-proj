# History rewrite evidence

Date: 2026-09-02

## Scope

This evidence covers the Option A Batch 1 rewrite and its owner-approved in-place
publication to the existing GitHub repository. It does not claim that external
caches, old clones, or GitHub-controlled pull-request refs have been erased.

## Inputs and tools

- Integrity-checked tainted bare mirror of the public repository.
- One local remediation commit based on the public `main` tip.
- `git-filter-repo` 2.47.0 with commit-hash references preserved.
- Gitleaks 8.30.1, downloaded from its official GitHub release and verified
  against the published SHA-256 checksum.

## Rewrite result

- 208 commits entered the rewrite before this evidence commit.
- 208 commits and 12 refs remained after the rewrite.
- 207 commit identifiers changed because their trees or ancestors changed.
- `main` retained 203 pre-evidence commits.
- Eleven pull-request head refs were included.
- Two historical Firebase service-account paths were removed from every ref.
- Twelve stale values were sanitized, including device/network credentials,
  prefilled login credentials, an email-provider private key, and four stale
  Firebase client API keys.

## Preservation checks

For every mapped commit, an independent verifier compared the original and
rewritten objects. Authors, committers, timestamps, encodings, messages, parent
topology, ref targets, modes, file types, and all non-secret file content match.
Only the declared credential paths and exact stale values differ.

## Scan results

- Known long stale values remaining: 0.
- Known stale values in credential assignments: 0.
- Project-owned private-key headers: 0.
- Firebase/GCP API-key findings from Gitleaks: 0.
- Service-account-path findings from Gitleaks: 0.
- Residual Gitleaks alerts: 6, all verified CocoaPods `SPEC CHECKSUMS` values in
  dependency lockfiles.

Historical vendored dependencies contain generic private-key fixtures and common
numeric strings. They are unchanged non-project test/library material and do not
occur in the repository's credential-bearing assignments.

## Verification limits

Node dependency installation and backend syntax/fail-closed checks pass. Flutter,
Dart, and Arduino toolchains were unavailable. The repository has no implemented
Node test suite, and `npm audit` reports existing dependency risks. See
`QA_REPORT.md` and `RISK_REGISTER.md`.

## Publication verification

- The encrypted tainted evidence backup passed integrity checks before publication.
- The owner approved the destructive in-place update, collaborator freeze, and rearchive procedure.
- The existing public repository name and visibility were retained.
- A fresh GitHub clone resolved to clean rewrite tip `1912a2ed82aa39593ba8b7abca2bb4feec07d823` with 204 `main` commits and passed `git fsck --full --strict`.
- The repository was rearchived immediately after the update.
- All 11 GitHub-controlled pull-request heads still resolve to pre-rewrite objects. A GitHub Support sensitive-data cleanup request is required; this repository evidence does not claim those objects or external caches are erased.
