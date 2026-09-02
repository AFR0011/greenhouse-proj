# Blueprint

Workflow schema: `agentic-workflow/v2`
Project: greenhouse-proj
Repository profile: software
Initialized: 2026-09-02

## Product objective

Secure archived portfolio case study with preserved project history and verified credential removal

## Active batch

Status: VERIFIED_LOCAL
Batch ID: PHASE2-GREENHOUSE-B1

### Objective

Complete Option A Batch 1, steps 1.1-1.19: create a secure archived case study, remove revoked credentials from the current tree and reachable Git history, preserve authentic commit metadata/topology, and produce local verification evidence.

### Intended files

- `.gitignore`
- `backend/app.js` and a non-secret backend configuration example
- `Hardware/wifi_code/wifi_code.ino` and `Hardware/wifi_code/secrets.example.h`
- `greenhouse_project/lib/services/cubit/management_cubit.dart`
- `greenhouse_project/lib/services/cubit/manage_employees_cubit.dart`
- `greenhouse_project/pubspec.yaml` and its lockfile
- The tracked Firebase service-account JSON paths, which must be removed
- Governance, security-notice, and verification documents
- An isolated local bare mirror used for the history rewrite

### Allowed adjacent files

- Dependency metadata changed only as required to remove the client-side EmailJS integration.
- Historical blobs containing exact revoked credential values, wherever the value occurs.

### Out of scope

- Any force-push or other public repository write.
- Unarchiving the GitHub repository or changing GitHub settings.
- Provider changes, deployment revival, feature redesign, or public successor publication.
- Squashing, rebasing for presentation, altering authorship, or rewriting commit messages unrelated to secret removal.

### Preconditions

- Owner accepted Option A and Batch 1 steps 1.1-1.19 on 2026-09-02.
- Revoked Firebase, Wi-Fi, Firebase-user, and EmailJS credentials are confirmed stale and safe to remove.
- A local tainted backup must pass Git integrity verification before history mutation.
- The rewrite tool must be version 2.47 or newer.

### Acceptance criteria

- The current branch contains no private service-account key, Wi-Fi credentials, Firebase user credentials, prefilled login credentials, or EmailJS private key.
- Runtime credential access uses injected/local-only configuration and fails closed when required configuration is absent.
- Employee provisioning/email delivery is visibly disabled in the archived build; no insecure replacement workflow is invented.
- Every reachable original commit maps to a rewritten commit; parent topology, authors, author dates, committers, committer dates, and messages are preserved except unavoidable SHA changes.
- Removed credential paths are absent from all rewritten refs and exact revoked values are absent from all rewritten blobs.
- A second generic scan, Git integrity check, current-tree checks, and metadata comparison complete successfully.
- No public write occurs.

### Verification

- `git fsck --full --no-dangling` on backup and rewritten mirrors.
- Exact-value scan across all reachable blobs without printing values.
- Independent generic secret-pattern scan across rewritten history.
- Commit-map, topology, and metadata comparison against the tainted backup.
- Non-secret tree equivalence comparison with a recorded allowlist.
- Focused syntax/dependency checks for the Node backend and static checks available for firmware/Flutter files.

### Protected inputs

- See `AGENTS.md` and `docs/REPO_MAP.md`.

### Risks

- See `RISK_REGISTER.md`.

### Rollback

- Preserve the verified tainted bare mirror and the pre-change working clone.
- Do not publish. If verification fails, discard only the isolated rewrite mirror and recreate it from the verified tainted backup.

### Evidence required for done

- Commands, versions, commit/ref counts, commit-map results, scan counts, test outputs, final diff review, tester verdict, and unresolved risks recorded in repository governance files and the external portfolio audit outputs.
