# Risk Register

Workflow schema: `agentic-workflow/v2`
Project: greenhouse-proj
Repository profile: software
Initialized: 2026-09-02

## Open risks

### RISK-001 - Public refs still contain revoked credentials

- Severity: Critical
- Category: security / credential history
- Status: Open
- Evidence: Phase 1 found a Firebase service-account private key and other revoked credentials in current or historical blobs.
- Mitigation: Remove current copies, rewrite every reachable local ref with exact-value replacement and path removal, then perform two history scans before proposing publication.
- Owner / next action: root executes and verifies local Batch 1; repository owner separately approves any later public rewrite.

### RISK-002 - History rewrite changes commit identifiers

- Severity: High
- Category: provenance / collaboration
- Status: Open
- Evidence: Removing historical blobs necessarily changes affected commits and descendants; pull-request and collaborator clones may retain old objects.
- Mitigation: Preserve an integrity-checked tainted backup, retain authors/dates/messages/topology, produce a commit map, inventory non-branch refs, and require a collaborator freeze before publication.
- Owner / next action: root records local evidence; repository owner coordinates publication later.

### RISK-003 - Archived provisioning flow cannot remain safely functional

- Severity: High
- Category: security / product behavior
- Status: Accepted for Option A
- Evidence: Employee provisioning sends generated plaintext passwords through a client-side EmailJS private key.
- Mitigation: Remove the client-side integration and visibly disable employee provisioning in the archived build. A secure server-side invitation flow is outside this batch.
- Owner / next action: root implements the archival disablement.

### RISK-004 - Full Flutter and firmware toolchains are unavailable

- Severity: Medium
- Category: verification
- Status: Open
- Evidence: Flutter was not available during Phase 1; hardware compilation requires board/toolchain configuration not recorded in the repository.
- Mitigation: Run all available static and dependency checks, inspect changed files, and keep unavailable build verification explicit.
- Owner / next action: root records verification limits; no public release claim is permitted.
