# Add GoogleService-Info.plist to Xcode

## Step-by-Step Instructions

### Step 1: Open Xcode
Make sure your TickerCodebase project is open in Xcode.

### Step 2: Find the Downloaded File
The file should be in your **Downloads** folder:
- File name: `GoogleService-Info.plist`
- Location: `~/Downloads/GoogleService-Info.plist`

### Step 3: Add to Xcode Project

1. **In Xcode Project Navigator** (left sidebar), right-click on **"TickerCodebase"** (the blue project icon at the very top)
   
2. Select **"Add Files to TickerCodebase..."**

3. **Navigate to Downloads folder** and select `GoogleService-Info.plist`

4. **IMPORTANT - Check these options:**
   - ✅ **"Copy items if needed"** (CHECKED)
   - ✅ **"Add to targets: TickerCodebase"** (CHECKED - make sure this is selected!)
   - ❌ **"Create groups"** (NOT "Create folder references")

5. Click **"Add"**

### Step 4: Verify It's Added

After adding, you should see `GoogleService-Info.plist` in your Project Navigator at the root level, like this:

```
TickerCodebase (blue project icon)
  ├── GoogleService-Info.plist  ← Should appear here
  ├── TickerApp.swift
  ├── Models/
  ├── ViewModels/
  └── ...
```

### Step 5: Verify Target Membership

1. Click on `GoogleService-Info.plist` in Project Navigator
2. In the right sidebar (File Inspector), check **"Target Membership"**
3. Make sure **"TickerCodebase"** is checked ✅

### Step 6: Clean and Rebuild

1. **Clean Build Folder**: `Shift + Cmd + K`
2. **Build**: `Cmd + B`
3. **Run**: `Cmd + R`

---

## ✅ Success!

If everything worked, the app should:
- ✅ Launch without crashing
- ✅ Show the **login screen** instead of a black screen
- ✅ No Firebase errors in console

---

## 🆘 Troubleshooting

**If you don't see the file in Project Navigator:**
- Make sure you added it to the **blue project icon** (TickerCodebase), not a folder
- Check that "Copy items if needed" was checked

**If app still crashes:**
- Check Xcode console (bottom panel) for error messages
- Verify Target Membership is checked
- Try cleaning Derived Data: Xcode → Preferences → Locations → Derived Data → Delete TickerCodebase folder

