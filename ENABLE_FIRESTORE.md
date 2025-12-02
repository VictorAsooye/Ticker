# Enable Firestore API

Your app needs the Firestore API enabled to work. Here's how to fix it:

## Quick Fix

1. **Open this link in your browser:**
   https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=ticker-54e2f

2. **Click "Enable"** button

3. **Wait 1-2 minutes** for the API to activate

4. **Run your app again** - the Firestore errors should be gone!

## Alternative: Enable via Firebase Console

1. Go to: https://console.firebase.google.com/project/ticker-54e2f/firestore
2. Click "Create database"
3. Choose "Start in test mode" (for now)
4. Select a location (us-central1 is fine)
5. Click "Enable"

This will automatically enable the Firestore API.

---

**Note:** After enabling, wait 1-2 minutes for changes to propagate, then try running your app again.

