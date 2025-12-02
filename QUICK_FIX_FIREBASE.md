# 🔧 QUICK FIX: Add Firebase Packages to Xcode

## The Problem
You're seeing: **"No such module 'FirebaseCore'"**

This means the Firebase SDK packages haven't been added to your Xcode project yet.

---

## ✅ SOLUTION: Follow These Exact Steps

### Step 1: Open Your Project
1. Open **Xcode**
2. Open `TickerCodebase.xcodeproj`

### Step 2: Add Firebase Package
1. In Xcode, click on **"TickerCodebase"** (blue icon) in the left sidebar (Project Navigator)
2. Make sure the **PROJECT** (not target) is selected at the top
3. Click on the **"Package Dependencies"** tab
4. Click the **"+"** button at the bottom left
5. In the search box, paste: `https://github.com/firebase/firebase-ios-sdk`
6. Click **"Add Package"**
7. Select version: **"Up to Next Major Version"** with `11.0.0` or latest
8. Click **"Add Package"** again
9. **IMPORTANT**: Check these 5 products:
   - ✅ FirebaseCore
   - ✅ FirebaseAuth  
   - ✅ FirebaseFirestore
   - ✅ FirebaseFunctions
   - ✅ FirebaseAnalytics
10. Make sure the **"TickerCodebase"** target is selected on the right
11. Click **"Add Package"**

### Step 3: Add RevenueCat Package
1. Click the **"+"** button again in Package Dependencies
2. In the search box, paste: `https://github.com/RevenueCat/purchases-ios`
3. Click **"Add Package"**
4. Select version: **"Up to Next Major Version"** with `5.0.0` or latest
5. Click **"Add Package"** again
6. Check: ✅ **RevenueCat**
7. Make sure **"TickerCodebase"** target is selected
8. Click **"Add Package"**

### Step 4: Clean and Build
1. Press **Shift + Cmd + K** (Clean Build Folder)
2. Press **Cmd + B** (Build)
3. The error should be gone! ✅

---

## 🎯 Visual Guide

**Where to find Package Dependencies:**
```
Xcode Window
├── Left Sidebar (Project Navigator)
│   └── TickerCodebase (blue icon) ← Click this
│       └── PROJECT: TickerCodebase ← Make sure this is selected
│           └── [Tabs at top]
│               └── "Package Dependencies" tab ← Click here
│                   └── "+" button ← Click to add packages
```

---

## ❌ If It Still Doesn't Work

### Option 1: Check Target Membership
1. Select your project in Navigator
2. Select **TARGET: TickerCodebase** (not PROJECT)
3. Go to **"General"** tab
4. Scroll to **"Frameworks, Libraries, and Embedded Content"**
5. Make sure you see:
   - FirebaseCore
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseFunctions
   - FirebaseAnalytics
   - RevenueCat
6. If any are missing, click **"+"** and add them

### Option 2: Verify Package Resolution
1. Go to **File → Packages → Resolve Package Versions**
2. Wait for it to finish
3. Try building again

### Option 3: Delete Derived Data
1. **Xcode → Settings** (or Preferences)
2. Go to **"Locations"** tab
3. Click the arrow next to **"Derived Data"** path
4. Find and delete the **"TickerCodebase-..."** folder
5. Clean build folder (Shift+Cmd+K)
6. Build again (Cmd+B)

---

## ✅ Verification

After adding packages, you should see in the Project Navigator:
```
TickerCodebase
├── Package Dependencies
│   ├── firebase-ios-sdk
│   └── purchases-ios
```

And when you build, you should see:
- ✅ **Build Succeeded** (no errors)

---

## 📝 Notes

- The packages will download automatically (may take 1-2 minutes)
- Make sure you have an internet connection
- If Xcode asks to "Trust" the packages, click **"Trust"**

---

**Still having issues?** Make sure:
1. You're using Xcode 14.0 or later
2. You have an active internet connection
3. The packages were added to the correct **target** (TickerCodebase)



