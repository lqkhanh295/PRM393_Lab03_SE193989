# Data Model Specification

**Course:** PRM393 — Final Assignment  
**Project:** Campus Event — One Complete System on Firebase  
**Database:** Cloud Firestore (`campus-event-48443`)  

---

## 1. Firestore Collections Architecture (Appendix A)

| Collection | Key Fields (Type) | Create | Read | Update | Delete | Used by Screens |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `users/{uid}` | `role` (string: student, staff, admin), `name` (string), `email` (string), `avatarUrl` (string), `activityPoints` (int), `followedClubs` (list) | Self on first sign-in (role = `student`); or Admin | Self; Admin; Staff | Admin (role only); Self (profile fields only, role immutable) | Admin only | Mobile ProfileScreen, LoginScreen; Web User List & Header |
| `events/{id}` | `title` (string $\le$ 200), `description` (string), `category` (string), `clubName` (string), `date` (string), `time` (string), `location` (string), `capacity` (int), `registeredCount` (int), `isFeatured` (bool), `speakers` (list), `sessions` (list) | Staff, Leader, Admin | Public (authenticated & unauthenticated) | Staff/Admin (event details); Authenticated Student (atomic registration increment) | Staff/Admin (or archived flag) | Mobile HomeScreen, ExploreScreen, EventDetailScreen, CalendarScreen; Web Overview, Safety Screen |
| `registrations/{id}` | `eventId` (string), `userId` / `uid` (string), `eventTitle` (string), `studentName` (string), `studentEmail` (string), `status` (string: `pending`, `approved`, `rejected`, `cancelled`), `reason` (string), `ticketId` (string), `createdAt` (timestamp), `reviewedAt` (timestamp) | Student creating own registration (`status = 'pending'`) | Owner; Staff; Admin | Staff (pending $\rightarrow$ approved/rejected with reason); Owner (cancel while pending) | Owner while pending; Staff | Mobile EventDetailScreen, RegistrationModal; Web Review Queue |
| `tickets/{id}` | `eventId` (string), `userId` (string), `eventTitle` (string), `eventDate` (string), `eventTime` (string), `eventLocation` (string), `studentName` (string), `studentEmail` (string), `qrToken` (string), `status` (string: `active`, `checkedIn`, `cancelled`), `checkedInAt` (timestamp) | Authenticated student (via 1-Tap registration or approved registration) | Ticket Owner; Staff/Admin | Staff (check-in QR validation); Owner (cancel active ticket) | Staff/Admin | Mobile MyTicketsScreen, DigitalTicketScreen, CalendarScreen; Mobile MobileDeskScreen; Web Telemetry, Export |
| `announcements/{id}` | `title` (string $\le$ 200), `content` (string), `category` (string: `general`, `reminder`, `urgent`, `ticket_approved`), `authorRole` (string), `eventId` (string, optional), `isPinned` (bool), `createdAt` (timestamp) | Staff, Organizer, Admin | All authenticated users | Staff, Admin | Staff, Admin | Mobile AnnouncementsInboxScreen, HomeScreen Notification Badge; Web Announcements Broadcast Screen |
| `feedbacks/{id}` | `eventId` (string), `userId` (string), `rating` (int: 1..5), `comments` (string), `submittedAt` (timestamp) | Authenticated attendee | Staff, Admin | Staff, Admin | Staff, Admin | Mobile EventFeedbackScreen; Web Safety Compliance |
| `certificates/{id}` | `eventId` (string), `userId` (string), `studentName` (string), `eventTitle` (string), `issueDate` (string), `verificationHash` (string: SHA-256), `downloadUrl` (string), `createdAt` (timestamp) | Staff / Cloud Function | Owner; Staff; Admin | Staff, Admin | Staff, Admin | Mobile ProfileScreen, Certificate View; Web Student Directory Export |
| `clubs/{id}` | `name` (string), `category` (string), `description` (string), `followerCount` (int), `logoUrl` (string), `acronym` (string, opt), `officialUrl` (string, opt), `fanpageUrl` (string, opt), `email` (string, opt) | Staff, Admin | Public | Staff, Admin | Admin | Mobile ExploreScreen, EventDetailScreen, ProfileScreen; Web Budget Proposals |

---

## 2. Allowed Status Transitions & RBAC Matrix

### 2.1 Registration Status Lifecycle (`registrations/{id}`)
```
[User submits on Mobile] ──> (status: pending)
                                  │
                  ┌───────────────┴───────────────┐
                  ▼                               ▼
       [Organizer Approves on Web]     [Organizer Rejects on Web]
                  │                               │
                  ▼                               ▼
        (status: approved)              (status: rejected)
                  │
                  ▼
[Auto-generates Ticket in tickets/{id}]
[Auto-emits Announcement in announcements/{id}]
```

* **Rules Enforcement:**
  - `R-01`: User attempting to create with `status = 'approved'` is immediately **Denied** by `firestore.rules`.
  - `R-02`: Staff transitioning `pending -> approved` or `pending -> rejected` is **Allowed**.
  - `R-03`: User updating their own `users/{uid}.role` is **Denied** (anti-privilege escalation).

### 2.2 Ticket Status Lifecycle (`tickets/{id}`)
```
(status: active) ──[Gate Staff scans QR on MobileDesk]──> (status: checkedIn)
       │
       └──[Student cancels before start]───────────────> (status: cancelled)
```

---

## 3. Storage Rules Specification (`storage.rules`)

* Path: `reports/{userId}/{fileName}`
  - Read: Allowed if `request.auth.uid == userId` or `request.auth.token.role in ['staff', 'admin']`.
  - Write: Allowed if `request.auth.uid == userId` and file size $\le 10\text{ MB}$ and content type is `application/pdf`.
  - Deny all public access by default.
