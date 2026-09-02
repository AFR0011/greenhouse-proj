# Risk Register

Workflow schema: `agentic-workflow/v2`
Project: greenhouse-proj
Repository profile: software
Initialized: 2026-09-02

## Open risks

### RISK-001 - GitHub-controlled historical refs may retain revoked credentials

- Severity: Critical
- Category: security / credential history
- Status: Mitigated on owned `main`; Support cleanup pending
- Evidence: Phase 1 found a Firebase service-account private key and other revoked credentials in current or historical blobs.
- Mitigation: Removed current copies, rewrote the owned history with exact-value replacement and path removal, performed independent scans, published the reviewed successor, and rearchived the repository.
- Owner / next action: root submits a GitHub Support request to purge or dereference the 11 stale pull-request refs and cached sensitive-data views.
- Current status: Public `main` is clean and verified. GitHub-controlled pull-request heads still resolve to their original identifiers.

### RISK-002 - History rewrite changes commit identifiers

- Severity: High
- Category: provenance / collaboration
- Status: Mitigated with residual external refs
- Evidence: Removing historical blobs necessarily changes affected commits and descendants; pull-request and collaborator clones may retain old objects.
- Mitigation: Preserve an integrity-checked tainted backup, retain authors/dates/messages/topology, produce a commit map, inventory non-branch refs, and require a collaborator freeze before publication.
- Owner / next action: Use only fresh clones after publication; retain the encrypted tainted mirror only as controlled evidence until Support cleanup is confirmed.
- Current status: Commit map, ref map, topology, metadata, and tree-equivalence evidence pass; the repository is archived to prevent accidental pushes.

### RISK-003 - Archived provisioning flow cannot remain safely functional

- Severity: High
- Category: security / product behavior
- Status: Accepted for Option A
- Evidence: Employee provisioning sends generated plaintext passwords through a client-side EmailJS private key.
- Mitigation: Remove the client-side integration and visibly disable employee provisioning in the archived build. A secure server-side invitation flow is outside this batch.
- Owner / next action: root implements the archival disablement.
- Local status: Mitigated in the rewritten current tree.

### RISK-004 - Full Flutter and firmware toolchains are unavailable

- Severity: Medium
- Category: verification
- Status: Open
- Evidence: Flutter was not available during Phase 1; hardware compilation requires board/toolchain configuration not recorded in the repository.
- Mitigation: Run all available static and dependency checks, inspect changed files, and keep unavailable build verification explicit.
- Owner / next action: root records verification limits; no public release claim is permitted.

### RISK-005 - Existing Node dependency vulnerabilities

- Severity: High
- Category: dependency security
- Status: Open
- Evidence: `npm ci` reports 19 audit findings: 3 critical, 6 high, 9 moderate, and 1 low.
- Mitigation: Keep the project archived; handle dependency upgrades as a separately planned batch with compatibility testing.
- Owner / next action: repository owner decides whether Phase 2 should include dependency modernization.

### RISK-006 - Server-controlled cleanup remains incomplete

- Severity: High
- Category: publication / recovery
- Status: Open
- Evidence: Publication prerequisites were satisfied and public `main` now matches the reviewed successor, but GitHub still advertises 11 original pull-request heads.
- Mitigation: Submit the GitHub sensitive-data removal request without including secret values; keep the repository archived and old clones disconnected from public push access.
- Owner / next action: root submits and records the Support request; repository owner monitors it to closure.
