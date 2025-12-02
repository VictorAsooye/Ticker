# Firebase Package Setup Guide

## Quick Fix: Add Firebase SDK Packages

The error "No such module 'FirebaseCore'" means the Firebase SDK packages haven't been added to your Xcode project yet.

### Step-by-Step Instructions:

1. **Open Xcode Project**
   - Open `TickerCodebase.xcodeproj` in Xcode

2. **Add Package Dependencies**
   - In Xcode, go to: **File → Add Package Dependencies...**
   - Or click on your project in the navigator, select the project (not target), go to **Package Dependencies** tab

3. **Add Firebase iOS SDK**
   - In the search bar, paste: `https://github.com/firebase/firebase-ios-sdk`
   - Click **Add Package**
   - Select version: **Up to Next Major Version** with `11.0.0` or latest
   - Click **Add Package**

4. **Select Required Products**
   You need to add these Firebase products:
   - ✅ **FirebaseCore**
   - ✅ **FirebaseAuth**
   - ✅ **FirebaseFirestore**
   - ✅ **FirebaseFunctions**
   - ✅ **FirebaseAnalytics**
   
   Make sure all 5 are checked, then click **Add Package**

5. **Wait for Package Resolution**
   - Xcode will download and resolve the packages (this may take a minute)

6. **Verify Installation**
   - In the Project Navigator, you should see a new "Package Dependencies" section
   - Expand it to see "firebase-ios-sdk"
   - Clean build folder: **Product → Clean Build Folder** (Shift+Cmd+K)
   - Build again: **Product → Build** (Cmd+B)

### Alternative: Using Terminal (if Xcode UI doesn't work)

If you prefer command line, you can add the package URL directly:

1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter: `https://github.com/firebase/firebase-ios-sdk`
3. Follow steps 3-6 above

### 7. Add RevenueCat Package (Also Required)

Your project also uses RevenueCat for in-app purchases:

1. **Add RevenueCat Package**
   - Go to: **File → Add Package Dependencies...**
   - Enter: `https://github.com/RevenueCat/purchases-ios`
   - Click **Add Package**
   - Select version: **Up to Next Major Version** with `5.0.0` or latest
   - Click **Add Package**

2. **Select Product**
   - ✅ **RevenueCat** (only one product needed)
   - Click **Add Package**

### Required Packages Summary:

Your project needs these packages:

**Firebase SDK:**
- `FirebaseCore` - Core Firebase functionality
- `FirebaseAuth` - Authentication
- `FirebaseFirestore` - Database
- `FirebaseFunctions` - Cloud Functions
- `FirebaseAnalytics` - Analytics

**RevenueCat:**
- `RevenueCat` - In-app purchase management

### After Adding All Packages:

1. **Clean Build Folder**: Shift+Cmd+K
2. **Build Project**: Cmd+B
3. The "No such module 'FirebaseCore'" error should be resolved
4. If you see "No such module 'RevenueCat'", make sure you added the RevenueCat package too

### If You Still Get Errors:

1. Make sure you've added the package to the correct **target** (TickerApp)
2. Check that all 5 products are selected in Package Dependencies
3. Try restarting Xcode
4. Delete Derived Data:
   - Xcode → Settings → Locations
   - Click arrow next to Derived Data path
   - Delete the folder for your project
   - Rebuild

---

**Note**: You'll also need to add the `GoogleService-Info.plist` file to your project after setting up Firebase in the Firebase Console. See `FIREBASE_SETUP.md` for details.

