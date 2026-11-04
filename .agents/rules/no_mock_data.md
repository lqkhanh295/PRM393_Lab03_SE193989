---
name: no-mock-data
description: Enforce strict zero-mock data policy across all Flutter and Web components.
trigger: always_on
---

# STRICT ZERO-MOCK DATA POLICY

1. **Zero Mock/Fake Data:**
   - Under no circumstances should mock data, dummy lists, or fake fallback models be placed in `lib/`.
   - Never inject hardcoded lists of `EventModel`, `TicketModel`, `ClubModel`, `SpeakerQuestionModel`, or `CertificateModel`.

2. **Real Cloud Data Sources:**
   - Cloud Firestore collections (`events`, `tickets`, `clubs`, `users`, `certificates`, `feedback`, `questions`).
   - Firebase Authentication for live student profiles.
   - Real Firebase Cloud Messaging (FCM) tokens and messages.
   - Real Cloud Storage for PDF certificates (`reports/{uid}/...`).
   - Real Firebase Remote Config for remote dynamic variables.

3. **Empty State Compliance:**
   - If a Firestore collection or user query returns empty, return an empty `List` (`[]`) and render the proper `EmptyView` / `StateEmpty`.
   - Do NOT substitute an empty result with mock data.

4. **Authentication & Calendar:**
   - Form inputs must not be pre-filled with demo credentials.
   - Calendar must dynamically bind to `DateTime.now()` and real Firestore events.
