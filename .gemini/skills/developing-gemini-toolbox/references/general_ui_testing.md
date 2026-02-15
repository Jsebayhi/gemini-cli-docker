# General UI Testing Standards

These standards define the architectural approach for testing web and mobile interfaces within the Gemini Toolbox.

## 1. Page Object Model (POM) & Composition
- **Decoupling:** Test files should contain "What" (user intent), Page Objects should contain "How" (implementation).
- **Component Composition:** For complex UIs, avoid "God Objects." Split the POM into logical components (e.g., `HubPage` containing a `LaunchWizard` instance). 
- **Rule:** Tests should interact via nested components: `hub.wizard.launch(...)`.

## 2. Deterministic Interactivity
- **Signal-Based Waiting:** NEVER use static timers (e.g., `sleep(500ms)`). 
- **Wait for State:** Always wait for a specific UI state change (e.g., element visibility, text change, count update) before proceeding.
- **Strict Mode:** If a selector matches multiple elements, the test is ambiguous and should fail.

## 3. Observability & Zero-Noise Policy
- **Rich Artifacts:** Tracing (screenshots, console logs, and network snapshots) must be captured automatically upon failure.
- **Zero-Console-Error:** UI tests should be configured to fail if any unexpected JS errors are detected in the browser console, even if assertions pass. This ensures high code quality and catches silent regressions.

## 4. State Management
- **Persistence Reset:** Explicitly clear browser-side storage (localStorage, Cookies) between tests to ensure isolation.
- **Navigation:** Every test should ideally start from a known entry point (e.g., the dashboard) to prevent cascading failures.
