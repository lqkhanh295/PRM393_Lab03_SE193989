# AGENTS GUIDELINE: STRICT ZERO-MOCK DATA POLICY

This file enforces that all autonomous coding agents, tools, and pair programming assistants must never introduce mock, dummy, or hardcoded fallback data into the application.

Please refer to [GEMINI.md](./GEMINI.md) for the full specification.

## Core Mandates:
1. **Never create or inject mock data** (`_demoEvents`, `_mockTickets`, fake users, dummy lists).
2. **Always query real Firebase services** (Cloud Firestore, Firebase Auth, FCM, Cloud Storage, Remote Config).
3. **Always render standard `EmptyView` / `StateEmpty`** when data collections are empty or offline.
4. **Never prefill forms with mock credentials** or add fake demo login bypasses.
5. **Always bind UI dynamically** to real runtime dates and Firestore documents.
