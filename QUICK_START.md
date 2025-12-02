# ⚡ Quick Start - Get Your App Running in 15 Minutes

## The Problem
Your app shows a **black screen and crashes** because Firebase isn't configured.

## The Solution (3 Steps)

### ✅ Step 1: Get GoogleService-Info.plist (10 minutes)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. **Create project** → Name: "Ticker"
3. **Add iOS app** → Bundle ID: `Ticker.TickerCodebase`
4. **Download** `GoogleService-Info.plist`
5. **Add to Xcode**: Right-click project → "Add Files" → Select plist → ✅ "Copy items" → ✅ "Add to targets"

### ✅ Step 2: Enable Firebase Services (3 minutes)

**In Firebase Console:**

1. **Authentication** → Get Started → **Sign-in method** → Enable **Email/Password**
2. **Firestore Database** → Create database → **Start in test mode** → Choose location → Enable

### ✅ Step 3: Run the App (2 minutes)

1. **Clean**: `Shift + Cmd + K`
2. **Build**: `Cmd + B`  
3. **Run**: `Cmd + R`

**You should now see the login screen!** 🎉

---

## What I Just Fixed For You

✅ **Complete Authentication UI** - Full login/signup screen with:
- Email/password fields
- Password visibility toggle
- Form validation
- Error messages
- Apple Sign In button (placeholder for now)
- Beautiful design matching your app

---

## What You'll See After Setup

1. **Login Screen** - Email/password authentication
2. **Sign Up** - Create new account
3. **Onboarding** - Investment preferences setup
4. **Home Screen** - Swipe cards with investment recommendations

---

## Next Steps After It's Running

1. **Test the flow**: Sign up → Onboarding → Swipe cards
2. **Add app icon** (see `ADD_ASSETS_TO_XCODE.md`)
3. **Test on your phone** (connect via USB)
4. **Review all screens** for any issues

---

## 🆘 Still Having Issues?

**If you still see a black screen:**

1. Check Xcode console (bottom panel) for error messages
2. Verify `GoogleService-Info.plist` is in the project
3. Verify it's added to the TickerCodebase target
4. Clean Derived Data: Xcode → Preferences → Locations → Derived Data → Delete TickerCodebase folder

**Tell me what error you see and I'll fix it immediately!**

---

## 🚀 Ready to Launch?

Once the app is running:
- Test all features
- Fix any bugs
- Add app icon
- Submit to App Store!

**You're almost there!** 🎯

