# 📘 Just Chat - Complete Developer Guide & Technical Documentation

This document serves as the ultimate developer manual for the **"Just Chat"** application. It explains every core feature, the technical decisions behind it, the libraries used, and exactly how data flows throughout the app.

---

## 📑 Table of Contents
1. [Project Overview & Summary](#1-project-overview--summary)
2. [Technologies Used](#2-technologies-used)
3. [Database Architecture & Data Models](#3-database-architecture--data-models)
4. [App Workflow (Screen by Screen)](#4-app-workflow-screen-by-screen)
5. [Core Features & Technical Implementation](#5-core-features--technical-implementation)
    * [A. Authentication System](#a-authentication-system)
    * [B. Custom Base64 Image Implementation (Cost Saving)](#b-custom-base64-image-implementation-cost-saving)
    * [C. Real-time Chat Engine](#c-real-time-chat-engine)
    * [D. Online Presence & Status Tracking](#d-online-presence--status-tracking)
    * [E. User Searching & Connections](#e-user-searching--connections)
    * [F. Profile Management](#f-profile-management)
6. [Future Enhancements / Maintenance](#6-future-enhancements--maintenance)

---

## 1. Project Overview & Summary
**Just Chat** is a scalable, real-time messaging application created using Flutter and Firebase. The app is specifically designed to minimize backend costs by entirely bypassing standard cloud storage platforms. Instead of uploading media (like profile pictures or chat images) to Firebase Storage, the app relies on **Base64 string encoding** combined with heavy local compression, allowing image data to be saved as regular text natively inside Google Cloud Firestore.

---

## 2. Technologies Used
* **Flutter** (Dart): The entire frontend framework providing a native compiling codebase.
* **Firebase Authentication**: Handles secure account creation and OAuth identity tracking.
* **Cloud Firestore (NoSQL)**: Stores users, messages, and relationships in real-time document hierarchies.
* **Important Flutter Packages:**
  * `google_sign_in`: Implements third-party Google Account logins.
  * `cached_network_image`: Responsibly loads standard HTTP URLs with error handling and native caching logic.
  * `image_picker`: Taps into local OS hardware (Camera & Gallery) to fetch native byte data.
  * `emoji_picker_flutter`: Cross-platform rendering for conversational emojis without building custom soft keyboards.

---

## 3. Database Architecture & Data Models

In Cloud Firestore, the data is structured into two main collections to prevent redundant fetching. 

### Collection: `users`
Each document has the ID of the user's Auth UID.
* **Fields:** 
  * `about` (String)
  * `avatar` (String) - Points to hardcoded localized assets (e.g., 'avatar1') if configured.
  * `created_at` (String/Timestamp)
  * `email` (String)
  * `id` (String) - Maps to Firebase Auth UID
  * `image` (String) - IMPORTANT: Can be an HTTP URL (from Google SignIn) OR a highly-compressed Base64 text string (if custom uploaded).
  * `is_online` (Boolean)
  * `last_active` (String)
  * `name` (String)
  * `push_token` (String)

*(Model mapping class: `lib/models/chat_user.dart`)*

### Collection: `messages` (Nested inside User nodes)
Chats are stored in subcollections between exactly two users. The subcollection path is named uniquely using a combination of the two user IDs: `chats/{conversation_id}/messages/`.
* **Fields:**
  * `fromId` (String)
  * `toId` (String)
  * `msg` (String) - Can be literal chat text, OR a Base64 text string representing bytes.
  * `read` (String) - Empty if unread, holds a timestamp string when read.
  * `sent` (String) - Time sent.
  * `type` (String) - Interpreted strictly by our Model as enum `Type.text` or `Type.image`.

*(Model mapping class: `lib/models/message.dart`)*

---

## 4. App Workflow (Screen by Screen)
1. **`SplashScreen`**: Initializes animations. Silently checks `APIs.auth.currentUser`. 
2. **`LoginScreen`**: If no user is logged in, displays options to log in via Google or Email/Password.
3. **`ProfileSetupScreen`**: (Intercept) If a user authenticates but their name is empty or defaults to "User", `HomeScreen` intercepts this and forces them here to fill out mandatory details.
4. **`HomeScreen`**: Renders the core dashboard. Uses a `StreamBuilder` connected to `APIs.getMyUsersId()` to show all current chat relationships.
5. **`ChatScreen`**: Entered when a User Card is clicked. Connects to `APIs.getAllMessages()` to open up a two-way street P2P chat room.
6. **`ProfileScreen`**: Accessible from the App Bar. Settings page for updating local attributes (Base64 Profile Images, Avatars, About, and Name) + Logout utility.

---

## 5. Core Features & Technical Implementation

### A. Authentication System
* **Implementation:** Located in `lib/screens/auth/`. The core logic connects to `FirebaseAuth.instance`.
* **How it works:** When a user taps Google Sign In, `google_sign_in` package creates a credential token. We pass that token to Firebase. If successful, `APIs.createUser()` generates a default node inside `Firestore -> users` containing their email, google photo, and a `created_at` timestamp.

### B. Custom Base64 Image Implementation (Cost Saving)
**The Problem:** Traditional "File Uploading" to Storage services gets expensive quickly. 
**The Solution:** 
1. **Selection:** Users pick an image with `ImagePicker(imageQuality: 50)` (heavily compressed to ensure string size remains within firestore limits). 
2. **Encoding:** We use Dart's native `File(path).readAsBytes()` and run `base64Encode(bytes)`. The output is a massive string of random text.
3. **Storage:** That string is sent to Firestore as literal text via `APIs.sendMessage()` passing `Type.image` OR `APIs.updateProfilePicture()`.
4. **Decoding & UI:** When the UI tries to load an image, it uses a ternary check everywhere (`image.startsWith('http')`). 
   * *If True:* The app routes it to `CachedNetworkImage` (it's a Google Auth photo). 
   * *If False:* The app uses `Image.memory(base64Decode(image))` to compile the bytes back into a tangible `Image` widget dynamically. We include safety wrappers (`isNotEmpty`) to prevent `FormatException` crashes.

### C. Real-time Chat Engine
* **Implementation:** The `ChatScreen` relies on Flutter's brilliant `StreamBuilder`. 
* **How it works:** We point a Stream at a Firestore collection (`APIs.getAllMessages()`). Firestore acts as an active listener. The moment any user device invokes `APIs.sendMessage()`, Firestore updates the node, and the Stream instantly auto-triggers Flutter's `setState()` underneath the hood. 
* **Widget Parsing:** The `MessageCard` widget checks `message.type == Type.text`. If so, it returns standard text formatting. If `Type.image`, it jumps to the `Image.memory` constructor.

### D. Online Presence & Status Tracking
* **Implementation:** Built directly into the initialization inside `HomeScreen` using `SystemChannels.lifecycle.setMessageHandler`.
* **How it works:** Flutter inherently tracks if the OS minimizes an app or puts an app to sleep. 
  1. When state changes to `resume`, we run `APIs.updateActiveStatus(true)` setting `is_online = true`. 
  2. When state changes to `pause`, we trigger `is_online = false` and log the `last_active` timestamp.
  3. **Visual Feedback:** In `chat_screen.dart` App Bar, we evaluate if the Remote User's database `is_online` equals true. If false, we run `MyDateUtil.getLastActiveTime` to calculate logical human text (e.g., *"Last seen yesterday at 1:20 PM"*).

### E. User Searching & Connections
* **Implementation:** Located in `HomeScreen` and `APIs.addChatUser()`.
* **How it works:** To connect with friends, Firestore handles security gracefully via the `addChatUser(email)` dialog. We run a query checking if the target `email` exists in the system. If found, we append the target UID directly inside the currently logged-in user's sub-collection (`APIs.me.id / my_users`). The main `StreamBuilder` only ever queries people located inside that specific sub-collection, acting as an implicit "Friends List".

### F. Profile Management
* **Implementation:** `lib/screens/profile_screen.dart`.
* **How it works:** Binds tightly to `APIs.me` (the locally cached copy of the current `ChatUser`). Users can pick a stylized *Avatar* (which just sets the String field `avatar` to 'avatar3' etc) OR pick a custom Base64 image. Upon pressing **Update**, `APIs.updateUserInfo()` fires all modified fields linearly into Firestore.

---

## 6. Future Enhancements / Maintenance
1. **Limits & Optimization (Pagination):** If a chat exceeds 10,000 messages, `getAllMessages` will fetch a monumental payload. For future optimization, engineers should introduce `orderBy().limit(50)` on Firestore streams, loading older messages strictly "On Scroll".
2. **Push Notifications:** The `push_token` infrastructure exists inside the models. Integrating `firebase_messaging` to send targeted JSON payloads via a lightweight NodeJS backend or Firebase Cloud Function will fully complete the "modern" messaging experience.
3. **Database Rules Restriction:** By default, Firebase development security rules are open. Prior to publishing to an App Store, enforce Firestore rules so that a user can only Read/Write to documents under `users` IF `request.auth.uid != null`.




