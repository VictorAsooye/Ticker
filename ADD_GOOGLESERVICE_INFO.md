# Add GoogleService-Info.plist to Fix Firebase Crash

## Problem
The app crashes because Firebase can't find `GoogleService-Info.plist`. This file contains your Firebase project configuration.

## Solution: Download and Add GoogleService-Info.plist

### Step 1: Create Firebase Project (if you haven't already)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"** or select existing project
3. Enter project name: **"Ticker"**
4. Follow the setup wizard (enable/disable Google Analytics as you prefer)
5. Click **"Continue"** and **"Create project"**

### Step 2: Add iOS App to Firebase

1. In Firebase Console, click **"Add app"** (or the iOS icon)
2. Select **iOS**
3. Enter your **Bundle ID**:
   - Check your Bundle ID in Xcode:
     - Select **"TickerCodebase"** project
     - Select **"TickerCodebase"** target
     - Go to **"General"** tab
     - Look for **"Bundle Identifier"** (should be something like `Ticker.TickerCodebase`)
   - Enter this Bundle ID in Firebase
4. Enter **App nickname** (optional): "Ticker iOS"
5. Enter **App Store ID** (optional, leave blank for now)
6. Click **"Register app"**

### Step 3: Download GoogleService-Info.plist

1. On the next screen, click **"Download GoogleService-Info.plist"**
2. Save the file to your Downloads folder

### Step 4: Add to Xcode Project

1. **Open Xcode**
2. In Project Navigator, right-click on **"TickerCodebase"** (the blue project icon)
3. Select **"Add Files to TickerCodebase..."**
4. Navigate to your Downloads folder
5. Select **"GoogleService-Info.plist"**
6. **IMPORTANT**: Check these options:
   - ✅ **"Copy items if needed"** (checked)
   - ✅ **"Add to targets: TickerCodebase"** (checked)
7. Click **"Add"**

### Step 5: Verify File Location

The file should appear in your Project Navigator at the root level:
```
TickerCodebase/
  ├── GoogleService-Info.plist  ← Should be here
  ├── TickerApp.swift
  ├── Info.plist
  └── ...
```

### Step 6: Verify Target Membership

1. Select **"GoogleService-Info.plist"** in Project Navigator
2. In the right sidebar (File Inspector), check **"Target Membership"**
3. Make sure **"TickerCodebase"** is checked ✅

### Step 7: Clean and Rebuild

1. **Clean Build Folder**: `Shift + Cmd + K`
2. **Rebuild**: `Cmd + B`
3. **Run**: `Cmd + R`

---

## Quick Test: Verify File is Found

After adding the file, you can verify it's in the right place:

1. In Xcode, select **"GoogleService-Info.plist"**
2. It should open and show Firebase configuration keys like:
   - `PROJECT_ID`
   - `BUNDLE_ID`
   - `API_KEY`
   - etc.

---

## Troubleshooting

### If file still not found:

1. **Check file location**: The file should be at the project root, not inside a subfolder
2. **Check target membership**: File Inspector > Target Membership > TickerCodebase should be checked
3. **Check Build Phases**: 
   - Select **"TickerCodebase"** target
   - Go to **"Build Phases"** tab
   - Expand **"Copy Bundle Resources"**
   - Make sure `GoogleService-Info.plist` is listed there

### If you don't have a Firebase project yet:

You can temporarily disable Firebase to test other parts of the app, but you'll need Firebase for authentication and backend features.

---

## Expected Result

After adding `GoogleService-Info.plist`, the app should:
- ✅ Launch without crashing
- ✅ Initialize Firebase successfully
- ✅ Allow authentication to work


