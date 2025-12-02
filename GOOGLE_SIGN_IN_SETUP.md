# Google Sign In Setup Guide

## ✅ Code Implementation Complete

I've implemented Google Sign In in your app. Now you need to:
1. Add Google Sign In SDK package
2. Enable it in Firebase Console

## Step 1: Add Google Sign In SDK (2 minutes)

### In Xcode:

1. **File** → **Add Package Dependencies...**
2. Enter this URL: `https://github.com/google/GoogleSignIn-iOS`
3. Click **Add Package**
4. Select **GoogleSignIn** product
5. Click **Add Package**

**Alternative:** If the above doesn't work, use:
- URL: `https://github.com/google/GoogleSignIn-iOS.git`
- Version: Latest (7.0.0 or newer)

## Step 2: Enable Google Sign In in Firebase (2 minutes)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your **"Ticker"** project
3. Go to **Authentication** → **Sign-in method**
4. Click on **"Google"**
5. Toggle **"Enable"**
6. Enter your **Support email** (your email)
7. Click **"Save"**

**That's it!** No OAuth client ID needed - Firebase handles it automatically.

## Step 3: Test

1. **Clean**: `Shift + Cmd + K`
2. **Build**: `Cmd + B`
3. **Run**: `Cmd + R`
4. Click **"Continue with Google"** button
5. Sign in with your Google account!

---

## 🎨 What I Added

- ✅ Google Sign In button (blue, matches Google's design)
- ✅ Firebase Google authentication
- ✅ User document creation/update
- ✅ Error handling
- ✅ URL scheme handling in AppDelegate

---

## 🆘 Troubleshooting

### "No such module 'GoogleSignIn'"
- Make sure you added the Google Sign In package (Step 1)
- Clean build folder: `Shift + Cmd + K`
- Rebuild: `Cmd + B`

### "Google Sign In configuration error"
- Make sure Google Sign In is enabled in Firebase Console
- Make sure `GoogleService-Info.plist` is in your project

### Button doesn't work
- Check that Google Sign In is enabled in Firebase
- Check Xcode console for error messages
- Make sure you're testing on a real device or simulator with internet

---

## ✅ Expected Behavior

1. User clicks **"Continue with Google"**
2. Google Sign In popup appears
3. User selects Google account
4. User is signed in
5. App navigates to onboarding/home screen

---

## 📝 Notes

- Google Sign In works on both simulator and real device
- No additional configuration needed in Xcode (unlike Apple Sign In)
- Firebase automatically handles OAuth client ID from `GoogleService-Info.plist`

The Google Sign In button should appear above the Apple Sign In button in your authentication screen! 🎉

