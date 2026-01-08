# Frontend Testing Guide - Railway Backend Connection

## ✅ Connection Status

Your Flutter frontend is now configured to connect to:
**https://worker-management-production.up.railway.app**

---

## 📋 Pre-Testing Checklist

### 1. Backend Requirements (Railway)
Your backend has a **Firestore configuration issue**. Before testing the app, ensure:

- [ ] Firebase credentials are properly set in Railway environment variables
- [ ] `FIREBASE_PROJECT_ID` is set
- [ ] `FIREBASE_CLIENT_EMAIL` is set
- [ ] `FIREBASE_PRIVATE_KEY` is set (with proper formatting)
- [ ] Firestore is initialized correctly in your backend

**Error detected:** `getFirestore is not a function`

### 2. Check Railway Environment Variables

1. Go to Railway dashboard: https://railway.app
2. Select your project: worker-management-production
3. Go to **Variables** tab
4. Verify Firebase credentials are present

---

## 🧪 Testing Steps

### Step 1: Test Backend Health
```bash
cd "/Users/mannerishivardhan/Desktop/codex/security sves/frontend"
dart run lib/utils/test_connection.dart
```

**Expected Result:** Health check should pass ✅

---

### Step 2: Test on Android Emulator

1. **Start Android Emulator:**
```bash
flutter emulators --launch <emulator-id>
```

2. **Run the app:**
```bash
flutter run
```

3. **Test Login Flow:**
   - Open the app
   - Try to login with test credentials
   - Check console for API responses

---

### Step 3: Test on iOS Simulator (macOS only)

1. **Start iOS Simulator:**
```bash
open -a Simulator
```

2. **Run the app:**
```bash
flutter run -d ios
```

---

### Step 4: Test on Physical Device

1. **Connect your device via USB**

2. **Enable developer mode on device**

3. **Run:**
```bash
flutter devices  # Check device is detected
flutter run -d <device-id>
```

---

## 🔍 Debugging Network Issues

### Check API Responses

When testing, monitor the console for:
- ✅ 200 responses = Success
- ⚠️ 401 responses = Authentication failed (expected for invalid credentials)
- ❌ 500 responses = Backend error (Firestore issue currently)
- ❌ Network errors = Connection timeout or URL issue

### Common Issues & Solutions

#### Issue 1: "Connection Refused"
**Solution:** 
- Verify Railway app is running
- Check https:// is used (not http://)

#### Issue 2: "SSL Handshake Failed"
**Solution:**
- Railway uses valid SSL certificates, this should not occur
- If it does, check device/emulator date/time settings

#### Issue 3: "Timeout"
**Solution:**
- Increase timeout in `api_config.dart` (currently 30 seconds)
- Check internet connection on device

---

## 📱 Test Cases

### 1. Authentication Tests

- [ ] **Login with valid credentials**
  - Expected: Should redirect to dashboard
  - Expected: JWT token stored securely

- [ ] **Login with invalid credentials**
  - Expected: Error message shown
  - Expected: Remains on login screen

- [ ] **Logout**
  - Expected: Token cleared
  - Expected: Redirect to login

### 2. Employee Management Tests

- [ ] **View all employees**
  - Expected: List of employees displayed

- [ ] **Create new employee**
  - Expected: Success message
  - Expected: Employee appears in list

- [ ] **Update employee**
  - Expected: Changes saved
  - Expected: Updated data shown

- [ ] **Delete employee**
  - Expected: Confirmation dialog
  - Expected: Employee removed from list

### 3. Department Management Tests

- [ ] **View all departments**
- [ ] **Create department**
- [ ] **Update department**
- [ ] **Delete department**

### 4. Attendance Tests

- [ ] **Mark attendance**
- [ ] **View attendance history**
- [ ] **Filter attendance by date**

---

## 🛠️ Quick Commands

### Check Flutter doctor
```bash
flutter doctor -v
```

### List available devices
```bash
flutter devices
```

### Run with specific device
```bash
flutter run -d <device-id>
```

### Run in debug mode with verbose logging
```bash
flutter run -v
```

### Build release APK for testing
```bash
flutter build apk --release
```

### Clean and rebuild
```bash
flutter clean
flutter pub get
flutter run
```

---

## 🐛 Current Backend Issue

**Problem:** Firestore initialization error
**Impact:** Login and all API calls requiring database will fail
**Fix Required:** On Railway backend, not frontend

**To fix on Railway:**
1. Ensure Firebase Admin SDK is properly initialized
2. Check environment variables are correctly set
3. Verify `firebase-admin` package is installed
4. Restart the Railway service after configuration

---

## 📊 Monitoring

### Railway Logs
Monitor your backend logs in real-time:
1. Go to Railway dashboard
2. Select your project
3. Click on **Deployments**
4. View **Logs** tab

### Flutter Console
Watch for network requests in Flutter console:
- Look for `DioError` messages
- Check response status codes
- Review error messages

---

## 🎯 Next Steps

1. ⚠️ **FIRST:** Fix Firestore configuration on Railway backend
2. ✅ Test connection again: `dart run lib/utils/test_connection.dart`
3. ✅ Run app: `flutter run`
4. ✅ Test all features systematically
5. ✅ Report any issues for debugging

---

## 📞 Support

If you encounter issues:
1. Check Railway logs for backend errors
2. Check Flutter console for frontend errors
3. Verify network connectivity
4. Ensure all environment variables are set correctly

---

**Configuration Files Updated:**
- ✅ `lib/core/config/api_config.dart` - Centralized API configuration
- ✅ `lib/services/auth_service.dart` - Auth API calls
- ✅ `lib/services/employee_service.dart` - Employee API calls
- ✅ `lib/services/department_service.dart` - Department API calls
- ✅ `lib/services/attendance_service.dart` - Attendance API calls
- ✅ `android/app/src/main/AndroidManifest.xml` - Internet permission added

**Test Utilities Created:**
- ✅ `lib/utils/test_connection.dart` - Connection testing script
