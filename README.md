# Family Circle 👨‍👩‍👧‍👦

**Family Circle** is a private, secure family management app built with Flutter and Firebase. It brings every part of family life — conversations, schedules, finances, memories, and safety information — into a single, unified space, replacing the scattered mix of group chats, spreadsheets, and paper records most families rely on today.

At the heart of the app is the **AI Mediator**: when a disagreement arises within the family, it listens to both sides of the story and offers a calm, neutral, and balanced perspective — powered by Claude AI, running securely on the backend so no API key is ever exposed inside the app itself.

The app is production-ready and structured for release on the Google Play Store, with a fully deployed Firebase backend, security rules, composite indexes, and a serverless AI proxy already in place.

---

## 📖 Overview

Most families today coordinate life through a patchwork of tools — a WhatsApp group for chat, a shared note for expenses, someone's memory for birthdays, and no reliable record of medical information or emergency contacts. Family Circle consolidates all of this into one application, organized around the idea of a **Family** as the core unit: every member joins one (or more) families via a secure invite link, and everything — chat, tasks, calendar, expenses, media, and records — is scoped to that family group.

The app is designed to feel warm and personal rather than corporate, with playful touches (mood check-ins, "On This Day" memories, AI-generated yearly family stories) alongside genuinely useful infrastructure (task reminders, expense splitting, medical records, emergency contacts).

---

## ✨ Features

### 💬 Communication
- **Group Chat** — real-time text messaging, voice notes, photo sharing, message likes, full message search, and the ability to pin important messages to the top of a conversation.
- **Typing Indicators & Presence** — see when a family member is typing, and whether they're currently online or when they were last active.
- **AI Mediator** — describe both sides of a disagreement and receive a neutral, thoughtful resolution suggestion. All AI calls are routed through a secure Firebase Cloud Function, so the underlying API key never lives inside the mobile app.
- **Family News Feed** — a shared space for family-wide announcements and updates.

### 📋 Organization
- **Shared Calendar** — track birthdays, anniversaries, and family events, with automatic reminder notifications sent ahead of time.
- **Tasks** — assign household chores and responsibilities to family members, complete with due-date reminders.
- **Expense Tracking** — log shared family expenses and see how costs are split.
- **Documents** — securely save links to important family documents (ID cards, property papers, etc.) for quick access when needed.
- **Event Planning** — plan larger occasions (weddings, Eid, birthdays) with budget tracking, guest lists, and a shared to-do checklist.
- **Event Photos** — each planned event gets its own dedicated photo album.

### 👨‍👩‍👧 Family & Safety
- **Family Tree** — visually map out how family members are related to one another.
- **Emergency Contacts** — one-tap access to critical phone numbers when every second counts.
- **Medical Records** — securely store health information for family members in one trusted place.
- **Call History** — a record of calls made within the family circle.
- **Members & Roles** — admin and member permission levels, with secure invite-link based onboarding.

### 🎉 Memories & Fun
- **Media Gallery** — photos and videos are stored via Cloudinary rather than on-device, so the family archive grows without consuming phone storage.
- **Mood Check-in** — a lightweight daily "how is everyone feeling" ritual.
- **On This Day** — past memories resurface automatically, the way social media "memories" features do.
- **AI Family Story** — at the end of each year, the AI generates a warm, narrative summary of the family's shared moments — a digital yearbook.
- **Birthday Reminders** — never miss a family birthday again.

### 🛡️ Admin & Control
- **Super Admin Dashboard** — a platform-wide control panel for managing users and families across the entire app (intended for the app owner/operator, not regular family admins).
- **Mediation History** — a record of past AI Mediator sessions and their resolutions.
- **Backup & Restore** — safeguard family data against loss.
- **Settings** — dark mode, notification preferences, and account management.

---

## 🛠️ Tech Stack

| Layer | Technology | Notes |
|---|---|---|
| Frontend | Flutter (Dart) | Cross-platform — Android and iOS from one codebase |
| State Management | Riverpod | Reactive, testable app state |
| Authentication | Firebase Auth + Google Sign-In | Secure account creation and login |
| Database | Cloud Firestore | Real-time, family-scoped data storage |
| Media Storage | Cloudinary | Chosen over Firebase Storage for its generous free tier (no billing card required to get started) |
| Push Notifications | Firebase Cloud Messaging + local scheduled notifications | Covers both server-triggered and locally-scheduled reminders |
| AI | Claude API (Anthropic), via a Firebase Cloud Function proxy | Keeps the API key server-side only — never bundled into the app |
| Offline Support | sqflite | Local caching for a smoother experience with intermittent connectivity |

---

## 📂 Project Structure

```
lib/
├── models/       # Data models — User, Family, Chat, Task, Event, Expense, Media, Invite Link...
├── providers/    # Riverpod providers — auth state, groups/families, media, theme
├── screens/      # 34 screens covering every feature — chat, calendar, tasks, family tree,
│                 #   emergency contacts, medical records, super admin dashboard, and more
├── services/     # Business logic — Firebase, Cloudinary uploads, AI calls, notifications,
│                 #   presence tracking, search, backups
├── utils/        # Shared constants, helper functions, and the app's visual theme
├── widgets/      # Reusable UI components used across multiple screens
└── main.dart     # App entry point

functions/        # Firebase Cloud Function — the secure server-side Claude API proxy
```

---

## 🚀 Getting Started (Local Development)

### Prerequisites
Before you begin, make sure you have:
- The latest stable **Flutter SDK** installed
- **Firebase CLI** installed (`npm install -g firebase-tools`)
- A Firebase project on the **Blaze (pay-as-you-go)** plan — this is required for Cloud Functions and Secret Manager, though the free monthly quota is generous enough that a small family app is unlikely to incur real charges
- An [Anthropic API key](https://console.anthropic.com) for the AI Mediator feature
- A free [Cloudinary](https://cloudinary.com) account for media storage

### 1. Clone the repository and install dependencies
```bash
git clone https://github.com/usmanch-15/family_circle.git
cd family_circle
flutter pub get
```

### 2. Create your `.env` file
In the project root, create a `.env` file with:
```
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_UPLOAD_PRESET=your_unsigned_preset
```
Note: the Claude API key is **not** placed here. It's configured separately as a server-side secret (see step 4) and is never present anywhere in the client app.

### 3. Deploy Firebase security rules and indexes
```bash
firebase login
firebase deploy --only firestore:rules,firestore:indexes,storage
```

### 4. Deploy the Cloud Function that powers the AI Mediator
```bash
cd functions
npm install
cd ..
firebase functions:secrets:set CLAUDE_API_KEY
firebase deploy --only functions
```
When prompted, paste your real Anthropic API key — it will be stored securely in Firebase Secret Manager, accessible only to the Cloud Function itself.

### 5. Run the app
```bash
flutter run
```

---

## 🔒 Security Notes

- **API key isolation**: the Claude API key lives exclusively in Firebase Secret Manager and is only ever read by the server-side Cloud Function. It is never embedded in the compiled app, so it cannot be extracted by decompiling the APK.
- **Firestore rules**: every collection's security rules verify that the requesting user is an actual member of the relevant family before granting read or write access.
- **Storage/Cloudinary uploads**: uploads are scoped to family folders and size-limited to prevent abuse.
- **Super Admin isolation**: the platform-wide admin dashboard uses a separate authentication flow and is governed by its own, stricter Firestore rules — regular family admins have no access to it.

---

## 📱 App Information

- **Package name**: `com.familycircle.app`
- **Platforms**: Android (with iOS project support included)

---

## 🤝 Contributing

This is currently a private project. Bug reports and feature suggestions are welcome via GitHub issues.

---

## 📄 License

Private project — all rights reserved.
