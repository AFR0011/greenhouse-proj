# Development Log

Workflow schema: `agentic-workflow/v2`
Project: greenhouse-proj
Repository profile: software
Initialized: 2026-09-02

## 2026-09-02 - Repository bootstrap

- Classified as `software` with traits: none.
- Created missing governance files without modifying product/source artifacts.
- Classification evidence is recorded in `docs/REPO_PROFILE.md`.

## 2026-09-02 - Option A Batch 1 accepted

- Owner confirmed the repository should become a secure archived case study.
- Scope is limited to Finalization Plan steps 1.1-1.19 and local work only.
- Owner confirmed the exposed Firebase, Wi-Fi, Firebase-user, and EmailJS credentials are revoked and safe to remove.
- Installed `git-filter-repo` 2.47.0 for the isolated rewrite.
- Created an integrity-checked tainted bare backup at the local Phase 2 workspace before source changes.
- Public force-push, unarchiving, provider changes, and publication remain outside the accepted batch.

## 2026-09-02 - Local credential-history rewrite verified

- Added one unpublished remediation commit that removes current credential files and inline values, moves configuration to ignored or injected inputs, and disables the archived employee-provisioning flow.
- Rewrote `main` and 11 pull-request refs in an isolated bare mirror with `git-filter-repo` 2.47.0.
- Removed both historical Firebase service-account paths and twelve known stale values, including four stale Firebase client API keys.
- Preserved all 208 pre-evidence commits and all 12 refs. Of those commits, 207 necessarily received new identifiers.
- A byte-level verifier found no author, committer, timestamp, message, parent-topology, ref, or non-secret tree mismatch.
- Gitleaks 8.30.1 found no Firebase/GCP keys, service-account paths, or project-owned private keys. Six residual alerts were verified CocoaPods `SPEC CHECKSUMS` entries.
- No public remote was changed.

## 2026-09-02 - Owner-approved publication verified

- The owner confirmed the publication package, collaborator freeze, and cleanup decisions for Finalization Plan steps 1.20-1.22.
- Retained the tainted evidence mirror with Windows EFS encryption and verified repository integrity before publication.
- Temporarily unarchived `AFR0011/greenhouse-proj`, force-updated the existing `main` branch in place to the reviewed successor, and rearchived the same public repository.
- A fresh partial clone from GitHub resolved to clean rewrite tip `1912a2ed82aa39593ba8b7abca2bb4feec07d823`, contained 204 `main` commits, passed `git fsck --full --strict`, and had a clean checkout.
- The published tree and the equivalent reviewed full history retain only six Gitleaks alerts, all verified CocoaPods `SPEC CHECKSUMS` values.
- GitHub still advertises all 11 pull-request heads at their original pre-rewrite object identifiers. GitHub Support cleanup remains required because repository owners cannot rewrite those server-controlled refs.
- GitHub secret scanning is enabled. Push protection remains disabled while the repository is archived; the archive state prevents writes.
