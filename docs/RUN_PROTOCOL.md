# Run and Verification Protocol

Workflow schema: `agentic-workflow/v2`
Project: greenhouse-proj
Repository profile: software
Initialized: 2026-09-02

## Principle

Use the lightest check that can disprove the completion claim, then broaden according to risk. Never execute a discovered command merely because it exists; confirm scope, cost, side effects, and required environment first.

## Environment/setup

- Unknown; do not invent commands. Confirm with repository evidence or the owner.

## Discovered commands

- **start**: `npm run start` (evidence: package.json scripts)
- **test**: `npm run test` (evidence: package.json scripts)

## Suggested verification ladder

1. Inventory and changed-file review.
2. Focused verification: `npm run test`.
3. Broader verification: `npm run test`.
4. Run/build/reproduce/render path: `npm run start`.
5. Manual review for claims, outputs, rendering, security, or irreversible effects that automation cannot establish.

## Profile-specific verification

Repository profile is `software`. Define checks for behavior, evidence/reproducibility, data integrity, factual/source consistency, or documentation build/link integrity as applicable.

## Safety boundaries

- Do not install dependencies, access production, mutate raw data, or launch expensive runs without explicit authorization.
- Record unavailable checks and their consequences instead of converting them into a pass.
- Preserve command output or concise evidence sufficient to reproduce the verdict.

## Evidence recording

Record actual commands, outputs, unavailable checks, and limitations in `QA_REPORT.md`.
