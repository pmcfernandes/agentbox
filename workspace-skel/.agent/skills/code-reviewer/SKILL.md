---
name: code-reviewer
description: Automated code review skill for pull requests, git diffs, and changesets
---

# Code Reviewer Skill

## Purpose
Perform high-quality, actionable, and prioritized code reviews on modified files or git diffs.

## Review Checklist
1. **Correctness & Logic**:
   - Are there null/undefined edge cases?
   - Are race conditions, deadlocks, or improper async/await handling present?
   - Is error handling complete and informative?
2. **Security**:
   - Injection vulnerabilities (SQL, Command, XSS, Path traversal).
   - Insecure credential or secret handling.
   - Proper input validation and sanitization.
3. **Performance & Scalability**:
   - Unbounded queries or loops (O(N^2)).
   - Memory leaks or unclosed resource handles (files, database connections).
4. **Style & Conventions**:
   - Conformance to existing repository style and idioms.
   - Clean, readable code without unnecessary comments.

## Output Format
Provide review findings in a concise table grouped by severity:
- 🔴 **Critical**: Must fix immediately before merge.
- 🟠 **High**: Potential bug or security exposure.
- 🟡 **Medium**: Performance or maintainability concern.
- ⚪ **Low**: Minor suggestion or style improvement.
