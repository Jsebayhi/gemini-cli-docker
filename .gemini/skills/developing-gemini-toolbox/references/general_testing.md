# General Testing Standards (Language Agnostic)

These principles apply to all components in the Gemini CLI Toolbox, regardless of the implementation language.

## 1. The Testing Trophy
We prioritize tests that provide the highest confidence-to-cost ratio.
- **Static Analysis:** Linters and type checkers are mandatory.
- **Integration Tests:** The bulk of the suite. Verify service interfaces and system boundaries.
- **Contract Testing:** Enforce JSON Schemas for all API interactions. Verify that mocks used in UI tests match the actual schemas produced by the backend.

## 2. Mocking Philosophy
- **Mock at the Boundary:** Only mock slow, non-deterministic, or dangerous external systems (Network, Time, Subprocesses).
- **Favor Realism:** Do not mock internal services. Let the code execute through the full stack.
- **Data over Mocks:** Use real temporary file structures (`tmp_path`) instead of mocking filesystem APIs.

## 3. Test Qualities
- **Atomicity:** Each test verifies a single logical outcome.
- **Synchronization:** When starting servers/services for E2E tests, use polling/probes to ensure the service is ready before yielding to the test (avoid race conditions).
- **Clean Slate:** Every test starts with a fresh environment (namespaces, temporary directories, etc.).
- **Parallel Readiness:** NEVER mutate global shared state. Use local overrides or scoped fixtures.
