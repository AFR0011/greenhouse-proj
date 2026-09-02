# Risk Register

Workflow schema: `agentic-workflow/v2`
Project: greenhouse-proj
Repository profile: software
Initialized: 2026-09-02

## Open risks

### RISK-001 - Public refs still contain revoked credentials

- Severity: Critical
- Category: security / credential history
- Status: Mitigated locally; public publication gated
- Evidence: Phase 1 found a Firebase service-account private key and other revoked credentials in current or historical blobs.
- Mitigation: Remove current copies, rewrite every reachable local ref with exact-value replacement and path removal, then perform two history scans before proposing publication.
- Owner / next action: root executes and verifies local Batch 1; repository owner separately approves any later public rewrite.
- Local status: Mitigated in the verified rewrite mirror; public refs remain unchanged until separately approved.

### RISK-002 - History rewrite changes commit identifiers

- Severity: High
- Category: provenance / collaboration
- Status: Open
- Evidence: Removing historical blobs necessarily changes affected commits and descendants; pull-request and collaborator clones may retain old objects.
- Mitigation: Preserve an integrity-checked tainted backup, retain authors/dates/messages/topology, produce a commit map, inventory non-branch refs, and require a collaborator freeze before publication.
- Owner / next action: root records local evidence; repository owner coordinates publication later.
- Local status: Commit map, ref map, topology, metadata, and tree-equivalence evidence all pass.

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

### RISK-006 - Public rewrite prerequisites remain incomplete

- Severity: High
- Category: publication / recovery
- Status: Open
- Evidence: The verified rewrite is local only. The tainted evidence mirror is local but is not an owner-confirmed encrypted/offline backup; collaborator freeze and GitHub authentication are also incomplete.
- Mitigation: Do not force-push. Resolve backup retention, collaborator coordination, authentication, and explicit publication approval first.
- Owner / next action: repository owner and root address only in a separately approved publication batch.
