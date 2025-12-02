# 🚀 Launch Day Checklist - Finish Ticker App Today

## 🔴 CRITICAL: Fix the Black Screen Crash (Do This First!)

The black screen is caused by **missing Firebase configuration**. You need to add `GoogleService-Info.plist`.

### Step 1: Create Firebase Project (5 minutes)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"** or select existing project
3. Project name: **"Ticker"**
4. Follow setup wizard (enable/disable Google Analytics - your choice)
5. Click **"Create project"**

### Step 2: Add iOS App to Firebase (2 minutes)

1. In Firebase Console, click **"Add app"** (or iOS icon)
2. Select **iOS**
3. **Bundle ID**: `Ticker.TickerCodebase` (this is your app's bundle ID)
4. **App nickname**: "Ticker iOS" (optional)
5. Click **"Register app"**

### Step 3: Download GoogleService-Info.plist (1 minute)

1. On the next screen, click **"Download GoogleService-Info.plist"**
2. Save it to your Downloads folder

### Step 4: Add to Xcode (2 minutes)

1. **Open Xcode**
2. In Project Navigator, right-click on **"TickerCodebase"** (blue project icon)
3. Select **"Add Files to TickerCodebase..."**
4. Navigate to Downloads and select **"GoogleService-Info.plist"**
5. **IMPORTANT**: Check these options:
   - ✅ **"Copy items if needed"** (checked)
   - ✅ **"Add to targets: TickerCodebase"** (checked)
6. Click **"Add"**

### Step 5: Enable Firebase Services (3 minutes)

#### Enable Authentication:
1. Firebase Console > **Authentication**
2. Click **"Get Started"**
3. Go to **"Sign-in method"** tab
4. Click **"Email/Password"**
5. Toggle **"Enable"** → **"Save"**

#### Enable Firestore Database:
1. Firebase Console > **Firestore Database**
2. Click **"Create database"**
3. Select **"Start in test mode"** (for now, you can secure it later)
4. Choose a location (pick closest to you)
5. Click **"Enable"**

### Step 6: Test the App (1 minute)

1. **Clean Build**: `Shift + Cmd + K`
2. **Build**: `Cmd + B`
3. **Run**: `Cmd + R`

**Expected Result**: You should now see the **AuthenticationView** (login screen) instead of a black screen!

---

## 🟡 IMPORTANT: Complete Authentication UI

The authentication screen is currently just placeholder text. You need a working login/signup screen.

**Options:**
- **Option A**: I can create a full authentication UI for you (email/password + Apple Sign In)
- **Option B**: You can use a simple test account for now and finish UI later

**For today's launch, I recommend Option A** - let me know and I'll build it now.

---

## 🟢 NICE TO HAVE: App Icon

1. Export your logo as **1024x1024 PNG**
2. In Xcode, add `Assets.xcassets` to project (see `ADD_ASSETS_TO_XCODE.md`)
3. Drag your PNG into the AppIcon slot

**This won't block the app from running**, but it's needed for App Store submission.

---

## 📋 Complete Setup Checklist

### Firebase Setup ✅
- [ ] Create Firebase project
- [ ] Add iOS app to Firebase
- [ ] Download GoogleService-Info.plist
- [ ] Add plist to Xcode project
- [ ] Enable Email/Password authentication
- [ ] Enable Firestore Database

### App Functionality ✅
- [ ] Fix black screen (add GoogleService-Info.plist)
- [ ] Complete authentication UI
- [ ] Test login/signup flow
- [ ] Test onboarding flow
- [ ] Test card swiping
- [ ] Test saving investments

### App Store Prep ✅
- [ ] Add app icon
- [ ] Test on physical device
- [ ] Review all screens
- [ ] Check for crashes/errors

---

## ⚡ Quick Start Commands

After adding GoogleService-Info.plist:

```bash
# Clean and rebuild
Shift + Cmd + K  (Clean)
Cmd + B          (Build)
Cmd + R          (Run)
```

---

## 🆘 If You Still See Black Screen

1. **Check Console** in Xcode (bottom panel) for error messages
2. **Verify** GoogleService-Info.plist is in the project root
3. **Verify** it's added to the TickerCodebase target
4. **Clean Derived Data**: 
   - Xcode > Preferences > Locations
   - Click arrow next to Derived Data path
   - Delete the TickerCodebase folder
   - Rebuild

---

## 🎯 Priority Order for Today

1. **FIRST**: Add GoogleService-Info.plist (fixes black screen) ⚡
2. **SECOND**: Enable Firebase Auth & Firestore (makes app functional) ⚡
3. **THIRD**: Complete authentication UI (so users can actually use it) ⚡
4. **FOURTH**: Add app icon (for App Store) 📱
5. **FIFTH**: Test everything end-to-end ✅

---

## 💡 Need Help?

If you get stuck on any step, tell me:
1. What step you're on
2. What error you're seeing (if any)
3. Screenshot of the issue

I'll help you fix it immediately!

