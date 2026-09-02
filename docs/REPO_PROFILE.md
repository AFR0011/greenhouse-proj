# Repository Profile

Workflow schema: `agentic-workflow/v2`
Project: greenhouse-proj
Repository profile: software
Initialized: 2026-09-02

## Classification

- Primary type: `software`
- Secondary traits: none
- Confidence: high
- Files scanned: 254
- Scan truncated: False

## Evidence

```json
{
  "software": [
    "file:build.gradle",
    "file:package.json",
    "file:CMakeLists.txt",
    "dir:test",
    "dir:app",
    "dir:src",
    "dir:lib",
    "ext:.java(1)",
    "ext:.kt(1)",
    "ext:.swift(6)",
    "ext:.js(3)",
    "ext:.cpp(4)",
    "keywords:service"
  ]
}
```

## Existing governance discovered

- README.md

## Discovered entry points

- `backend\app.js`
- `greenhouse_project\lib\main.dart`
- `greenhouse_project\linux\main.cc`
- `greenhouse_project\web\index.html`
- `package.json`

## Discovered commands

- **start**: `npm run start` (evidence: package.json scripts)
- **test**: `npm run test` (evidence: package.json scripts)

## Protected/generated boundaries

### Protected candidates

- None detected automatically; manual review required.

### Generated-output candidates

- None detected automatically.

## Equivalent-file mappings

Record mature existing files that satisfy canonical purposes under different names.

## Profile review

- [ ] Human confirmed primary type and traits.
- [ ] Authority and protected paths confirmed.
- [ ] Required commands confirmed.
