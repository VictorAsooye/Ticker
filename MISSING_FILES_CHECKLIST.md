# ✅ Missing Files Checklist

## 🔍 How to Check in Xcode:

1. Click **"TARGET: TickerCodebase"** (left sidebar)
2. Go to **"Build Phases"** tab  
3. Expand **"Compile Sources"**
4. Check if these files are in the list (with ✅ checkboxes)

---

## 📋 Files to Verify (Based on Errors):

### **Critical - Causing Current Errors:**
- [ ] `Utilities/HapticManager.swift` ← **"Cannot find 'HapticManager'" error**
- [ ] `ViewModels/PurchaseManager.swift` ← **"Cannot find 'PurchaseManager'" error**
- [ ] `ViewModels/CloudFunctionsService.swift`
- [ ] `Utilities/UndoManager.swift`

### **Components:**
- [ ] `Views/Components/UndoBannerView.swift`
- [ ] `Views/Components/LoadingCardView.swift`

### **Legal & Settings:**
- [ ] `Views/Legal/LegalView.swift`
- [ ] `Views/Legal/DisclaimerPopupView.swift`
- [ ] `Views/Settings/SettingsView.swift`

### **Onboarding:**
- [ ] `Views/Onboarding/NotificationPermissionView.swift`

---

## ✅ How to Add Missing Files:

### **Quick Method:**
1. In Xcode, right-click the folder (e.g., `Utilities/`)
2. **"Add Files to TickerCodebase..."**
3. Select the file
4. **IMPORTANT**: 
   - ✅ Uncheck **"Copy items if needed"** (file already exists)
   - ✅ Check **"Add to targets: TickerCodebase"**
5. Click **"Add"**

### **Alternative Method:**
1. **TARGET: TickerCodebase** → **Build Phases** → **Compile Sources**
2. Click **"+"** button
3. Find and select the file
4. Click **"Add"**

---

## 🎯 After Adding Files:

1. **Clean Build Folder**: Shift+Cmd+K
2. **Build**: Cmd+B
3. Errors should be resolved!

---

## 📝 All Files That Should Exist:

I found **42 Swift files** in your directory. Here's the complete list:

### Core:
- ✅ TickerApp.swift

### Models (4):
- ✅ Investment.swift
- ✅ UserProfile.swift
- ✅ Notification.swift
- ✅ FirestoreModels.swift

### ViewModels (7):
- ✅ HomeViewModel.swift
- ✅ OpenAIService.swift
- ✅ StorageManager.swift
- ✅ FirebaseManager.swift
- ✅ AuthViewModel.swift
- ✅ CloudFunctionsService.swift
- ✅ PurchaseManager.swift

### Utilities (7):
- ✅ Constants.swift
- ✅ Extensions.swift
- ✅ HapticManager.swift
- ✅ NotificationManager.swift
- ✅ UndoManager.swift
- ✅ DeviceHelper.swift
- ✅ AnalyticsHelper.swift

### Views (23):
- ✅ Onboarding (5 files)
- ✅ Authentication (1 file)
- ✅ Home (4 files)
- ✅ Components (5 files)
- ✅ Paywall (1 file)
- ✅ SavedInterests (1 file)
- ✅ Legal (2 files)
- ✅ Settings (1 file)

---

**If a file is missing from "Compile Sources", add it using the steps above!**


