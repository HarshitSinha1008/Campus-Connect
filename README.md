# CampusConnect 🎓

CampusConnect is a Flutter-based social networking application designed specifically for college students. The platform enables students to connect with peers, join academic and interest-based communities, share posts, and stay updated with campus activities through a clean and modern mobile experience.

## 🚀 Features

### 🔐 Authentication

* Secure user registration and login using Firebase Authentication.
* College profile creation with:

  * Name
  * Email
  * Branch
  * Academic Year

### 📰 Feed

* Create and share posts.
* Real-time feed updates using Cloud Firestore.
* Like posts and interact with community content.
* View posts from students across the campus.

### 👥 Communities

* Browse and search communities.
* Dedicated community pages.
* Community-specific post feeds.
* Community information and member statistics.

### 👤 User Profile

* Personalized profile page.
* Edit profile information:

  * Name
  * Branch
  * Year
  * Bio
  * Profile Picture
* View personal post history.
* Profile statistics including:

  * Total Posts
  * Total Likes

### 🛒 Marketplace

* Student-to-student marketplace.
* Buy and sell items within the campus community.
* Post listings with price and contact information.

### 🎨 Modern UI

* Clean and responsive Flutter UI.
* Material Design components.
* Smooth navigation experience.

---

## 🛠 Tech Stack

### Frontend

* Flutter
* Dart

### Backend & Database

* Firebase Authentication
* Cloud Firestore

### State Management

* Flutter Stateful Widgets
* StreamBuilder
* FutureBuilder

---

## 📂 Project Structure

```text
lib/
├── models/
│   ├── post_model.dart
│   └── community_model.dart
│
├── services/
│   ├── auth_service.dart
│   ├── post_service.dart
│   └── community_service.dart
│
├── screens/
│   ├── auth/
│   ├── feed/
│   ├── communities/
│   ├── profile/
│   └── createpost/
│
└── main.dart
```

---

## 🔥 Firebase Setup

1. Create a Firebase Project.
2. Enable Authentication.
3. Enable Cloud Firestore.
4. Enable Firebase Storage.
5. Add:

   * `google-services.json` (Android)
   * `GoogleService-Info.plist` (iOS)
6. Run:

```bash
flutter pub get
```

---

## 👨‍💻 Developer

**Harshit Ranjan Sinha**

Electrical and Electronics Engineering Student
SRM Institute of Science and Technology

### Skills Used

* Flutter
* Firebase
* Firestore
* Firebase Storage
* Authentication
* UI/UX Design

---

## 📄 License

This project is developed for learning, portfolio building, and educational purposes.

---
