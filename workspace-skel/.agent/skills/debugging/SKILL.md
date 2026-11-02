---
name: debugging
description: Systematic root cause analysis, reproduction, and bug-fixing skill
---

# Debugging Skill

## Objective
Isolate, reproduce, and fix software defects with minimal surface impact.

## Protocol
1. **Understand & Reproduce**:
   - Collect exact error messages, stack traces, and relevant environment logs.
   - Formulate a minimal reproducible example (unit test or CLI command).
2. **Hypothesize & Inspect**:
   - Trace backwards from the failure point to where invariants broke.
   - Inspect variable states and inspect inputs.
3. **Formulate Fix**:
   - Implement the smallest complete fix that resolves root causes, not just symptoms.
   - Avoid workaround hacks that mask the underlying bug.
4. **Validate**:
   - Run the reproduction test to ensure the failure is resolved.
   - Run existing regression suites to prevent breaking existing behavior.
