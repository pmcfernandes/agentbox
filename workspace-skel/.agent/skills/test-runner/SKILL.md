---
name: test-runner
description: Automated test execution, validation, and coverage reporting
---

# Test Runner Skill

## Workflow
1. **Detect Test Harness**:
   - Node / TS: `bun test`, `npm test`, `vitest`, `jest`
   - Python: `uv run pytest`
   - Rust / Go / C: `cargo test`, `go test ./...`, `ctest`
2. **Execute Targeted Tests**:
   - First run the tests corresponding directly to modified units.
   - Run the broader test suite once targeted tests succeed.
3. **Analyze Failures**:
   - Parse failure summaries, assertions, and diffs.
   - If tests fail due to deliberate API changes, update test expectations accordingly.
