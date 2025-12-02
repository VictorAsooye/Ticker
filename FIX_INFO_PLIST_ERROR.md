# 🔧 Fix: "Multiple commands produce Info.plist" Error

## The Error
**"Multiple commands produce '/Users/.../TickerCodebase.app/Info.plist'"**

This happens when Xcode tries to generate Info.plist automatically AND you also have an Info.plist file in your project.

---

## ✅ FIX (Choose One Method):

### **METHOD 1: Use Auto-Generated Info.plist (Recommended for iOS 14+)**

1. In Xcode, click **"TARGET: TickerCodebase"**
2. Go to **"Build Settings"** tab
3. Search for **"Info.plist File"** (or `INFOPLIST_FILE`)
4. **DELETE** the value (make it empty)
5. Search for **"Generate Info.plist File"** (or `GENERATE_INFOPLIST_FILE`)
6. Set it to **"Yes"**
7. Go to **"Info"** tab
7. Add any custom keys you need there (they'll be auto-generated)

**Then:**
- Delete or remove `Info.plist` from your project:
  - Right-click `Info.plist` in Project Navigator
  - **"Delete"** → Choose **"Remove Reference"** (don't move to trash)

---

### **METHOD 2: Use Your Existing Info.plist File**

1. In Xcode, click **"TARGET: TickerCodebase"**
2. Go to **"Build Settings"** tab
3. Search for **"Generate Info.plist File"** (or `GENERATE_INFOPLIST_FILE`)
4. Set it to **"No"**
5. Search for **"Info.plist File"** (or `INFOPLIST_FILE`)
6. Make sure it points to: **`Info.plist`** (or `$(SRCROOT)/Info.plist`)

**Then:**
- Make sure `Info.plist` is in your project:
  - If it's missing, add it: Right-click project → **"Add Files to TickerCodebase"** → Select `Info.plist`

---

## 🎯 Quick Fix (Most Common Solution):

### **Step 1: Remove Info.plist from Build Phases**

1. Click **"TARGET: TickerCodebase"**
2. Go to **"Build Phases"** tab
3. Expand **"Copy Bundle Resources"**
4. Find **"Info.plist"** in the list
5. If it's there, select it and click **"-"** to remove it
6. **Info.plist should NOT be in "Copy Bundle Resources"**

### **Step 2: Configure Build Settings**

1. Go to **"Build Settings"** tab
2. Search for **"Generate Info.plist File"**
3. Set to **"Yes"** (for auto-generation)
4. Search for **"Info.plist File"**
5. **Clear/Delete** the value (leave it empty)

### **Step 3: Clean and Build**

1. **Product** → **Clean Build Folder** (Shift+Cmd+K)
2. **Product** → **Build** (Cmd+B)

---

## 📝 Alternative: If You Need Custom Info.plist

If you have custom keys in Info.plist that you need to keep:

1. **"TARGET: TickerCodebase"** → **"Info"** tab
2. Add your custom keys here (like `NSUserNotificationsUsageDescription`, etc.)
3. Use **METHOD 1** above (auto-generate)
4. The custom keys from the "Info" tab will be included automatically

---

## ✅ Verification

After fixing:
- Build should succeed
- No "Multiple commands" error
- App should run

---

## 🔍 Why This Happens

Modern Xcode (iOS 14+) can auto-generate Info.plist. If you have both:
- An `Info.plist` file in your project
- Auto-generation enabled

Xcode tries to create it twice, causing the conflict.

**Solution:** Use one or the other, not both!


