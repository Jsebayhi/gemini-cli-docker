# Python Testing Implementation Standards

This document defines how to apply general testing principles specifically using the Python toolchain.

## 1. Toolchain
- **Runner:** `pytest` with `pytest-xdist` (parallel) and `pytest-mock`.
- **Contract Enforcement:** `jsonschema` for validating API responses and mock payloads.

## 2. Infrastructure & Synchronization
- **Process Isolation:** The live HTTP server MUST run in the same process memory as the test runner when using `unittest.mock`.
- **Socket Probe:** Use a connection probe in `conftest.py` to wait for the Flask server to bind to its socket before starting UI tests.
- **Monkeypatching:** Always use the `monkeypatch` fixture for thread-safe configuration overrides.

## 3. Quality & Coverage (DRY)
- **Threshold:** Every component must exceed **90% coverage**.
- **Centralized Config:** Configuration (thresholds, parallel workers, source paths) must live in `.coveragerc` rather than CLI flags in the Makefile.
- **Real FS:** Use `tmp_path` for all filesystem testing.

## 4. Log & Console Hygiene
- **Suppression:** Use a `suppress_logs` fixture to silence expected errors.
- **Zero-Console-Error:** Configure Playwright to catch `console.error` and fail the test in the `hub` fixture.
