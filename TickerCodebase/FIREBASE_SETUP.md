# Firebase Integration Setup Guide

## ✅ Files Created

### 1. `ViewModels/FirebaseManager.swift`
- Singleton manager for Firebase services
- Provides access to Auth, Firestore, Functions, and Analytics
- Helper methods for logging events and user properties

### 2. `Models/FirestoreModels.swift`
- `UserDocument`: User data structure for Firestore
- `SwipeRecord`: Tracks user swipe history
- `CachedCardSet`: Caches generated cards to reduce API calls

### 3. `ViewModels/AuthViewModel.swift` (Placeholder)
- Manages authentication state
- Listens for auth state changes
- Will be fully implemented in next chunk

### 4. `Views/Authentication/AuthenticationView.swift` (Placeholder)
- Placeholder for authentication UI
- Will be fully implemented in next chunk

### 5. Updated Files
- `TickerApp.swift`: Now initializes Firebase and uses AuthViewModel
- `OnboardingView.swift`: Updated to use AuthViewModel via environment object
- `InterestsView.swift`: Updated to work with AuthViewModel

## 📋 Manual Setup Steps Required

### 1. Firebase Console Setup
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create new project: **"Ticker"**
3. Enable Google Analytics (recommended)

### 2. Add iOS App
1. Click "Add app" > iOS
2. Bundle ID: `com.yourcompany.ticker` (use your actual bundle ID)
3. Download `GoogleService-Info.plist`
4. Add to Xcode project root (drag into project navigator)
5. ✅ Check "Copy items if needed"

### 3. Install Firebase SDK
In Xcode:
1. **File > Add Package Dependencies**
2. URL: `https://github.com/firebase/firebase-ios-sdk`
3. Select these packages:
   - ✅ FirebaseAuth
   - ✅ FirebaseFirestore
   - ✅ FirebaseFunctions
   - ✅ FirebaseAnalytics
4. Click **Add Package**

### 4. Enable Firebase Services

#### Authentication
1. Firebase Console > **Authentication**
2. Click **Get Started**
3. **Sign-in method** tab
4. Enable:
   - ✅ **Email/Password**
   - ✅ **Apple** (requires Xcode Signing & Capabilities setup)

#### Firestore Database
1. Firebase Console > **Firestore Database**
2. Click **Create database**
3. Choose **Start in production mode**
4. Select location (choose closest to users)
5. Click **Enable**

#### Functions (Optional for now)
1. Firebase Console > **Functions**
2. Click **Get started**
3. We'll deploy functions in a later step

### 5. Firestore Security Rules

In Firebase Console > **Firestore Database > Rules**, replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Saved investments subcollection
      match /saved_investments/{investmentId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Swipe history subcollection
      match /swipe_history/{swipeId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Cache for generated cards (read-only for clients)
    match /card_cache/{cacheId} {
      allow read: if request.auth != null;
      allow write: if false; // Only functions can write
    }
  }
}
```

Click **Publish** to save rules.

### 6. Apple Sign-In Setup (Optional but Recommended)

In Xcode:
1. Select your project in navigator
2. Select your target
3. **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **Sign in with Apple**
6. Configure in Firebase Console:
   - Authentication > Sign-in method > Apple
   - Enter your app's bundle ID
   - Download OAuth key
   - Upload to Firebase

## 🔧 Code Integration Status

### ✅ Completed
- FirebaseManager singleton created
- Firestore data models defined
- TickerApp updated with Firebase initialization
- AuthViewModel placeholder created
- AuthenticationView placeholder created
- Onboarding flow updated to use AuthViewModel

### ⏳ Pending (Next Chunk)
- Full AuthViewModel implementation
- AuthenticationView UI (Email/Password, Apple Sign-In)
- Firestore integration for user profiles
- Card caching system
- Swipe history tracking

## 🧪 Testing

After setup, you should be able to:
1. Build the project (may show warnings about missing AuthViewModel methods)
2. See AuthenticationView placeholder
3. Firebase should initialize without errors

## ⚠️ Important Notes

1. **Bundle ID**: Make sure your Xcode bundle ID matches Firebase app bundle ID
2. **GoogleService-Info.plist**: Must be in project root and added to target
3. **Security Rules**: Start in production mode, then customize rules
4. **API Keys**: Firebase keys in GoogleService-Info.plist are safe to include in app (they're public)

## 🚀 Next Steps

Wait for **CHUNK 2** to implement:
- Complete authentication flow
- Firestore user document creation
- Profile syncing
- Card caching logic

---

**Status**: ✅ Firebase setup files created and integrated
**Next**: Implement authentication UI and Firestore operations

