# Gap Review: Evolution from Lab 2 & Lab 3 to Final Assignment

**Course:** PRM393 — Mobile Programming  
**Topic:** Campus Event — FPT University Mobile & Cloud System  
**Repository:** `PRM393_Final_SE193989`  
**Author:** Lê Quốc Khánh (SE193989) & Team  

---

## 1. Executive Summary

This document reviews the architecture and scope evolution across the three stages of the PRM393 curriculum:
1. **Lab 2 (AI-Assisted UI/UX Design):** Persona, 3 user flows, 8 core screens in Figma, and design system tokens (`flutter-handoff.md`).
2. **Lab 3 (Cloud-Enabled Mobile App):** Full Flutter MVVM implementation, 6 Firebase services, zero-mock policy, automated testing with Google ARTEMIS, and AI-assisted code review.
3. **Final Assignment (One Complete System on Firebase):** Unified multi-role architecture combining Flutter Mobile (Student persona), Web Admin (Organizer & Staff personas), shared Cloud Firestore backend, real-time Cross-Role flow, and Level 2 Google Gemini AI structured output.

---

## 2. Gap Closure Matrix

| Category | Lab 2 Design Baseline | Lab 3 Mobile App Scope | Final Assignment Unified System | Status |
| :--- | :--- | :--- | :--- | :---: |
| **Client Platforms** | Mobile Figma Prototype (360–412 dp) | Android Mobile App (Flutter) | **2 Clients:** Flutter Mobile App + Web Admin Portal on Firebase Hosting | **CLOSED** |
| **Data Source & Mock Policy** | Static mockup frames | Real Firebase Services (Spark plan); Strict Zero-Mock Data Policy | Cloud Firestore real-time collections (`events`, `tickets`, `registrations`, `announcements`) | **CLOSED** |
| **Role-Based Access Control** | Single persona (Student) | Student authentication via Google SSO & FPT Email domain | **Multi-role (Student, Staff, Admin):** Role-based Security Rules with deny-by-default and Emulator tests | **CLOSED** |
| **System Interaction** | Isolated screen clicks | Mobile internal navigation & local actions | **Cross-Role Flow:** Mobile student submits registration (`pending`) $\rightarrow$ Web Admin reviews & approves $\rightarrow$ Real-time Mobile ticket issuance | **CLOSED** |
| **Communication Channel** | Local modal popups | FCM background/foreground push notifications | **Real-time Announcements Inbox:** Web Admin broadcast form writes to `announcements` collection $\rightarrow$ Live Mobile Inbox | **CLOSED** |
| **Artificial Intelligence** | Design ideation | AI Code Review record (5 findings, 3 commit fixes) | **Level 2 Gemini Feature:** Structured JSON $\rightarrow$ Dart model event insights with Remote Config toggle & zero-PII | **CLOSED** |
| **Automated Testing** | None | 10 Google ARTEMIS E2E tests with pytest suite | ARTEMIS Mobile E2E + Firebase Security Rules Emulator unit tests (`R-01`, `R-02`, `R-03`) | **CLOSED** |

---

## 3. Detailed Component Review

### 3.1 Mobile Client (Flutter)
* **Lab 2/3 Scope Finished:** 14 screens implemented with high typographic contrast and hairline rules (`AppTheme`). All 3 user flows (Discover $\rightarrow$ Register $\rightarrow$ Check-in $\rightarrow$ Live Q&A $\rightarrow$ Feedback & Certificate) execute end-to-end.
* **Announcements Inbox:** Added [`AnnouncementsInboxScreen`](file:///d:/University/FA26/PRM391/Lab2_3/lib/screens/inbox/announcements_inbox_screen.dart) governed by [`InboxViewModel`](file:///d:/University/FA26/PRM391/Lab2_3/lib/viewmodels/inbox_viewmodel.dart), providing real-time streaming of organizer broadcasts.
* **Strict Zero-Mock Enforcement:** Guaranteed by [`GEMINI.md`](file:///d:/University/FA26/PRM391/Lab2_3/GEMINI.md) and [`AGENTS.md`](file:///d:/University/FA26/PRM391/Lab2_3/AGENTS.md). 100% of event cards, tickets, and calendar markers query Cloud Firestore.

### 3.2 Web Admin Client (Web Portal on Firebase Hosting)
* **4 Dedicated Operations Screens:**
  1. **Dashboard & Overview:** $\ge 3$ KPI aggregation figures, real-time check-in velocity chart, and live telemetry.
  2. **Review Queue (Cross-Role):** Real-time list of pending event registrations for approval or rejection with reason.
  3. **Event & Budget Management:** Operational approval for club activity budgets and PCCC fire-safety compliance.
  4. **Student Directory & Export:** Roster search, filter, and 10,000-row Excel export with SHA-256 verification hashes.
* **Announcement Broadcast Form:** Allows organizers to broadcast instant announcements with priority tags (`ticket_approved`, `urgent`, `reminder`, `general`) to student mobile inboxes.

### 3.3 Shared Backend & Cloud Firestore
* **Data Model:** Centralized schema documented in [`docs/data-model.md`](file:///d:/University/FA26/PRM391/Lab2_3/docs/data-model.md) covering `users`, `events`, `tickets`, `registrations`, `announcements`, `feedbacks`, and `certificates`.
* **Security Rules:** Production-grade `firestore.rules` (578 lines) enforcing deny-by-default, field whitelisting (`hasOnlyAllowedFields`), and strict role-based access.

### 3.4 Gemini AI Feature
* Implements **Level 2 Structured Output** using Gemini 1.5 Flash.
* Takes public event details (Zero-PII) and returns typed JSON containing `summary`, `keyTakeaways`, `recommendedAudience`, and `suggestedQuestions`.
* Governed by Remote Config flags (`enable_gemini_insights`, `gemini_model_name`) with deterministic offline fallback.
