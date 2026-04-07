# ✨ Just Chat - A Chatting Application 💬

📱 A modern, feature-rich chat application built with Flutter and Firebase, offering seamless real-time messaging across platforms. 

## 📱 Overview
**Just Chat** is a cross-platform messaging app that enables users to communicate instantly with text and images.  
The app uses a **custom Base64 image handling system** to reduce Firebase Storage costs while maintaining performance.

## 💡 Features

- 🔒 **Secure Authentication** - Email/Password login with Firebase Auth
- 💬 **Real-time Messaging** - Instant message delivery with Cloud Firestore
- ✅ **Message Status** - Read & Seen receipts for better communication
- 👥 **Private Chats** - One-on-one conversations
- 📸 **Media Sharing** - Send images and files with ease
- 👤 **User Profiles** - Customizable user information
- 🔔 **Push Notifications** - Stay updated with message alerts
- 🌐 **Cross-Platform** - Works on both Android & iOS
- ⚡ **Fast & Responsive** - Optimized for smooth performance
- 🟢 **Online / Offline Status**
    - Real-time presence tracking
    - Last seen timestamps
- 🔍 **User Search & Connections**
    - Add users via email
    - Personalized chat list (friends system)

## 🚀 Tech Stack
### Frontend
- **Framework**: Flutter
- **State Management**: Provider

### Backend (Firebase)
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Notifications**: Firebase Cloud Messaging (FCM)

## 🧠 Unique Implementation 

### 💡 Base64 Image System (Cost Optimization)
Instead of using Firebase Storage:

- Images are **compressed + converted to Base64**
- Stored directly inside Firestore as text
- Rendered using:
    - `Image.memory()` for Base64
    - `CachedNetworkImage` for URLs

## 💭 Highlights
 - Cross-platform support (Android & iOS) 
 - Real-time chat powered by Cloud Firestore 
 - Secure authentication with Email & Password 
 - Online/offline message sync
 - image sharing by using Base64 

## 🔄 App Workflow

1. Splash Screen → Check login
2. Login Screen → Authenticate user
3. Profile Setup → Complete user info
4. Home Screen → Chat list (Stream)
5. Chat Screen → Real-time messaging
6. Profile Screen → Update user data


## 👨‍💻 Developer

**Harshal Mendhule**  
💡 Passionate about App Development & Coding