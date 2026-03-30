# Aadhaar Verification Flow - Knowledge Transfer Documentation

**Package:** Sysmo Verification  
**Author:** Gayathri  
**Date:** March 30, 2026  
**KT Prepared For:** Team Member Onboarding

---

## 📋 Table of Contents
1. [Overview](#overview)
2. [Architecture & Components](#architecture--components)
3. [Complete Flow Diagram](#complete-flow-diagram)
4. [Step-by-Step Implementation](#step-by-step-implementation)
5. [Code Walkthrough](#code-walkthrough)
6. [API Integration Points](#api-integration-points)
7. [UI Components](#ui-components)
8. [Security Features](#security-features)
9. [Testing Scenarios](#testing-scenarios)
10. [Common Issues & Solutions](#common-issues--solutions)

---

## 🎯 Overview

### What is Aadhaar Verification?
Aadhaar verification is a **multi-step KYC process** that validates a user's Aadhaar number through:
- **OTP-based authentication** (Primary focus)
- **Biometric authentication** (Alternative)

### Why is this flow complex?
Unlike simple verifications (PAN, Voter ID), Aadhaar requires:
1. **User Consent** (UIDAI regulation)
2. **OTP Generation & Validation**
3. **Vault Lookup/Registration** (Reference number management)
4. **Transaction ID tracking** (OTP invalidation)
5. **Multiple API calls** in sequence

---

## 🏗️ Architecture & Components

### Key Files & Their Responsibilities

```
lib/src/
├── core/
│   ├── enums_and_state.dart                    # VerificationType.aadhaar enum
│   ├── verification_handlers.dart              # AadhaarVerificationHandler
│   └── api/
│       └── api_client.dart                     # Dio HTTP client
│ 
└── widget/
    ├── uiwidgetprops/
    │   ├── kyc_verification_widget.dart        # Main KYC input widget (Entry point)
    │   ├── consent_form.dart                   # Aadhaar consent screen
    │   └── otp_sheet.dart                      # OTP input bottom sheet
    └── kyc_verification.dart                   # VerificationMixin
```

### Component Interactions

```
┌──────────────────────────────────────────────────────────┐
│ KYCTextBox (kyc_verification_widget.dart)               │
│ - User enters Aadhaar number                            │
│ - Clicks "Verify" button                                │
└────────────────┬─────────────────────────────────────────┘
                 │
                 │ _verifyAadhaar()
                 ▼
┌──────────────────────────────────────────────────────────┐
│ Method Selection Dialog                                  │
│ - "OTP Based" or "Biometric"                            │
└────────────────┬─────────────────────────────────────────┘
                 │
                 │ User selects "OTP"
                 ▼
┌──────────────────────────────────────────────────────────┐
│ ConsentForm (consent_form.dart)                         │
│ - Show UIDAI terms & conditions                         │
│ - User accepts consent                                   │
│ - Generate OTP (API Call #1)                            │
└────────────────┬─────────────────────────────────────────┘
                 │
                 │ OTP Generated → transactionId created
                 ▼
┌──────────────────────────────────────────────────────────┐
│ OtpSheet (otp_sheet.dart)                               │
│ - User enters 6-digit OTP                               │
│ - 60-second countdown timer                             │
│ - Validate OTP (API Call #2)                            │
└────────────────┬─────────────────────────────────────────┘
                 │
                 │ OTP valid → check vault
                 ▼
┌──────────────────────────────────────────────────────────┐
│ Vault Operations (Inside OtpSheet/ConsentForm)          │
│ Step 1: Vault Lookup (API Call #3)                      │
│   - Check if aadharRefNum exists                        │
│   - ErrorCode 000 → RefNum found ✓                      │
│   - ErrorCode 2 → Go to Step 2                          │
│                                                           │
│ Step 2: Vault Registration (API Call #4)                │
│   - Register Aadhaar in vault                           │
│   - Get new aadharRefNum                                │
└────────────────┬─────────────────────────────────────────┘
                 │
                 │ Return Response with aadharRefNum
                 ▼
┌──────────────────────────────────────────────────────────┐
│ Success Handler (kyc_verification_widget.dart)          │
│ - Display success message                                │
│ - Call onSuccess callback with full data                │
│ - Button state → "verified" ✓                           │
└──────────────────────────────────────────────────────────┘
```

---

## 🔄 Complete Flow Diagram

### OTP-Based Aadhaar Verification Flow

```
START: User enters 12-digit Aadhaar number
  │
  ├─→ [Input Validation]
  │     - Pattern: ^\d{12}$
  │     - Not empty check
  │
  ├─→ [User clicks "Verify" button]
  │
  └─→ _verifyAadhaar() called
        │
        ├─→ Show Method Selection Dialog
        │     Options:
        │     1. "OTP Based Verification"
        │     2. "Biometric Verification"
        │
        ├─→ User selects "OTP Based"
        │
        └─→ Navigate to ConsentForm
              │
              ├─→ [CONSENT FORM SCREEN]
              │     Components:
              │     - Terms & Conditions display
              │     - Checkbox: "I accept T&C"
              │     - Button: "Proceed with OTP"
              │
              ├─→ User checks consent ✓
              │
              ├─→ User clicks "Proceed with OTP"
              │
              └─→ _handleOtpVerification() in ConsentForm
                    │
                    ├─→ [API CALL #1: Generate OTP]
                    │     Endpoint: otpGendraassetApiurl
                    │     Request Body:
                    │     {
                    │       "aadharNumber": "XXXXXXXXXXXX",
                    │       "uniqueId": "leadId",
                    │       "token": "token"
                    │     }
                    │     Response:
                    │     {
                    │       "OtpGeneration": {
                    │         "ErrorCode": "000",
                    │         "transactionId": "TXN123456",
                    │         "ErrorStatus": "OTP sent successfully"
                    │       }
                    │     }
                    │
                    ├─→ Extract transactionId (CRITICAL!)
                    │     - This ID validates the OTP
                    │     - Stored in currentTransactionId
                    │
                    └─→ Open OtpSheet bottom sheet
                          │
                          ├─→ [OTP SHEET BOTTOM SHEET]
                          │     Components:
                          │     - 6 OTP input boxes
                          │     - 60-second countdown timer
                          │     - "Resend OTP" button
                          │     - "Verify" button
                          │
                          ├─→ Start 60-second expiry timer
                          │
                          ├─→ [USER ACTIONS]
                          │     Option A: User enters OTP → Go to VERIFY OTP
                          │     Option B: Times out → Show expiry alert
                          │     Option C: User clicks "Resend OTP" → Go to RESEND
                          │
                          ├─→ [RESEND OTP FLOW]
                          │     _handleResendOtp() called
                          │     │
                          │     ├─→ [API CALL: Regenerate OTP]
                          │     │     Same as API #1
                          │     │     Returns NEW transactionId
                          │     │
                          │     ├─→ Update currentTransactionId
                          │     │     OLD OTP IS NOW INVALID ❌
                          │     │     ONLY NEW OTP WILL WORK ✓
                          │     │
                          │     ├─→ Reset 60-second timer
                          │     └─→ Clear OTP input fields
                          │
                          └─→ [VERIFY OTP FLOW]
                                _handleOtpVerification() called
                                │
                                ├─→ Validation Checks:
                                │     - OTP length == 6 digits?
                                │     - Timer not expired?
                                │
                                ├─→ [API CALL #2: Validate OTP]
                                │     Endpoint: aadhaarResponseApiurl
                                │     Request Body:
                                │     {
                                │       "otp": "123456",
                                │       "uid": "XXXXXXXXXXXX",
                                │       "uniqueId": "leadId",
                                │       "token": "token",
                                │       "transactionId": "TXN123456" ← MUST MATCH!
                                │     }
                                │     Response:
                                │     {
                                │       "otpValidationNew": {
                                │         "ErrorCode": "000",
                                │         "Status": "Y",
                                │         "TransactionId": "TXN123456",
                                │         "KycDetails": {
                                │           "name": "John Doe",
                                │           "dob": "01-01-1990",
                                │           "gender": "M"
                                │         }
                                │       }
                                │     }
                                │
                                ├─→ Check ErrorCode == "000" && Status == "Y"
                                │
                                ├─→ Check if aadharRefNum in response
                                │     - If YES → Return immediately ✓
                                │     - If NO → Continue to VAULT operations
                                │
                                └─→ [VAULT OPERATIONS]
                                      │
                                      ├─→ [API CALL #3: Vault Lookup]
                                      │     Endpoint: aadharvaultlookupapiurl
                                      │     Purpose: Check if refNum exists
                                      │     Request Body:
                                      │     {
                                      │       "aadharNumber": "XXXXXXXXXXXX",
                                      │       "uniqueId": "leadId",
                                      │       "token": "token"
                                      │     }
                                      │     Response Scenarios:
                                      │     
                                      │     Scenario A: RefNum exists
                                      │     {
                                      │       "VaultLoolUp": {
                                      │         "errorCode": "000",
                                      │         "aadharRefNum": "REF789"
                                      │       }
                                      │     }
                                      │     → Use this refNum ✓
                                      │     
                                      │     Scenario B: RefNum doesn't exist
                                      │     {
                                      │       "VaultLoolUp": {
                                      │         "errorCode": "2"
                                      │       }
                                      │     }
                                      │     → Go to Vault Registration
                                      │
                                      └─→ [API CALL #4: Vault Registration]
                                            (Only if errorCode == 2)
                                            Endpoint: aadharvaultApiurl
                                            Purpose: Create new refNum
                                            Request Body:
                                            {
                                              "aadharNumber": "XXXXXXXXXXXX",
                                              "uniqueId": "leadId",
                                              "token": "token"
                                            }
                                            Response:
                                            {
                                              "AadharValut": {
                                                "errorCode": "000",
                                                "aadharRefNum": "REF999"
                                              }
                                            }
                                            → Use this NEW refNum ✓

FINAL STEP: Return to KYCTextBox
  │
  ├─→ Response object contains:
  │     {
  │       "otpValidationNew": { ... KYC details ... },
  │       "aadharRefNum": "REF999",
  │       "vaultData": { ... vault data ... }
  │     }
  │
  ├─→ _handleVerificationSuccess() called
  │     - Button state → "verified" (green)
  │     - onSuccess callback with full data
  │     - Store aadhaarRefNumber for future use
  │
  └─→ END: Aadhaar Verified Successfully ✓
```

---

## 📝 Step-by-Step Implementation

### Step 1: Widget Setup (KYCTextBox)

**File:** `lib/src/widget/uiwidgetprops/kyc_verification_widget.dart`

The entry point for Aadhaar verification:

```dart
KYCTextBox(
  verificationType: VerificationType.aadhaar,  // Set Aadhaar type
  formProps: FormProps(
    label: 'Aadhaar Number',
    hintText: 'Enter 12-digit Aadhaar',
  ),
  styleProps: StyleProps(...),
  buttonProps: ButtonProps(label: 'Verify Aadhaar'),
  validationPattern: RegExp(r'^\d{12}$'),  // Must be 12 digits
  maskAadhaar: true,  // Optional: masks input (XXXX XXXX 3456)
  
  // API endpoints for different stages
  otpGendraassetApiurl: 'https://api.example.com/aadhar/otp/generate',
  aadhaarResponseApiurl: 'https://api.example.com/aadhar/otp/validate',
  aadharvaultlookupapiurl: 'https://api.example.com/aadhar/vault/lookup',
  aadharvaultApiurl: 'https://api.example.com/aadhar/vault/register',
  
  // Or offline mode with assets
  otpGendrateassetPath: 'assets/mock/otp_generate.json',
  aadhaarResponseassetspath: 'assets/mock/otp_validate.json',
  
  leadId: 'LEAD12345',
  token: 'AUTH_TOKEN',
  isOffline: false,
  
  onSuccess: (response) {
    // Extract verified data
    final vaultData = response.data['vaultData'];
    final refNum = response.data['aadharRefNum'];
    print('Aadhaar verified! RefNum: $refNum');
  },
  onError: (error) {
    print('Verification failed: $error');
  },
)
```

**Key Points:**
- `verificationType` must be `VerificationType.aadhaar`
- Multiple API URLs needed (4 different endpoints)
- `leadId` and `token` are passed through the entire flow

---

### Step 2: User Initiates Verification

**When:** User enters Aadhaar number and clicks "Verify" button

**Code Location:** `_handleVerification()` → `_verifyAadhaar()`

```dart
Future<void> _verifyAadhaar() async {
  // Show method selection dialog
  final methodType = await showValidateOptions(context);
  // Options: "OTP Based" or "Biometric"
  
  if (methodType == null) {
    // User cancelled
    _buttonStateManager.reset(widget.buttonProps.label);
    return;
  }
  
  // Navigate to consent form
  final consentResponse = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ConsentForm(
        aadhaarNumber: _currentInput,  // User's Aadhaar number
        aadhaarmethod: methodType,     // "OTP" or "Biometric"
        leadId: widget.leadId,
        token: widget.token,
        // ... other parameters
      ),
    ),
  );
  
  // Handle response after consent flow completes
  _processConsentResponse(consentResponse);
}
```

---

### Step 3: Consent Form & OTP Generation

**File:** `lib/src/widget/uiwidgetprops/consent_form.dart`

**UI Components:**
1. **Terms & Conditions text** - UIDAI mandated consent
2. **Checkbox** - User must accept
3. **Proceed button** - Disabled until checkbox checked

**Code Flow:**

```dart
// User accepts consent and clicks "Proceed with OTP"
Future<void> _handleOtpVerification() async {
  setState(() {
    isLoading = true;
  });

  // Prepare OTP generation request
  final requestBody = {
    'aadharNumber': widget.aadhaarNumber,
    'uniqueId': widget.leadId,
    'token': widget.token,
  };

  // API Call #1: Generate OTP
  final response = await KYCService().verify(
    isOffline: widget.isOffline,
    request: jsonEncode(requestBody),
    assetPath: widget.assetPath,
    url: widget.url,
  );

  final otpGeneration = response.data['OtpGeneration'];
  
  if (otpGeneration['ErrorCode'] == '000') {
    // Extract transaction ID (CRITICAL!)
    final transactionId = otpGeneration['transactionId'];
    
    // Open OTP input sheet
    final otpResponse = await showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (_) => OtpSheet(
        aadhaarNumber: widget.aadhaarNumber,
        leadId: widget.leadId,
        token: widget.token,
        initialTransactionId: transactionId,  // Pass transaction ID
        // ... other parameters
      ),
    );
    
    // Return OTP validation result to parent
    Navigator.pop(context, otpResponse);
  } else {
    // Show error
    _showErrorDialog(otpGeneration['ErrorStatus']);
  }
}
```

**Important:** 
- `transactionId` from OTP generation response MUST be saved
- This ID is used to validate the OTP in next step
- Each OTP generation creates a unique transaction ID

---

### Step 4: OTP Input & Validation

**File:** `lib/src/widget/uiwidgetprops/otp_sheet.dart`

**Features:**
- 6 OTP input boxes
- 60-second countdown timer
- Auto-expiry after 60 seconds
- Resend OTP functionality
- Transaction ID tracking

**Key Code Sections:**

#### 4.1 OTP Input State Management

```dart
class _OtpSheetState extends State<OtpSheet> {
  late String otpPin;  // Stores 6-digit OTP
  late ValueNotifier<int> resendTimer;  // 60-second countdown
  String? currentTransactionId;  // Current valid transaction ID
  Timer? _timer;
  Timer? _expiryTimer;
  
  @override
  void initState() {
    super.initState();
    currentTransactionId = widget.initialTransactionId;
    _startResendTimer();  // Start 60s countdown
    _startExpiryTimer();  // Auto-expire after 60s
  }
}
```

#### 4.2 OTP Validation

```dart
Future<void> _handleOtpVerification() async {
  // Validation checks
  if (resendTimer.value == 0) {
    _showExpiryAlert();
    return;
  }
  
  if (otpPin.length != 6) {
    _showError('Please enter a valid 6-digit OTP');
    return;
  }
  
  isLoading.value = true;

  // Prepare validation request
  final requestBody = {
    'otp': otpPin,
    'uid': widget.aadhaarNumber,
    'uniqueId': widget.leadId,
    'token': widget.token,
    'transactionId': currentTransactionId,  // ← MUST MATCH OTP generation
  };

  // API Call #2: Validate OTP
  final response = await KYCService().verify(
    isOffline: widget.isOffline,
    request: jsonEncode(requestBody),
    assetPath: widget.assetPath,
    url: widget.url,
  );

  final otpValidation = response.data['otpValidationNew'];
  
  if (otpValidation['ErrorCode'] == '000' && 
      otpValidation['Status'] == 'Y') {
    // OTP is valid! ✓
    await _performVaultOperations(otpValidation, response);
  } else {
    _showError('Invalid OTP');
  }
}
```

#### 4.3 OTP Resend Flow

```dart
Future<void> _handleResendOtp() async {
  if (isResending.value) return;
  
  isResending.value = true;

  final requestBody = {
    'aadharNumber': widget.aadhaarNumber,
    'uniqueId': widget.leadId,
    'token': widget.token,
  };

  // Generate NEW OTP
  final response = await KYCService().verify(
    isOffline: widget.isOffline,
    request: jsonEncode(requestBody),
    assetPath: widget.otpGenerateAssetPath,
    url: widget.otpGenerateApiUrl,
  );

  final otpGeneration = response.data['OtpGeneration'];
  
  if (otpGeneration['ErrorCode'] == '000') {
    // Update to NEW transaction ID
    currentTransactionId = otpGeneration['transactionId'];
    
    debugPrint("New TransactionId: $currentTransactionId");
    debugPrint("Previous OTP is now INVALID ❌");
    
    // Reset timers
    _startResendTimer();
    _startExpiryTimer();
    _resetOtpField();
    
    _showSuccessDialog('OTP sent successfully');
  }
}
```

**Critical OTP Invalidation Logic:**
```dart
/*
  OTP INVALIDATION MECHANISM:
  
  1. First OTP generation → transactionId = "TXN001"
     currentTransactionId = "TXN001"
     
  2. User clicks "Resend OTP" → transactionId = "TXN002"
     currentTransactionId = "TXN002"  (updated)
     
  3. Backend validates OTP against transactionId
     - If user enters OTP from TXN001 → FAILS ❌
     - Only OTP from TXN002 will work ✓
     
  This ensures old OTPs cannot be used after resend!
*/
```

---

### Step 5: Vault Operations

**Purpose:** Retrieve or register Aadhaar reference number for future lookups

**Location:** Inside `otp_sheet.dart` after successful OTP validation

#### 5.1 Vault Lookup

```dart
// Check if reference number already exists
final vaultLookupRequest = {
  'aadharNumber': widget.aadhaarNumber,
  'uniqueId': widget.leadId,
  'token': widget.token,
};

// API Call #3: Vault Lookup
final vaultLookupResponse = await KYCService().verify(
  isOffline: widget.isOffline,
  request: jsonEncode(vaultLookupRequest),
  assetPath: widget.aadharvaultlookupassetpath,
  url: widget.aadharvaultlookupapiurl,
);

final vaultLookup = vaultLookupResponse.data['VaultLoolUp'];
final errorCode = vaultLookup['errorCode'];
final refNum = vaultLookup['aadharRefNum'];

if (errorCode == '000' && refNum != null) {
  // Reference number found! ✓
  debugPrint("RefNum found: $refNum");
  return _returnSuccessWithRefNum(refNum, vaultLookup);
}

if (errorCode == '2') {
  // Reference number doesn't exist → Register new one
  await _performVaultRegistration();
}
```

#### 5.2 Vault Registration

```dart
// Register new reference number
final vaultRequest = {
  'aadharNumber': widget.aadhaarNumber,
  'uniqueId': widget.leadId,
  'token': widget.token,
};

// API Call #4: Vault Registration
final vaultResponse = await KYCService().verify(
  isOffline: widget.isOffline,
  request: jsonEncode(vaultRequest),
  assetPath: widget.aadharvaultassetpath,
  url: widget.aadharvaultApiurl,
);

final aadharVault = vaultResponse.data['AadharValut'];
final vaultErrorCode = aadharVault['errorCode'];
final vaultRefNum = aadharVault['aadharRefNum'];

if (vaultErrorCode == '000' && vaultRefNum != null) {
  // NEW reference number created! ✓
  debugPrint("New RefNum registered: $vaultRefNum");
  return _returnSuccessWithRefNum(vaultRefNum, aadharVault);
} else {
  _showError('Vault registration failed');
}
```

#### 5.3 Return Final Response

```dart
Future<void> _returnSuccessWithRefNum(
  String refNum,
  Map<String, dynamic> vaultData,
) async {
  // Merge OTP validation data + vault data + refNum
  final finalData = Map<String, dynamic>.from(response.data);
  finalData['aadharRefNum'] = refNum;
  finalData['vaultData'] = vaultData;
  
  final finalResponse = Response(
    requestOptions: response.requestOptions,
    data: finalData,
    statusCode: 200,
  );
  
  isLoading.value = false;
  
  // Show success dialog
  await showDialog(
    context: context,
    builder: (dialogContext) => SysmoAlert.success(
      message: "OTP verified successfully",
      onButtonPressed: () {
        Navigator.pop(dialogContext);
      },
    ),
  );
  
  // Return to parent with complete data
  if (mounted) {
    Navigator.pop(context, finalResponse);
  }
}
```

---

### Step 6: Handle Success in KYCTextBox

**File:** `lib/src/widget/uiwidgetprops/kyc_verification_widget.dart`

```dart
// After ConsentForm returns with response
if (consentResponse != null && consentResponse.data != null) {
  final responseData = consentResponse.data;
  
  // Check if this is biometric response
  if (responseData['type'] == 'Biometric') {
    _handleVerificationSuccess(
      'Aadhaar verified successfully',
      consentResponse,
      showSuccessDialog: false,
    );
    return;
  }
  
  // OTP scenario
  final otpValidation = responseData['otpValidationNew'];
  
  if (otpValidation['ErrorCode'] == '000' && 
      otpValidation['Status'] == 'Y') {
    
    // Extract reference number
    aadhaarRefNumber = responseData['aadharRefNum'];
    
    // Update button state to "verified"
    _buttonStateManager.setSuccess('verified');
    
    // Call onSuccess callback with complete data
    widget.onSuccess(consentResponse);
    
    // Mark verification as completed
    _verificationCompleted = true;
  }
}
```

---

## 🔌 API Integration Points

### API Summary Table

| API Call | Purpose | Endpoint Variable | Request Body | Success Response |
|----------|---------|------------------|--------------|------------------|
| **#1 Generate OTP** | Create OTP & transaction ID | `otpGendraassetApiurl` | `{aadharNumber, uniqueId, token}` | `{OtpGeneration: {ErrorCode: "000", transactionId: "TXN123"}}` |
| **#2 Validate OTP** | Verify user-entered OTP | `aadhaarResponseApiurl` | `{otp, uid, uniqueId, token, transactionId}` | `{otpValidationNew: {ErrorCode: "000", Status: "Y", KycDetails: {...}}}` |
| **#3 Vault Lookup** | Check if refNum exists | `aadharvaultlookupapiurl` | `{aadharNumber, uniqueId, token}` | `{VaultLoolUp: {errorCode: "000", aadharRefNum: "REF789"}}` |
| **#4 Vault Register** | Create new refNum | `aadharvaultApiurl` | `{aadharNumber, uniqueId, token}` | `{AadharValut: {errorCode: "000", aadharRefNum: "REF999"}}` |

### Request/Response Examples

#### 1. Generate OTP Request
```json
POST /aadhar/otp/generate
{
  "aadharNumber": "123456789012",
  "uniqueId": "LEAD12345",
  "token": "AUTH_TOKEN_HERE"
}
```

**Response:**
```json
{
  "OtpGeneration": {
    "ErrorCode": "000",
    "ErrorStatus": "OTP sent successfully to registered mobile",
    "transactionId": "TXN_20260330_123456",
    "mobileNumber": "XXXXXX7890"
  }
}
```

#### 2. Validate OTP Request
```json
POST /aadhar/otp/validate
{
  "otp": "123456",
  "uid": "123456789012",
  "uniqueId": "LEAD12345",
  "token": "AUTH_TOKEN_HERE",
  "transactionId": "TXN_20260330_123456"
}
```

**Response:**
```json
{
  "otpValidationNew": {
    "ErrorCode": "000",
    "Status": "Y",
    "TransactionId": "TXN_20260330_123456",
    "KycDetails": {
      "name": "John Doe",
      "dob": "01-01-1990",
      "gender": "M",
      "address": {
        "street": "123 Main St",
        "city": "Mumbai",
        "state": "Maharashtra",
        "pincode": "400001"
      }
    }
  }
}
```

#### 3. Vault Lookup Request
```json
POST /aadhar/vault/lookup
{
  "aadharNumber": "123456789012",
  "uniqueId": "LEAD12345",
  "token": "AUTH_TOKEN_HERE"
}
```

**Response (Found):**
```json
{
  "VaultLoolUp": {
    "errorCode": "000",
    "aadharRefNum": "REF_ABC123",
    "message": "Reference number found"
  }
}
```

**Response (Not Found):**
```json
{
  "VaultLoolUp": {
    "errorCode": "2",
    "message": "Reference number not found"
  }
}
```

#### 4. Vault Registration Request
```json
POST /aadhar/vault/register
{
  "aadharNumber": "123456789012",
  "uniqueId": "LEAD12345",
  "token": "AUTH_TOKEN_HERE"
}
```

**Response:**
```json
{
  "AadharValut": {
    "errorCode": "000",
    "aadharRefNum": "REF_XYZ789",
    "message": "Reference number registered successfully"
  }
}
```

---

## 🎨 UI Components

### 1. Method Selection Dialog

**Shown:** When user clicks "Verify" button on Aadhaar input

```dart
Future<String?> showValidateOptions(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Verification Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sms),
              title: const Text('OTP Based Verification'),
              onTap: () {
                Navigator.pop(context, 'OTP');
              },
            ),
            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: const Text('Biometric Verification'),
              onTap: () {
                Navigator.pop(context, 'Biometric');
              },
            ),
          ],
        ),
      );
    },
  );
}
```

**Returns:**
- `"OTP"` → OTP-based flow
- `"Biometric"` → Biometric flow
- `null` → User cancelled

---

### 2. Consent Form Screen

**File:** `consent_form.dart`

**Layout Structure:**
```
┌─────────────────────────────────────┐
│ AppBar: "Terms & Conditions"        │
├─────────────────────────────────────┤
│ Header                              │
│   └─ Icon + "Please read and accept"│
├─────────────────────────────────────┤
│ Scrollable Content:                 │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Terms Card                      │ │
│ │                                 │ │
│ │ "I voluntarily give my consent  │ │
│ │  to Ujjivan Small Finance Bank  │ │
│ │  Ltd. to use my Aadhaar..."     │ │
│ │                                 │ │
│ │ [Full UIDAI terms text]         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Consent Checkbox Card           │ │
│ │                                 │ │
│ │ ☑ I accept Terms & Conditions   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Proceed with OTP Verification] ← Button │
│                                     │
└─────────────────────────────────────┘
```

**Key Features:**
- ✅ Checkbox must be checked to enable button
- ✅ Loading state during OTP generation
- ✅ Cannot go back during loading
- ✅ Gradient header with icon

---

### 3. OTP Input Bottom Sheet

**File:** `otp_sheet.dart`

**Layout Structure:**
```
┌─────────────────────────────────────┐
│ Drag Handle                         │
├─────────────────────────────────────┤
│ Header                              │
│   └─ "Enter OTP"                    │
│   └─ "Sent to XXXXXX7890"           │
├─────────────────────────────────────┤
│ OTP Input Boxes                     │
│                                     │
│   ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ │
│   │ 1 │ │ 2 │ │ 3 │ │ 4 │ │ 5 │ │ 6 │ │
│   └───┘ └───┘ └───┘ └───┘ └───┘ └───┘ │
│                                     │
├─────────────────────────────────────┤
│ Timer: "Resend OTP in 00:45"        │
│                                     │
│ [Resend OTP]  (disabled for 60s)    │
├─────────────────────────────────────┤
│                                     │
│ [Verify OTP] ← Primary action       │
│                                     │
└─────────────────────────────────────┘
```

**Key Features:**
- ✅ Auto-focus next box on input
- ✅ Auto-focus previous box on backspace
- ✅ 60-second expiry timer
- ✅ Resend OTP disabled for first 60 seconds
- ✅ Auto-clear fields after expiry
- ✅ Loading indicator during verification

**State Management:**
```dart
late ValueNotifier<bool> isLoading;    // Verify button loading
late ValueNotifier<int> resendTimer;   // 60 → 0 countdown
late ValueNotifier<bool> isResending;  // Resend button loading
late ValueNotifier<int> otpFieldKey;   // Key to rebuild OTP fields
```

---

## 🔒 Security Features

### 1. Aadhaar Number Masking

**Purpose:** Protect against shoulder surfing and screenshots

**Implementation:**
```dart
KYCTextBox(
  maskAadhaar: true,  // Enable masking
  verificationType: VerificationType.aadhaar,
  // ...
)
```

**How it works:**
```dart
String _getMaskedAadhaar(String value) {
  if (value.length <= 4) {
    return value;  // Don't mask if less than 4 digits
  }
  
  // Mask all but last 4 digits
  final int visibleDigits = 4;
  final int maskedLength = value.length - visibleDigits;
  final String masked = 'X' * maskedLength;
  final String visible = value.substring(maskedLength);
  
  return masked + visible;
}

// Example:
// Input:  "123456789012"
// Masked: "XXXXXXXX9012"
```

**Display format with spacing:**
```
XXXX XXXX 9012
```

**Internal value stored:**
```dart
// Actual value (not masked): "123456789012"
// This is what gets sent to API
```

---

### 2. OTP Transaction ID Validation

**Security Benefit:** Prevents replay attacks and OTP reuse

**How it works:**

1. **OTP Generation:**
   ```dart
   // Server generates unique transaction ID
   transactionId = "TXN_" + timestamp + "_" + randomNumber
   // Example: "TXN_20260330123456_78945612"
   ```

2. **OTP Validation:**
   ```dart
   // Client must send same transaction ID
   {
     "otp": "123456",
     "transactionId": "TXN_20260330123456_78945612"
   }
   ```

3. **Server-side Check:**
   ```
   IF transactionId matches OTP generation request
   AND OTP is correct
   AND not expired
   THEN success
   ELSE fail
   ```

**Resend OTP Security:**
```dart
// Old transaction ID
currentTransactionId = "TXN_001"

// User clicks Resend OTP
// New transaction ID generated
currentTransactionId = "TXN_002"

// Now OTPs associated with TXN_001 are invalid
// Only OTPs for TXN_002 will work
```

---

### 3. OTP Expiry Timer

**Implementation:**
```dart
void _startExpiryTimer() {
  _expiryTimer?.cancel();
  _expiryTimer = Timer(const Duration(seconds: 60), () {
    if (mounted && !isLoading.value) {
      _resetOtpField();
      _showExpiryAlert();
    }
  });
}
```

**User Experience:**
- OTP valid for: **60 seconds**
- If expired: Alert shown, fields cleared
- User action: Click "Resend OTP"

---

### 4. UIDAI Consent Compliance

**Regulatory Requirement:** User must explicitly consent to Aadhaar usage

**Implementation:**
- ✅ Full terms displayed (not hidden in scrollable area)
- ✅ Checkbox required before proceeding
- ✅ Button disabled until consent given
- ✅ Clear wording: "I accept Terms & Conditions"

**Terms include:**
- Purpose of collection
- Data storage compliance
- Alternative verification methods
- User's voluntary consent

---

## 🧪 Testing Scenarios

### Functional Testing Checklist

#### Input Validation
- [ ] Enter less than 12 digits → Show error
- [ ] Enter more than 12 digits → Show error
- [ ] Enter alphabets → Show error
- [ ] Enter special characters → Show error
- [ ] Enter exactly 12 digits → Allow verification
- [ ] Test masking (if enabled) → Shows XXXXXXXX9012

#### Method Selection
- [ ] Click Verify → Dialog opens
- [ ] Select "OTP Based" → Navigate to Consent
- [ ] Select "Biometric" → Return to widget
- [ ] Click outside dialog → Cancel

#### Consent Form
- [ ] Checkbox unchecked → Button disabled
- [ ] Checkbox checked → Button enabled
- [ ] Click Proceed without checkbox → Nothing happens
- [ ] Click Proceed with checkbox → OTP generation starts
- [ ] Back button during loading → Disabled

#### OTP Generation
- [ ] Success (ErrorCode 000) → OTP sheet opens
- [ ] Failure (ErrorCode ≠ 000) → Error alert shown
- [ ] Check transactionId extracted → Logged to console

#### OTP Input
- [ ] Enter 1 digit → Auto-focus next box
- [ ] Backspace on empty box → Focus previous box
- [ ] Enter 6 digits → Enable Verify button
- [ ] Timer counts from 60 → 0
- [ ] Timer reaches 0 → Show expiry alert
- [ ] Click Resend before timer ends → Button disabled

#### OTP Resend
- [ ] After 60s, click Resend → New OTP generated
- [ ] Check new transactionId → Different from first
- [ ] Try old OTP → Should fail
- [ ] Try new OTP → Should succeed

#### OTP Validation
- [ ] Enter correct OTP → Success
- [ ] Enter incorrect OTP → Error alert
- [ ] Enter expired OTP → Error alert
- [ ] Verify with wrong transactionId → Fail

#### Vault Operations
- [ ] aadharRefNum in OTP response → Skip vault calls
- [ ] No refNum, Lookup errorCode 000 → Use lookup refNum
- [ ] No refNum, Lookup errorCode 2 → Register new refNum
- [ ] Registration success → Return refNum

#### Success Handling
- [ ] Success dialog shown
- [ ] Sheet dismissed
- [ ] Response contains: otpValidationNew, aadharRefNum, vaultData
- [ ] Button state → "verified" (green)
- [ ] onSuccess callback called

---

### API Mock Responses

#### Offline Testing Setup

Create mock JSON files in `assets/mock/`:

**1. otp_generate_success.json**
```json
{
  "OtpGeneration": {
    "ErrorCode": "000",
    "ErrorStatus": "OTP sent successfully",
    "transactionId": "MOCK_TXN_123456",
    "mobileNumber": "XXXXXX7890"
  }
}
```

**2. otp_validate_success.json**
```json
{
  "otpValidationNew": {
    "ErrorCode": "000",
    "Status": "Y",
    "TransactionId": "MOCK_TXN_123456",
    "KycDetails": {
      "name": "Test User",
      "dob": "01-01-1990",
      "gender": "M"
    }
  }
}
```

**3. vault_lookup_found.json**
```json
{
  "VaultLoolUp": {
    "errorCode": "000",
    "aadharRefNum": "MOCK_REF_ABC123"
  }
}
```

**4. vault_lookup_not_found.json**
```json
{
  "VaultLoolUp": {
    "errorCode": "2"
  }
}
```

**5. vault_register_success.json**
```json
{
  "AadharValut": {
    "errorCode": "000",
    "aadharRefNum": "MOCK_REF_XYZ789"
  }
}
```

**Usage:**
```dart
KYCTextBox(
  isOffline: true,  // Enable offline mode
  otpGendrateassetPath: 'assets/mock/otp_generate_success.json',
  aadhaarResponseassetspath: 'assets/mock/otp_validate_success.json',
  aadharvaultlookupassetpath: 'assets/mock/vault_lookup_found.json',
  // ...
)
```

---

### Error Scenarios Testing

| Scenario | Test Steps | Expected Behavior |
|----------|-----------|------------------|
| **Invalid Aadhaar** | Enter 11 digits, click Verify | Form validation error shown |
| **OTP Generation Fails** | Mock API returns ErrorCode ≠ 000 | Error alert: "OTP generation failed" |
| **Wrong OTP** | Enter incorrect 6-digit OTP | Error alert: "Invalid OTP" |
| **OTP Expired** | Wait >60s, then verify | Alert: "OTP Expired, click Resend" |
| **Network Error** | Disconnect internet, click Verify | Error alert: "Network error" |
| **Vault Lookup Fails** | Mock returns errorCode ≠ 000, ≠ 2 | Error alert: "Verification failed" |
| **Vault Registration Fails** | Mock returns errorCode ≠ 000 | Error alert: "Vault registration failed" |

---

## ⚠️ Common Issues & Solutions

### Issue 1: OTP Validation Fails After Resend

**Symptom:**
- User clicks "Resend OTP"
- Enters new OTP
- Validation fails with "Invalid OTP"

**Root Cause:**
`currentTransactionId` not updated after resend

**Solution:**
```dart
// In _handleResendOtp()
if (otpGeneration['ErrorCode'] == '000') {
  // CRITICAL: Update transaction ID
  currentTransactionId = otpGeneration['transactionId'];
  debugPrint("New TransactionId: $currentTransactionId");
}
```

**Verification:**
- Check console logs for "New TransactionId"
- Verify new OTP works
- Verify old OTP fails

---

### Issue 2: aadharRefNum Not Found in Response

**Symptom:**
```
Error: aadharRefNum is null in onSuccess callback
```

**Root Cause:**
Vault operations skipped or failed

**Solution Checklist:**
1. Check OTP validation response:
   ```dart
   if (otpValidation['aadharRefNum'] != null) {
     // Refnum in OTP response - good!
   } else {
     // Must call vault operations
   }
   ```

2. Check vault lookup response:
   ```dart
   debugPrint("Vault Lookup errorCode: ${vaultLookup['errorCode']}");
   debugPrint("Vault Lookup refNum: ${vaultLookup['aadharRefNum']}");
   ```

3. Check vault registration:
   ```dart
   debugPrint("Vault Registration errorCode: ${aadharVault['errorCode']}");
   debugPrint("Vault Registration refNum: ${aadharVault['aadharRefNum']}");
   ```

**Prevention:**
- Always log API responses
- Add null checks:
  ```dart
  final refNum = responseData['aadharRefNum'];
  if (refNum == null || refNum.toString().isEmpty) {
    throw Exception('Reference number not found');
  }
  ```

---

### Issue 3: Multiple Verification Success Dialogs

**Symptom:**
- User sees success dialog multiple times
- onSuccess callback called multiple times

**Root Cause:**
`_verificationCompleted` flag not set properly

**Solution:**
```dart
bool _verificationCompleted = false;

void _handleVerificationSuccess(String message, Response response) {
  if (_verificationCompleted) {
    debugPrint("Verification already completed, skipping duplicate");
    return;  // Prevent duplicate calls
  }
  
  _verificationCompleted = true;
  
  // Show dialog & call onSuccess
  // ...
}

void _handleInputChange(String value) {
  // Reset flag on input change
  _verificationCompleted = false;
}
```

---

### Issue 4: Consent Form Returns Null

**Symptom:**
```dart
consentResponse == null
// Verification stops here
```

**Root Causes:**
1. User pressed back button on consent form
2. User pressed back button on OTP sheet
3. Error occurred but not handled properly

**Solution:**
```dart
// In kyc_verification_widget.dart
final consentResponse = await Navigator.push(...);

if (consentResponse == null) {
  debugPrint("Consent cancelled by user");
  setState(() {
    _buttonStateManager.reset(widget.buttonProps.label);
  });
  return;  // Exit gracefully
}
```

**In OTP Sheet:**
```dart
// Prevent back button dismissal
return PopScope(
  canPop: false,  // Disable back button
  child: BottomSheet(
    // ...
  ),
);
```

---

### Issue 5: Timer Not Stopping After Navigation

**Symptom:**
- Navigate away from OTP sheet
- Timer continues running in background
- Memory leak

**Root Cause:**
Timers not cancelled in dispose()

**Solution:**
```dart
@override
void dispose() {
  // ALWAYS cancel timers in dispose
  _timer?.cancel();
  _expiryTimer?.cancel();
  
  // Dispose value notifiers
  isLoading.dispose();
  resendTimer.dispose();
  isResending.dispose();
  otpFieldKey.dispose();
  
  super.dispose();
}
```

---

### Issue 6: API Endpoints Not Configured

**Symptom:**
```
Exception: No data provider URL or asset path
```

**Root Cause:**
Empty API URLs or asset paths

**Solution:**
```dart
// ALWAYS provide either online URL or offline asset
KYCTextBox(
  // Online mode
  isOffline: false,
  otpGendraassetApiurl: 'https://api.example.com/aadhar/otp/generate',
  aadhaarResponseApiurl: 'https://api.example.com/aadhar/otp/validate',
  // ...
  
  // OR Offline mode
  isOffline: true,
  otpGendrateassetPath: 'assets/mock/otp_generate.json',
  aadhaarResponseassetspath: 'assets/mock/otp_validate.json',
  // ...
)
```

**Validation in widget:**
```dart
if ((isOffline && assetPath.isEmpty) || (!isOffline && apiUrl.isEmpty)) {
  throw Exception('Either asset path (offline) or API URL (online) must be provided');
}
```

---

## 🎓 Learning Resources

### Key Concepts to Understand

1. **Flutter Async Programming**
   - `async`/`await` usage
   - `Future<T>` return types
   - Error handling with try-catch

2. **State Management**
   - `setState()` for UI updates
   - `ValueNotifier<T>` for reactive values
   - Widget lifecycle (initState, dispose)

3. **Navigation & Routes**
   - `Navigator.push()` with awaiting results
   - `Navigator.pop()` with return values
   - Modal bottom sheets

4. **API Integration**
   - Dio HTTP client
   - Request/response parsing
   - Error handling

5. **Timers**
   - `Timer.periodic()` for countdown
   - `Timer()` for delayed actions
   - Proper cancellation in dispose()

### Code Reading Path

**For New Team Members:**

1. Start: `enums_and_state.dart`
   - Understand `VerificationType` enum
   - Learn `ButtonStateManager`

2. Next: `verification_handlers.dart`
   - See factory pattern
   - Understand `AadhaarVerificationHandler`

3. Then: `kyc_verification_widget.dart`
   - Main widget structure
   - `_verifyAadhaar()` method
   - Success/error handling

4. Then: `consent_form.dart`
   - UI layout
   - OTP generation logic
   - Navigation to OTP sheet

5. Finally: `otp_sheet.dart`
   - OTP input handling
   - Timer management
   - Vault operations
   - Response building

6. Bonus: `api_client.dart`
   - HTTP client setup
   - Interceptors
   - Error handling

---

## 🔧 Debugging Tips

### Enable Debug Logging

```dart
// In api_client.dart
ApiClient(
  enableLogging: true,  // Enable Dio logger
);

// Console will show:
// ┌──────────────────────────────────────────────
// │ POST https://api.example.com/aadhar/otp/generate
// │ Headers: {token: xxx, ...}
// │ Body: {"aadharNumber": "123456789012"}
// ├──────────────────────────────────────────────
// │ Response: 200 OK
// │ {"OtpGeneration": {"ErrorCode": "000", ...}}
// └──────────────────────────────────────────────
```

### Add Verbose Debug Prints

```dart
debugPrint("========== AADHAAR VERIFICATION START ==========");
debugPrint("Aadhaar Number: $_currentInput");
debugPrint("Lead ID: ${widget.leadId}");
debugPrint("Is Offline: ${widget.isOffline}");

// ... verification code ...

debugPrint("TransactionId: $transactionId");
debugPrint("OTP Validation Status: ${otpValidation['Status']}");
debugPrint("RefNum: $aadhaarRefNumber");
debugPrint("========== AADHAAR VERIFICATION END ==========");
```

### Use Flutter DevTools

1. **Network Tab:** Monitor API calls
2. **Widget Inspector:** Check widget tree
3. **Timeline:** Find performance bottlenecks
4. **Logging:** Filter by "debugPrint"

### Breakpoint Locations

Set breakpoints at:
- `_verifyAadhaar()` - Start of flow
- `_handleOtpVerification()` in ConsentForm - OTP generation
- `_handleOtpVerification()` in OtpSheet - OTP validation
- Vault lookup response parsing
- `_handleVerificationSuccess()` - Final success

---

## 📞 Support & Escalation

### When to Ask for Help

❌ **Don't hesitate to ask if:**
- API integration not working
- Cannot understand vault flow
- Timers behaving unexpectedly
- Navigation issues
- State management confusion

✅ **Try first:**
1. Check debug logs
2. Review this KT document
3. Read inline code comments
4. Test in offline mode with mocks

### Contact

- **Package Maintainer:** Gayathri
- **Documentation:** This file + `sysmo_documentation.md`
- **Code Repository:** [Your repo URL]

---

## 🚀 Quick Start Checklist for New Developers

- [ ] Read this entire document
- [ ] Set up offline mock JSON files
- [ ] Run app with `isOffline: true`
- [ ] Test complete OTP flow with mocks
- [ ] Add debug prints to understand flow
- [ ] Switch to online mode with real APIs
- [ ] Test all error scenarios
- [ ] Review code comments in `otp_sheet.dart`
- [ ] Understand transaction ID concept
- [ ] Practice explaining flow to teammate

---

## 📝 Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | March 30, 2026 | Initial KT documentation created | Gayathri |

---

## ✅ Conclusion

### Key Takeaways

1. **Aadhaar flow is multi-step:**
   - Consent → OTP Generation → OTP Validation → Vault Operations

2. **Critical elements:**
   - Transaction ID tracks OTP validity
   - Timers manage OTP expiry
   - Vault provides reference number for future lookups

3. **State management:**
   - Button states reflect verification progress
   - ValueNotifiers enable reactive UI
   - Proper disposal prevents memory leaks

4. **Error handling:**
   - Check ErrorCode at every API call
   - Show user-friendly error messages
   - Log errors for debugging

5. **Testing:**
   - Use offline mode for rapid testing
   - Mock all API responses
   - Test edge cases (expired OTP, network errors)
