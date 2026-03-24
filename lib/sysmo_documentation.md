# Sysmo KYC Verification Package 

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Project Structure](#project-structure)
4. [Dependencies](#dependencies)
5. [Configuration & Setup](#configuration--setup)
6. [Core Components](#core-components)
7. [Verification Flow](#verification-flow)
8. [Widget Components](#widget-components)
9. [API Integration](#api-integration)
10. [Security & Encryption](#security--encryption)
11. [State Management](#state-management)
12. [Response Handling](#response-handling)
13. [Error Handling](#error-handling)
14. [Usage Examples](#usage-examples)
15. [Testing](#testing)
16. [Best Practices](#best-practices)
17. [Troubleshooting](#troubleshooting)
18. [Future Enhancements](#future-enhancements)

---

## Overview

### What is Sysmo Verification?

**Sysmo Verification** is a production-ready Flutter package that provides comprehensive KYC (Know Your Customer) document verification capabilities. It supports multiple document types with a unified, customizable UI and both online/offline verification modes.

### Key Highlights

- **Version**: 0.0.17
- **Author**: Gayathri Balraj
- **Created**: November 2024
- **Repository**: [GitHub](https://github.com/gayathribalraj/Sysmo_Verification)
- **License**: MIT

### Supported Verification Types

| Document Type | Enum Value | Description |
|--------------|------------|-------------|
| **Aadhaar** | `VerificationType.aadhaar` | Indian Aadhaar number with OTP verification |
| **PAN Card** | `VerificationType.pan` | Permanent Account Number verification |
| **Voter ID** | `VerificationType.voter` | Electoral Photo Identity Card (EPIC) verification |
| **GST** | `VerificationType.gst` | Goods and Services Tax Identification Number |
| **Passport** | `VerificationType.passport` | Indian Passport verification |

### Core Features

- **Unified Widget** - Single `KYCTextBox` widget for all verification types  
- **Online/Offline Mode** - Support for both live API calls and local asset-based testing  
- **Reactive Forms** - Built on `reactive_forms` for robust form validation  
- **AES Encryption** - OpenSSL-compatible encryption for data security  
- **Token Management** - Automatic token generation and validation  
- **OTP Support** - Full Aadhaar OTP generation and verification flow  
- **Vault Integration** - Aadhaar vault lookup and storage  
- **Customizable UI** - Complete control over styling, colors, and behavior  
- **State Management** - Built-in button states (idle, loading, success, error)  
- **Input Validation** - Pattern-based validation with custom error messages  
- **Masking Support** - Aadhaar number masking (8 masked + 4 visible digits)  
- **Error Handling** - Comprehensive error handling with user-friendly alerts  

---

## Architecture

### Design Patterns Used

1. **Factory Pattern** - `VerificationHandlerFactory`, `ResponseParserFactory`
2. **Strategy Pattern** - Different handlers for each verification type
3. **State Management Pattern** - `ButtonStateManager`, `InputValidationManager`
4. **Mixin Pattern** - `VerificationMixin` for shared verification logic
5. **Builder Pattern** - Widget composition with props classes
6. **Interceptor Pattern** - `TokenInterceptor` for request/response handling

### Architectural Layers

```
┌─────────────────────────────────────────────┐
│         Presentation Layer                   │
│  (Widgets: KYCTextBox, KYCInputField, etc.) │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│         Business Logic Layer                 │
│  (Handlers, Parsers, State Managers)        │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│         Data Layer                           │
│  (ApiClient, Offline Handler, Encryption)   │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│         External Services                    │
│  (REST APIs, Asset Loader)                  │
└─────────────────────────────────────────────┘
```

### Component Interaction Flow

```
User Input → KYCTextBox → VerificationHandler → ApiClient
                ↓                                    ↓
         ButtonStateManager              TokenInterceptor
                ↓                                    ↓
         ResponseParser ←───────────────── API Response
                ↓
         onSuccess/onError Callback
```

---

## Project Structure

```
lib/
├── kyc_validation.dart              # Main export file (public API)
├── main.dart                         # Package initialization
├── sysmo_documentation.md        # This documentation
│
└── src/
    ├── core/                         # Core business logic
    │   ├── enums_and_state.dart     # Enums and state managers
    │   ├── response_parsers.dart    # Response parsing implementations
    │   ├── verification_handlers.dart # Verification logic
    │   │
    │   └── api/                      # API and configuration
    │       ├── api_client.dart       # HTTP client with Dio
    │       ├── api_config.dart       # API endpoints from .env
    │       ├── app_constant.dart     # Validation patterns & constants
    │       ├── constant_variable.dart # String constants
    │       └── offline_verification_handler.dart # Asset loading
    │
    ├── Utils/                        # Utility modules
    │   ├── aes_utils.dart           # AES encryption/decryption
    │   └── service.dart             # KYCService wrapper
    │
    └── widget/                       # UI components
        ├── kyc_verification.dart    # Wrapper widgets for each type
        │
        └── uiwidgetprops/           # Widget property classes
            ├── kyc_verification_widget.dart  # Main KYCTextBox widget
            ├── kyc_input_field.dart          # Reactive text field
            ├── verify_button.dart            # Verify button widget
            ├── otp_sheet.dart               # OTP bottom sheet
            ├── consent_form.dart            # Terms & conditions
            ├── form_props.dart              # Form configuration
            ├── button_props.dart            # Button configuration
            ├── style_props.dart             # Styling configuration
            ├── kyc_wrapper_class.dart       # Type-specific wrappers
            ├── pan_request.dart             # PAN request model
            ├── voterid_request.dart         # Voter ID request model
            └── sysmo_alert.dart             # Custom alert dialogs
```

### File Responsibilities

| File | Purpose | Key Classes |
|------|---------|-------------|
| `enums_and_state.dart` | State management, enums | `VerificationType`, `ButtonStateManager`, `InputValidationManager` |
| `verification_handlers.dart` | Verification logic per type | `VerificationHandler`, `VoterVerificationHandler`, etc. |
| `response_parsers.dart` | Parse API responses | `ResponseParser`, `VoterResponseParser`, etc. |
| `api_client.dart` | HTTP client, interceptors | `ApiClient`, `TokenInterceptor` |
| `aes_utils.dart` | Encryption utilities | `encryptString()`, `decryptString()` |
| `kyc_verification_widget.dart` | Main verification widget | `KYCTextBox` |

---

## Dependencies

### Production Dependencies

```yaml
dependencies:
  crypto: ^3.0.6                    # Hashing for encryption
  dio: ^5.9.0                       # HTTP client
  encrypt: ^5.0.3                   # AES encryption
  equatable: ^2.0.7                 # Value equality
  flutter_dotenv: ^5.1.0            # Environment variables
  flutter_bloc: ^9.1.1              # State management (not actively used)
  flutter_otp_text_field: ^1.5.1+1 # OTP input fields
  pretty_dio_logger: ^1.4.0         # Request/response logging
  reactive_forms: ^18.1.1           # Reactive form management
```

### Development Dependencies

```yaml
dev_dependencies:
  flutter_test:                     # Testing framework
    sdk: flutter
  flutter_lints: ^5.0.0            # Linting rules
```

### Dependency Usage

| Package | Used For | Location Used |
|---------|----------|---------------|
| `dio` | HTTP requests | `api_client.dart` |
| `encrypt` | AES-256-CBC encryption | `aes_utils.dart` |
| `reactive_forms` | Form state management | All input widgets |
| `flutter_otp_text_field` | OTP input UI | `otp_sheet.dart` |
| `flutter_dotenv` | Load API endpoints | `api_config.dart` |
| `crypto` | MD5 hashing for key derivation | `aes_utils.dart` |

---

## Configuration & Setup

### 1. Package Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  sysmo_verification: ^0.0.17
```

Run:
```bash
flutter pub get
```

### 2. Environment Configuration

Create a `.env` file in your project root:

```env
voter_verification_endpoint=https://api.example.com/voter/verify
pan_verification_endpoint=https://api.example.com/pan/verify
# Add other endpoints as needed
```

### 3. Load Environment Variables

In your app's `main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading .env file: $e');
  }
  
  runApp(MyApp());
}
```

### 4. Platform-Specific Setup

#### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <false/>
</dict>
```

### 5. Encryption Key Configuration

Update the encryption key in `lib/src/core/api/app_constant.dart`:

```dart
class AppConstant {
  static const String encKey = 'your-16-character-key';  // Must be 16 chars
}
```

**Security Note**: Store encryption keys in secure vaults (e.g., AWS Secrets Manager) in production.

---

## Core Components

### 1. VerificationType Enum

Defines the type of KYC verification to perform.

```dart
enum VerificationType { 
  voter,      // Voter ID/EPIC verification
  aadhaar,    // Aadhaar verification with OTP
  pan,        // PAN card verification
  gst,        // GST number verification
  passport    // Passport verification
}
```

### 2. ButtonStateManager

Manages button UI states throughout the verification lifecycle.

**States:**
```dart
enum ButtonState { 
  idle,      // Initial state, ready for action
  loading,   // API call in progress
  success,   // Verification successful
  error      // Verification failed
}
```

**Methods:**

```dart
class ButtonStateManager {
  void initialize(String initialText);    // Set initial button text
  void setLoading();                      // Show loading spinner
  void stopLoading();                     // Remove loading spinner
  void setSuccess(String successText);    // Show success state
  void setError(String errorText);        // Show error state
  void reset(String defaultText);         // Reset to idle state
  
  Color getBackgroundColor({              // Get state-based color
    Color? idleColor,
    Color? loadingColor,
    Color? successColor,
    Color? errorColor,
  });
}
```

**Usage Example:**

```dart
final buttonManager = ButtonStateManager();
buttonManager.initialize('Verify');

// During API call
buttonManager.setLoading();

// On success
buttonManager.setSuccess('Verified ✓');

// On error
buttonManager.setError('Failed');
```

### 3. InputValidationManager

Manages input field validation using regex patterns.

**Methods:**

```dart
class InputValidationManager {
  void addPattern(RegExp pattern);        // Add validation pattern
  bool validate(String input);            // Validate input against patterns
  void reset();                           // Reset validation state
  bool get isValid;                       // Check if input is valid
}
```

**Usage Example:**

```dart
final validator = InputValidationManager();
validator.addPattern(AppConstant.panPattern);  // ^[A-Z]{5}[0-9]{4}[A-Z]$

if (validator.validate('ABCDE1234F')) {
  print('Valid PAN');
}
```

### 4. VerificationHandler (Abstract Class)

Base class for all verification handlers using Factory pattern.

**Abstract Methods:**

```dart
abstract class VerificationHandler {
  Future<Response> verifyOnline(String url, {dynamic request});
  Future<Response> verifyOffline(String assetPath);
  
  Future<Response> verify({
    required bool isOffline,
    String? url,
    String? assetPath,
    dynamic request,
  });
}
```

**Implementations:**

- `VoterVerificationHandler` - Voter ID verification
- `PanVerificationHandler` - PAN card verification
- `AadhaarVerificationHandler` - Aadhaar verification
- `GstVerificationHandler` - GST verification
- `PassportVerificationHandler` - Passport verification

**Factory Usage:**

```dart
final handler = VerificationHandlerFactory.create(VerificationType.pan);
final response = await handler.verify(
  isOffline: false,
  url: 'https://api.example.com/pan',
  request: PanidRequest(pan: 'ABCDE1234F'),
);
```

### 5. ResponseParser (Abstract Class)

Parses API responses to determine verification success.

**Abstract Methods:**

```dart
abstract class ResponseParser {
  bool parseOnlineResponse(dynamic responseData);
  bool parseOfflineResponse(dynamic responseData);
}
```

**Implementations:**

- `VoterResponseParser` - Parse voter ID response
- `PanResponseParser` - Parse PAN response
- `GstResponseParser` - Parse GST response
- `PassportResponseParser` - Parse passport response

**Example Response Validation:**

```dart
// PAN Response Parser
@override
bool parseOnlineResponse(dynamic responseData) {
  try {
    return responseData['status'] == 'SUCCESS' &&
           responseData['responseCode'] == '200';
  } catch (e) {
    return false;
  }
}
```

### 6. ApiClient

HTTP client wrapper with automatic token handling and encryption.

**Features:**

- Automatic token generation and validation
- Request/response encryption
- Pretty logging
- Token mismatch detection

**Key Methods:**

```dart
class ApiClient {
  Future<Response> post(String url, {dynamic data});
  Future<Response> get(String url);
}
```

**Token Flow:**

```
1. Generate token: timestamp_randomNumber
2. Encrypt token with AES
3. Add to request headers & body
4. Server processes request
5. Server returns encrypted response with token
6. Decrypt response
7. Compare tokens
8. Reject on mismatch
```

---

## Verification Flow

### General Verification Flow

```
┌─────────────────┐
│  User enters    │
│  document number│
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Input validation│
│  (regex pattern) │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Create request  │
│  object         │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Select handler  │
│  (Factory)      │
└────────┬────────┘
         │
         ↓
┌─────────────────────┐
│  Online or Offline? │
└─────┬──────────┬────┘
      │          │
   Online     Offline
      │          │
      ↓          ↓
┌──────────┐  ┌────────────┐
│ API Call │  │ Load Asset │
└────┬─────┘  └─────┬──────┘
     │              │
     └──────┬───────┘
            ↓
    ┌───────────────┐
    │ Parse Response│
    └───────┬───────┘
            │
      ┌─────┴─────┐
      │           │
   Success      Error
      │           │
      ↓           ↓
  ┌────────┐  ┌────────┐
  │Success │  │ Error  │
  │Callback│  │Callback│
  └────────┘  └────────┘
```

### Aadhaar Verification Flow (Special Case)

Aadhaar verification has a unique flow with OTP:

```
1. User enters Aadhaar number
2. Click "Verify" → Opens Consent Form
3. User accepts terms → Generates OTP
4. OTP sent to Aadhaar-linked mobile
5. User enters OTP in bottom sheet
6. Verify OTP
7. On success → Store in vault (optional)
8. Return Aadhaar reference number
```

**Detailed Aadhaar Flow:**

```dart
// Step 1: Enter Aadhaar number
KYCTextBox(
  verificationType: VerificationType.aadhaar,
  formProps: FormProps(
    formControlName: 'aadhaar',
    label: 'Aadhaar Number',
    maxLength: 12,
  ),
  validationPattern: AppConstant.aadhaarPattern,
  // ...
)

// Step 2: Click Verify → Show Consent Form
// consent_form.dart opens

// Step 3: Accept Terms → Generate OTP
await KYCService().verify(
  isOffline: false,
  url: widget.otpGenerateApiUrl,
  request: jsonEncode({
    'aadharNumber': aadhaarNumber,
    'uniqueId': leadId,
    'token': token,
  }),
);

// Step 4: Show OTP Sheet
OtpSheet(
  aadhaarNumber: aadhaarNumber,
  url: aadhaarResponseApiurl,
  // ...
)

// Step 5: Verify OTP
await KYCService().verify(
  isOffline: false,
  url: widget.url,
  request: jsonEncode({
    'otp': enteredOtp,
    'uid': aadhaarNumber,
    'uniqueId': leadId,
    'token': token,
  }),
);

// Step 6: Store in vault (if configured)
await KYCService().verify(
  isOffline: false,
  url: aadharvaultApiurl,
  request: jsonEncode({
    'aadhaarNumber': aadhaarNumber,
    'aadhaarRefNum': refNumber,
    'uniqueId': leadId,
  }),
);
```

---

## Widget Components

### 1. KYCTextBox (Main Widget)

The primary widget for KYC verification. Handles input, validation, and verification.

**Constructor:**

```dart
KYCTextBox({
  Key? key,
  required FormProps formProps,
  required StyleProps styleProps,
  required ButtonProps buttonProps,
  required bool isOffline,
  String? assetPath,
  String? apiUrl,
  required ValueChanged<dynamic> onSuccess,
  required ValueChanged<dynamic> onError,
  required VerificationType verificationType,
  String? kycNumber,                           // Pre-verified number
  ReactiveFormFieldCallback<String>? onChange,
  bool showVerifyButton = false,
  String? validationPatternErrorMessage,
  required RegExp? validationPattern,
  // Aadhaar-specific parameters
  String otpGendraassetApiurl = '',
  String aadhaarResponseApiurl = '',
  String aadharvaultApiurl = '',
  String aadharvaultlookupapiurl = '',
  required String leadId,
  required String token,
  bool obscureText = false,
  bool maskAadhaar = false,
  List<String>? usedAadhaarRefNumbers,
})
```

**Key Features:**

- Automatic button state management
- Built-in input validation
- Supports offline mode with asset files
- Customizable styling
- Pre-verification support (kycNumber parameter)
- Aadhaar masking support

**Example Usage:**

```dart
KYCTextBox(
  formProps: FormProps(
    formControlName: 'panNumber',
    label: 'PAN Number',
    mandatory: true,
    maxLength: 10,
  ),
  styleProps: StyleProps(
    textStyle: TextStyle(fontSize: 16),
    borderRadius: 8,
  ),
  buttonProps: ButtonProps(
    label: 'Verify PAN',
    backgroundColor: Colors.blue,
  ),
  isOffline: false,
  apiUrl: dotenv.env['pan_verification_endpoint'],
  verificationType: VerificationType.pan,
  validationPattern: AppConstant.panPattern,
  validationPatternErrorMessage: 'Invalid PAN format',
  onSuccess: (response) {
    print('PAN verified: $response');
  },
  onError: (error) {
    print('Verification failed: $error');
  },
  leadId: 'LEAD123',
  token: 'YOUR_TOKEN',
)
```

### 2. KYCInputField

Reactive input field with validation and masking support.

**Key Features:**

- Reactive form integration
- Custom validation patterns
- Aadhaar masking (8 masked + 4 visible)
- Password obscure toggle
- Focus management

**Masking Example:**

```dart
KYCInputField(
  formProps: FormProps(
    formControlName: 'aadhaar',
    label: 'Aadhaar Number',
  ),
  styleProps: StyleProps(),
  validationManager: InputValidationManager(),
  maskAadhaar: true,  // Enables masking
)

// User sees: ********4567 (when not focused)
// User sees: 123456784567 (when focused)
```

### 3. VerifyButton

Stateful verification button with loading, success, and error states.

**Button States:**

| State | Background Color | Text | Behavior |
|-------|-----------------|------|----------|
| Idle | Primary color | "Verify" | Clickable |
| Loading | Grey | Spinner | Disabled |
| Success | Green | "Verified ✓" | Disabled |
| Error | Red | Error message | Clickable |

**Example:**

```dart
VerifyButton(
  stateManager: buttonStateManager,
  buttonProps: ButtonProps(
    label: 'Verify',
    backgroundColor: Colors.blue,
  ),
  onPressed: () {
    // Trigger verification
  },
)
```

### 4. OtpSheet (Bottom Sheet)

Modal bottom sheet for OTP entry and verification.

**Features:**

- 6-digit OTP input
- Resend OTP functionality with 30s timer
- Auto-validation
- Persistent attempts tracking
- Success/failure alerts

**Parameters:**

```dart
OtpSheet(
  aadhaarNumber: '123456789012',
  url: 'https://api.example.com/verify-otp',
  isOffline: false,
  leadId: 'LEAD123',
  token: 'TOKEN',
  aadharvaultlookupassetpath: 'assets/vault_lookup.json',
  aadharvaultlookupapiurl: 'https://api.example.com/vault/lookup',
  aadharvaultassetpath: 'assets/vault_store.json',
  aadharvaultApiurl: 'https://api.example.com/vault/store',
  otpGenerateAssetPath: 'assets/otp_generate.json',
  otpGenerateApiUrl: 'https://api.example.com/otp/generate',
)
```

### 5. ConsentForm

Full-screen consent form for Aadhaar verification.

**Features:**

- Terms & conditions display
- Checkbox for acceptance
- Scrollable content
- Gradient UI design
- Loading state during OTP generation

**Usage:**

```dart
// Automatically shown when verifying Aadhaar
// User must accept terms before OTP generation
```

### 6. Wrapper Widgets

Type-specific wrapper widgets for cleaner code organization:

```dart
// Voter ID Wrapper
VoterVerification(
  kycTextBox: KYCTextBox(/* config */),
)

// PAN Wrapper
PanVerification(
  kycTextBox: KYCTextBox(/* config */),
)

// Similar wrappers for Aadhaar, GST, Passport
```

---

## API Integration

### Request Format

All API requests follow this encrypted format:

**Raw Request Body:**

```json
{
  "pan": "ABCDE1234F",
  "consent": "Y",
  "token": "encrypted_token_value"
}
```

**Encrypted Request (sent to server):**

```json
{
  "data": "U2FsdGVkX1..."  // AES-encrypted payload
}
```

### Response Format

**Expected API Response Structure:**

#### Voter ID Response

```json
{
  "status": "SUCCESS",
  "responseCode": "200",
  "data": {
    "name": "John Doe",
    "epicNo": "ABC1234567",
    "age": "30",
    "gender": "Male"
  }
}
```

#### PAN Response

```json
{
  "status": "SUCCESS",
  "responseCode": "200",
  "PanValidation": {
    "success": true,
    "name": "JOHN DOE",
    "panNumber": "ABCDE1234F",
    "category": "Individual"
  }
}
```

#### Aadhaar OTP Generation Response

```json
{
  "OtpGeneration": {
    "ErrorCode": "000",
    "Status": "Success",
    "Message": "OTP sent successfully",
    "TransactionId": "TXN123456"
  }
}
```

#### Aadhaar OTP Verification Response

```json
{
  "otpValidationNew": {
    "ErrorCode": "000",
    "Status": "Y",
    "TransactionId": "TXN123456",
    "aadharRefNum": "REF987654",
    "KycDetails": {
      "name": "John Doe",
      "dob": "01-01-1990",
      "gender": "M",
      "address": "..."
    }
  }
}
```

### API Endpoints Configuration

Configure endpoints in `.env` file:

```env
# Voter ID
voter_verification_endpoint=https://api.example.com/voter/verify

# PAN
pan_verification_endpoint=https://api.example.com/pan/verify

# Aadhaar (multiple endpoints)
aadhaar_otp_generate_endpoint=https://api.example.com/aadhaar/otp/generate
aadhaar_otp_verify_endpoint=https://api.example.com/aadhaar/otp/verify
aadhaar_vault_store_endpoint=https://api.example.com/aadhaar/vault/store
aadhaar_vault_lookup_endpoint=https://api.example.com/aadhaar/vault/lookup

# GST
gst_verification_endpoint=https://api.example.com/gst/verify

# Passport
passport_verification_endpoint=https://api.example.com/passport/verify
```

### HTTP Headers

Default headers sent with every request:

```dart
Map<String, String> defaultHeaders = {
  "Accept": "application/json",
  "Content-Type": "application/json",
  'token': "encrypted_token",              // Auto-generated
  'deviceId': "encrypted_device_id",
  'userid': 'SAIGANESH',
  // Add custom headers as needed
};
```

### Request Models

#### PAN Request

```dart
class PanidRequest {
  final String pan;
  final String consent;
  
  const PanidRequest({
    required this.pan, 
    this.consent = "Y"
  });
  
  Map<String, dynamic> toMap() {
    return {'pan': pan, 'consent': consent};
  }
}
```

#### Voter ID Request

```dart
class VoteridRequest {
  final String epicNo;
  final String consent;
  
  const VoteridRequest({
    required this.epicNo,
    this.consent = "Y"
  });
  
  Map<String, dynamic> toMap() {
    return {'epicNo': epicNo, 'consent': consent};
  }
}
```

### Custom API Integration

To integrate with your own APIs:

1. **Match the expected response format** OR
2. **Create custom response parser**:

```dart
class CustomResponseParser implements ResponseParser {
  @override
  bool parseOnlineResponse(dynamic responseData) {
    // Your custom parsing logic
    return responseData['success'] == true;
  }
  
  @override
  bool parseOfflineResponse(dynamic responseData) {
    return parseOnlineResponse(responseData);
  }
}
```

3. **Update the factory**:

```dart
// In response_parsers.dart
class ResponseParserFactory {
  static ResponseParser create(VerificationType type) {
    return switch (type) {
      VerificationType.pan => CustomResponseParser(),  // Your parser
      // ... other types
    };
  }
}
```

---

## Security & Encryption

### AES Encryption Implementation

The package uses **AES-256-CBC** encryption with OpenSSL-compatible format.

#### Encryption Process

```dart
String encryptString({required String inputText}) {
  // 1. Generate 8-byte random salt
  final salt = _secureRandomBytes(8);
  
  // 2. Derive key+iv from password using EVP_BytesToKey (MD5)
  final dk = _evpBytesToKey(
    password: Uint8List.fromList(utf8.encode(AppConstant.encKey)),
    salt: salt,
    keyLen: 32,  // AES-256
    ivLen: 16,   // 128-bit IV
  );
  
  // 3. Encrypt with AES-256-CBC
  final encrypter = Encrypter(AES(
    Key(dk['key']!), 
    mode: AESMode.cbc
  ));
  final encrypted = encrypter.encryptBytes(
    utf8.encode(inputText), 
    iv: IV(dk['iv']!)
  );
  
  // 4. Build OpenSSL format: "Salted__" + salt + ciphertext
  final output = 'Salted__' + Base64Encode(salt + encrypted.bytes);
  
  return output;  // Returns: U2FsdGVkX1...
}
```

#### Decryption Process

```dart
String decryptString({required String encryptedText}) {
  // 1. Decode base64
  final decoded = base64.decode(encryptedText);
  
  // 2. Check for "Salted__" prefix
  if (_isOpenSslSalted(decoded)) {
    final salt = decoded.sublist(8, 16);
    final cipherBytes = decoded.sublist(16);
    
    // 3. Derive same key+iv
    final dk = _evpBytesToKey(
      password: Uint8List.fromList(utf8.encode(AppConstant.encKey)),
      salt: salt,
      keyLen: 32,
      ivLen: 16,
    );
    
    // 4. Decrypt
    final encrypter = Encrypter(AES(
      Key(dk['key']!), 
      mode: AESMode.cbc
    ));
    return encrypter.decrypt(
      Encrypted(cipherBytes), 
      iv: IV(dk['iv']!)
    );
  }
}
```

### Token Management

#### Token Generation

```dart
String generateToken() {
  var timestamp = DateTime.now();
  var ranNum = Random().nextInt(90000000) + 10000000;
  
  String token = "${timestamp.toString()}_${ranNum.toString()}";
  expectedTokenValue = token;  // Store for validation
  
  return encryptString(inputText: token);
}
```

#### Token Validation Flow

```
1. Client generates token: "2025-01-15 10:30:00_12345678"
2. Client encrypts token → "U2FsdGVkX1..."
3. Client stores plaintext in expectedTokenValue
4. Client sends encrypted token in headers & body
5. Server processes request
6. Server returns encrypted token in response
7. Client decrypts response token
8. Client compares: decrypted == expectedTokenValue
9. If match → Success, else → TokenMismatchException
```

### TokenInterceptor Implementation

```dart
class TokenInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Generate and add token
    String token = generateToken();
    options.headers['token'] = token;
    
    // Encrypt request body
    if (options.data is Map<String, dynamic>) {
      final body = Map<String, dynamic>.from(options.data);
      body['token'] = token;
      options.data = _encryptRequestBody(body);
    }
    
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Decrypt response body
    final decryptedBody = _decryptResponseBody(response.data);
    
    // Extract and validate token
    String? responseToken = decryptedBody?['token'];
    String? decryptedResponseToken = decryptString(
      encryptedText: responseToken
    );
    
    if (decryptedResponseToken == expectedTokenValue) {
      handler.next(response);  // Success
    } else {
      handler.reject(DioException(/* Token mismatch */));
    }
  }
}
```

### Security Best Practices

**DO:**
- Store encryption keys in secure vaults (AWS Secrets Manager, HashiCorp Vault)
- Use environment variables for API keys
- Implement certificate pinning for production
- Rotate encryption keys periodically
- Use HTTPS only
- Implement rate limiting on server
- Log security events

**DON'T:**
- Hardcode API keys in source code
- Store plaintext passwords
- Expose internal error messages to users
- Skip token validation
- Use weak encryption keys

---

## State Management

### Button State Lifecycle

```
     IDLE (Initial)
       │
       ↓ [User clicks Verify]
    LOADING
       │
       ├──→ SUCCESS (verified)
       │
       └──→ ERROR (failed)
              │
              ↓ [User retries]
            IDLE
```

### State Management Classes

#### 1. ButtonStateManager

```dart
class ButtonStateManager {
  ButtonState _state = ButtonState.idle;
  String _text = '';
  bool _disabled = false;
  
  // Getters
  ButtonState get state => _state;
  bool get isLoading => _state == ButtonState.loading;
  bool get isSuccess => _state == ButtonState.success;
  bool get isError => _state == ButtonState.error;
  bool get isDisabled => _disabled;
  
  // State transitions
  void initialize(String initialText) {
    _text = initialText;
    _state = ButtonState.idle;
    _disabled = false;
  }
  
  void setLoading() {
    _state = ButtonState.loading;
    _disabled = true;
  }
  
  void setSuccess(String successText) {
    _state = ButtonState.success;
    _text = successText;
    _disabled = true;
  }
  
  void setError(String errorText) {
    _state = ButtonState.error;
    _text = errorText;
    _disabled = false;  // Allow retry
  }
  
  void reset(String defaultText) {
    _state = ButtonState.idle;
    _text = defaultText;
    _disabled = false;
  }
}
```

#### 2. InputValidationManager

```dart
class InputValidationManager {
  bool _isValid = true;
  final List<RegExp> _patterns = [];
  
  bool get isValid => _isValid;
  
  void addPattern(RegExp pattern) {
    _patterns.add(pattern);
  }
  
  bool validate(String input) {
    if (input.isEmpty) {
      _isValid = false;
      return false;
    }
    
    _isValid = _patterns.any((pattern) => pattern.hasMatch(input));
    return _isValid;
  }
  
  void reset() {
    _isValid = true;
  }
}
```

### Reactive Forms Integration

The package uses `reactive_forms` for form state management:

```dart
// Define form with validation
final form = FormGroup({
  'panNumber': FormControl<String>(
    validators: [
      Validators.required,
      Validators.pattern(AppConstant.panPattern.pattern),
    ],
  ),
});

// Use in widget
ReactiveFormBuilder(
  form: () => form,
  builder: (context, form, child) {
    return Column(
      children: [
        KYCTextBox(
          formProps: FormProps(
            formControlName: 'panNumber',
            label: 'PAN Number',
          ),
          // ...
        ),
        
        // Get validation errors
        ReactiveFormConsumer(
          builder: (context, form, child) {
            final control = form.control('panNumber');
            if (control.hasErrors) {
              return Text('Invalid PAN');
            }
            return SizedBox.shrink();
          },
        ),
      ],
    );
  },
)
```

### State Persistence

For persistent state across sessions:

```dart
// Save verification status
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString('pan_verified', 'true');
await prefs.setString('pan_number', 'ABCDE1234F');

// Retrieve on app restart
String? panVerified = prefs.getString('pan_verified');
if (panVerified == 'true') {
  // Pre-populate KYCTextBox with verified status
  KYCTextBox(
    kycNumber: prefs.getString('pan_number'),  // Shows as verified
    // ...
  );
}
```

---

## Response Handling

### Response Parser Architecture

Each verification type has a dedicated response parser implementing the `ResponseParser` interface.

#### Response Parser Interface

```dart
abstract class ResponseParser {
  bool parseOnlineResponse(dynamic responseData);
  bool parseOfflineResponse(dynamic responseData);
}
```

### Parser Implementations

#### 1. VoterResponseParser

```dart
class VoterResponseParser implements ResponseParser {
  @override
  bool parseOnlineResponse(dynamic responseData) {
    try {
      return responseData['status'] == 'SUCCESS' &&
             responseData['responseCode'] == '200';
    } catch (e) {
      return false;
    }
  }
  
  @override
  bool parseOfflineResponse(dynamic responseData) {
    try {
      final decodedResponse = jsonDecode(
        responseData['RESPONSE']
      );
      final status = decodedResponse['ursh']?['status']
        ?.toString()
        .toUpperCase();
      final responseCode = decodedResponse['ursh']?['responseCode']
        ?.toString();
      
      return status == 'SUCCESS' && responseCode == '200';
    } catch (e) {
      return false;
    }
  }
}
```

#### 2. PanResponseParser

```dart
class PanResponseParser implements ResponseParser {
  @override
  bool parseOnlineResponse(dynamic responseData) {
    try {
      return responseData['status'] == 'SUCCESS' &&
             responseData['responseCode'] == '200';
    } catch (e) {
      return false;
    }
  }
  
  @override
  bool parseOfflineResponse(dynamic responseData) {
    try {
      final panValidation = responseData["PanValidation"];
      return responseData["Success"] == true &&
             panValidation != null &&
             panValidation['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
```

### Success/Error Callbacks

#### onSuccess Callback

Called when verification is successful. Receives the full API response.

```dart
onSuccess: (response) {
  // Extract data from response
  final data = response.data;
  
  // For PAN
  if (data['PanValidation'] != null) {
    String name = data['PanValidation']['name'];
    String category = data['PanValidation']['category'];
    print('PAN Holder: $name, Category: $category');
  }
  
  // For Voter ID
  if (data['data'] != null) {
    String name = data['data']['name'];
    String epicNo = data['data']['epicNo'];
    print('Voter: $name, EPIC: $epicNo');
  }
  
  // Store in database or state management
  saveVerificationResult(data);
  
  // Navigate to next screen
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => VerifiedScreen(data: data)
  ));
}
```

#### onError Callback

Called when verification fails. Receives error details.

```dart
onError: (error) {
  // Log error
  print('Verification error: $error');
  
  // Show error dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Verification Failed'),
      content: Text(error.toString()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Retry'),
        ),
      ],
    ),
  );
  
  // Analytics logging
  FirebaseAnalytics.instance.logEvent(
    name: 'verification_failed',
    parameters: {'error': error.toString()},
  );
}
```

### Response Data Extraction

#### Extract Voter ID Data

```dart
void extractVoterData(Response response) {
  final data = response.data['data'];
  
  String name = data['name'] ?? '';
  String epicNo = data['epicNo'] ?? '';
  String age = data['age'] ?? '';
  String gender = data['gender'] ?? '';
  String address = data['address'] ?? '';
  
  // Use extracted data
  print('Name: $name');
  print('EPIC: $epicNo');
}
```

#### Extract PAN Data

```dart
void extractPanData(Response response) {
  final panValidation = response.data['PanValidation'];
  
  String name = panValidation['name'] ?? '';
  String panNumber = panValidation['panNumber'] ?? '';
  String category = panValidation['category'] ?? '';
  bool isValid = panValidation['success'] ?? false;
  
  // Use extracted data
  if (isValid) {
    print('PAN Holder: $name');
    print('Category: $category');
  }
}
```

#### Extract Aadhaar Data

```dart
void extractAadhaarData(Response response) {
  final otpValidation = response.data['otpValidationNew'];
  final kycDetails = otpValidation['KycDetails'];
  
  String name = kycDetails['name'] ?? '';
  String dob = kycDetails['dob'] ?? '';
  String gender = kycDetails['gender'] ?? '';
  String aadhaarRefNum = otpValidation['aadharRefNum'] ?? '';
  String transactionId = otpValidation['TransactionId'] ?? '';
  
  // Store reference number for future use
  print('Aadhaar Ref: $aadhaarRefNum');
  print('Holder: $name');
}
```

---

## Error Handling

### Error Types

#### 1. Network Errors

```dart
try {
  final response = await handler.verify(...);
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    print('Connection timeout');
  } else if (e.type == DioExceptionType.receiveTimeout) {
    print('Receive timeout');
  } else if (e.type == DioExceptionType.connectionError) {
    print('No internet connection');
  }
  
  // Show user-friendly message
  showError('Please check your internet connection');
}
```

#### 2. Token Mismatch Errors

```dart
// Handled by TokenInterceptor
handler.reject(
  DioException(
    requestOptions: response.requestOptions,
    error: 'TokenMismatchException',
    message: 'Token does not match expected value',
  ),
);

// Catch in widget
onError: (error) {
  if (error.toString().contains('TokenMismatchException')) {
    showDialog(
      context: context,
      builder: (_) => SysmoAlert.failure(
        message: 'Security Error',
        detailMessage: 'Invalid token. Please try again.',
      ),
    );
  }
}
```

#### 3. Validation Errors

```dart
// Pattern validation
if (!AppConstant.panPattern.hasMatch(panNumber)) {
  return 'Invalid PAN format (e.g., ABCDE1234F)';
}

// Length validation
if (aadhaarNumber.length != 12) {
  return 'Aadhaar must be 12 digits';
}

// Custom validation
String? validatePan(AbstractControl control) {
  final value = control.value as String?;
  
  if (value == null || value.isEmpty) {
    return 'PAN is required';
  }
  
  if (!AppConstant.panPattern.hasMatch(value)) {
    return 'Invalid PAN format';
  }
  
  // Additional business logic validation
  if (value.startsWith('AAAAA')) {
    return 'Invalid PAN series';
  }
  
  return null;  // Valid
}
```

#### 4. API Response Errors

```dart
// Parse API error response
void handleApiError(Response response) {
  final data = response.data;
  
  if (data['ErrorCode'] != '000') {
    String errorMessage = data['ErrorStatus'] ?? 'Unknown error';
    String errorCode = data['ErrorCode'] ?? 'N/A';
    
    print('API Error: $errorMessage (Code: $errorCode)');
    
    // Map error codes to user-friendly messages
    final userMessage = mapErrorCode(errorCode);
    showError(userMessage);
  }
}

String mapErrorCode(String code) {
  switch (code) {
    case '001':
      return 'Invalid document number';
    case '002':
      return 'Document not found';
    case '003':
      return 'Service temporarily unavailable';
    default:
      return 'Verification failed. Please try again.';
  }
}
```

### Error Alert Widget

```dart
// Success alert
await showDialog(
  context: context,
  builder: (context) => Dialog(
    backgroundColor: Colors.transparent,
    child: SysmoAlert.success(
      message: 'Verification successful',
      onButtonPressed: () => Navigator.pop(context),
    ),
  ),
);

// Failure alert with details
await showDialog(
  context: context,
  builder: (context) => Dialog(
    backgroundColor: Colors.transparent,
    child: SysmoAlert.failure(
      message: 'Verification Failed',
      detailMessage: 'The PAN number you entered is invalid',
      viewButtonText: 'View Details',
      onButtonPressed: () => Navigator.pop(context),
    ),
  ),
);
```

### Graceful Degradation

```dart
// Fallback to offline mode if online fails
Future<Response> verifyWithFallback() async {
  try {
    // Try online first
    return await handler.verifyOnline(apiUrl, request: request);
  } catch (e) {
    print('Online verification failed, trying offline: $e');
    
    if (offlineAssetPath != null) {
      // Fallback to offline
      return await handler.verifyOffline(offlineAssetPath);
    }
    
    rethrow;  // No fallback available
  }
}
```

### Error Logging

```dart
void logError(String context, dynamic error, StackTrace? stackTrace) {
  // Console logging
  debugPrint('[$context] Error: $error');
  if (stackTrace != null) {
    debugPrint('Stack trace:\n$stackTrace');
  }
  
  // Firebase Crashlytics (if integrated)
  // FirebaseCrashlytics.instance.recordError(
  //   error,
  //   stackTrace,
  //   reason: context,
  // );
  
  // Custom analytics
  // analytics.logEvent(
  //   name: 'error_occurred',
  //   parameters: {
  //     'context': context,
  //     'error': error.toString(),
  //   },
  // );
}

// Usage
try {
  await verifyKyc();
} catch (e, stackTrace) {
  logError('PAN Verification', e, stackTrace);
  onError(e);
}
```

---

## Usage Examples

### Example 1: Basic PAN Verification

```dart
import 'package:flutter/material.dart';
import 'package:sysmo_verification/kyc_validation.dart';

class PanVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PAN Verification')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ReactiveFormBuilder(
          form: () => FormGroup({
            'panNumber': FormControl<String>(
              validators: [Validators.required],
            ),
          }),
          builder: (context, form, child) {
            return Column(
              children: [
                KYCTextBox(
                  formProps: FormProps(
                    formControlName: 'panNumber',
                    label: 'PAN Number',
                    mandatory: true,
                    maxLength: 10,
                  ),
                  styleProps: StyleProps(
                    textStyle: TextStyle(fontSize: 16),
                    borderRadius: 8,
                  ),
                  buttonProps: ButtonProps(
                    label: 'Verify PAN',
                    backgroundColor: Colors.blue,
                  ),
                  isOffline: false,
                  apiUrl: dotenv.env['pan_verification_endpoint'],
                  verificationType: VerificationType.pan,
                  validationPattern: AppConstant.panPattern,
                  validationPatternErrorMessage: 'Invalid PAN (Format: ABCDE1234F)',
                  onSuccess: (response) {
                    final data = response.data['PanValidation'];
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PAN verified: ${data['name']}')),
                    );
                  },
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Verification failed: $error')),
                    );
                  },
                  leadId: 'LEAD123',
                  token: 'YOUR_TOKEN',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

### Example 2: Aadhaar Verification with OTP

```dart
class AadhaarVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Aadhaar Verification')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ReactiveFormBuilder(
          form: () => FormGroup({
            'aadhaarNumber': FormControl<String>(
              validators: [
                Validators.required,
                Validators.minLength(12),
                Validators.maxLength(12),
              ],
            ),
          }),
          builder: (context, form, child) {
            return Column(
              children: [
                KYCTextBox(
                  formProps: FormProps(
                    formControlName: 'aadhaarNumber',
                    label: 'Aadhaar Number',
                    mandatory: true,
                    maxLength: 12,
                  ),
                  styleProps: StyleProps(
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  buttonProps: ButtonProps(
                    label: 'Verify Aadhaar',
                    backgroundColor: Color(0xFF009688),
                  ),
                  isOffline: false,
                  apiUrl: '',  // Not directly used for Aadhaar
                  verificationType: VerificationType.aadhaar,
                  validationPattern: AppConstant.aadhaarPattern,
                  validationPatternErrorMessage: 'Aadhaar must be 12 digits',
                  maskAadhaar: true,  // Enable masking
                  // Aadhaar-specific URLs
                  otpGendraassetApiurl: dotenv.env['aadhaar_otp_generate_endpoint'] ?? '',
                  aadhaarResponseApiurl: dotenv.env['aadhaar_otp_verify_endpoint'] ?? '',
                  aadharvaultApiurl: dotenv.env['aadhaar_vault_store_endpoint'] ?? '',
                  aadharvaultlookupapiurl: dotenv.env['aadhaar_vault_lookup_endpoint'] ?? '',
                  leadId: 'LEAD123',
                  token: 'YOUR_TOKEN',
                  onSuccess: (response) {
                    final kycDetails = response.data['otpValidationNew']['KycDetails'];
                    final refNum = response.data['otpValidationNew']['aadharRefNum'];
                    
                    print('Aadhaar verified: ${kycDetails['name']}');
                    print('Reference Number: $refNum');
                    
                    // Navigate to next screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SuccessScreen(
                          name: kycDetails['name'],
                          refNumber: refNum,
                        ),
                      ),
                    );
                  },
                  onError: (error) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Verification Failed'),
                        content: Text(error.toString()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

### Example 3: Offline Verification with Assets

```dart
class OfflineVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Offline Verification (Testing)')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ReactiveFormBuilder(
          form: () => FormGroup({
            'voterID': FormControl<String>(
              validators: [Validators.required],
            ),
          }),
          builder: (context, form, child) {
            return Column(
              children: [
                KYCTextBox(
                  formProps: FormProps(
                    formControlName: 'voterID',
                    label: 'Voter ID',
                    mandatory: true,
                    maxLength: 10,
                  ),
                  styleProps: StyleProps(),
                  buttonProps: ButtonProps(
                    label: 'Verify Voter ID',
                  ),
                  isOffline: true,  // Offline mode
                  assetPath: 'assets/mock_voter_response.json',  // Load from assets
                  verificationType: VerificationType.voter,
                  validationPattern: AppConstant.voterPattern,
                  validationPatternErrorMessage: 'Invalid Voter ID format',
                  onSuccess: (response) {
                    print('Offline verification success: $response');
                  },
                  onError: (error) {
                    print('Offline verification error: $error');
                  },
                  leadId: 'TEST_LEAD',
                  token: 'TEST_TOKEN',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Create asset file: assets/mock_voter_response.json
/*
{
  "status": "SUCCESS",
  "responseCode": "200",
  "data": {
    "name": "Test User",
    "epicNo": "ABC1234567",
    "age": "30",
    "gender": "Male"
  }
}
*/
```

### Example 4: Pre-Verified KYC Number

```dart
class PreVerifiedScreen extends StatelessWidget {
  final String? verifiedPan;
  
  PreVerifiedScreen({this.verifiedPan});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: ReactiveFormBuilder(
        form: () => FormGroup({
          'panNumber': FormControl<String>(),
        }),
        builder: (context, form, child) {
          return Column(
            children: [
              KYCTextBox(
                formProps: FormProps(
                  formControlName: 'panNumber',
                  label: 'PAN Number',
                ),
                styleProps: StyleProps(),
                buttonProps: ButtonProps(
                  label: 'Verify',
                ),
                isOffline: false,
                verificationType: VerificationType.pan,
                kycNumber: verifiedPan,  // Shows as verified if provided
                validationPattern: AppConstant.panPattern,
                onSuccess: (response) {},
                onError: (error) {},
                leadId: 'LEAD123',
                token: 'TOKEN',
              ),
            ],
          );
        },
      ),
    );
  }
}
```

### Example 5: Custom Styling

```dart
KYCTextBox(
  formProps: FormProps(
    formControlName: 'panNumber',
    label: 'PAN Number',
    mandatory: true,
  ),
  styleProps: StyleProps(
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
    borderRadius: 12,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    inputDecoration: InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
      prefixIcon: Icon(Icons.credit_card, color: Colors.blue),
      labelStyle: TextStyle(color: Colors.grey[700]),
    ),
  ),
  buttonProps: ButtonProps(
    label: 'Verify',
    backgroundColor: Colors.blue[800],
    foregroundColor: Colors.white,
    borderRadius: 12,
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
  ),
  // ... other props
)
```

---

## Testing

### Unit Testing

#### Test Response Parsers

```dart
// test/response_parser_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sysmo_verification/kyc_validation.dart';

void main() {
  group('PanResponseParser', () {
    late PanResponseParser parser;
    
    setUp(() {
      parser = PanResponseParser();
    });
    
    test('should return true for valid online response', () {
      final response = {
        'status': 'SUCCESS',
        'responseCode': '200',
        'PanValidation': {
          'success': true,
          'name': 'Test User',
        },
      };
      
      expect(parser.parseOnlineResponse(response), true);
    });
    
    test('should return false for invalid response', () {
      final response = {
        'status': 'FAILURE',
        'responseCode': '400',
      };
      
      expect(parser.parseOnlineResponse(response), false);
    });
    
    test('should handle null response gracefully', () {
      expect(parser.parseOnlineResponse(null), false);
    });
  });
  
  group('VoterResponseParser', () {
    late VoterResponseParser parser;
    
    setUp(() {
      parser = VoterResponseParser();
    });
    
    test('should parse offline response correctly', () {
      final response = {
        'RESPONSE': '{"ursh":{"status":"SUCCESS","responseCode":"200"}}'
      };
      
      expect(parser.parseOfflineResponse(response), true);
    });
  });
}
```

#### Test Verification Handlers

```dart
// test/verification_handler_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sysmo_verification/kyc_validation.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('PanVerificationHandler', () {
    late PanVerificationHandler handler;
    late MockApiClient mockApiClient;
    
    setUp(() {
      mockApiClient = MockApiClient();
      handler = PanVerificationHandler();
    });
    
    test('should call API with correct request', () async {
      final request = PanidRequest(pan: 'ABCDE1234F');
      
      when(mockApiClient.post(any, data: anyNamed('data')))
        .thenAnswer((_) async => Response(
          data: {'status': 'SUCCESS'},
          requestOptions: RequestOptions(path: ''),
        ));
      
      await handler.verifyOnline('https://api.test.com', request: request);
      
      verify(mockApiClient.post(any, data: request.toJson())).called(1);
    });
  });
}
```

### Widget Testing

```dart
// test/kyc_textbox_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sysmo_verification/kyc_validation.dart';

void main() {
  testWidgets('KYCTextBox displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReactiveFormBuilder(
            form: () => FormGroup({
              'pan': FormControl<String>(),
            }),
            builder: (context, form, child) {
              return KYCTextBox(
                formProps: FormProps(
                  formControlName: 'pan',
                  label: 'PAN Number',
                ),
                styleProps: StyleProps(),
                buttonProps: ButtonProps(label: 'Verify'),
                isOffline: true,
                assetPath: 'assets/mock.json',
                verificationType: VerificationType.pan,
                validationPattern: AppConstant.panPattern,
                onSuccess: (_) {},
                onError: (_) {},
                leadId: 'TEST',
                token: 'TOKEN',
              );
            },
          ),
        ),
      ),
    );
    
    // Verify label is displayed
    expect(find.text('PAN Number'), findsOneWidget);
    
    // Verify button is displayed
    expect(find.text('Verify'), findsOneWidget);
    
    // Enter text
    await tester.enterText(
      find.byType(ReactiveTextField<String>),
      'ABCDE1234F',
    );
    await tester.pump();
    
    // Tap verify button
    await tester.tap(find.text('Verify'));
    await tester.pump();
  });
}
```

### Integration Testing

```dart
// integration_test/kyc_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:your_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete PAN verification flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Navigate to KYC screen
    await tester.tap(find.text('Verify KYC'));
    await tester.pumpAndSettle();
    
    // Enter PAN number
    await tester.enterText(
      find.byType(TextField),
      'ABCDE1234F',
    );
    await tester.pumpAndSettle();
    
    // Tap verify button
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle(Duration(seconds: 5));
    
    // Verify success message
    expect(find.text('Verified ✓'), findsOneWidget);
  });
}
```

### Manual Testing Checklist

#### PAN Verification
- [ ] Valid PAN number accepts (e.g., ABCDE1234F)
- [ ] Invalid PAN shows error
- [ ] Empty input shows validation error
- [ ] Button shows loading state during API call
- [ ] Success state displays on verification
- [ ] Error state displays on failure
- [ ] Retry works after error

#### Aadhaar Verification
- [ ] Valid Aadhaar number accepts (12 digits)
- [ ] Masking works (8 masked + 4 visible)
- [ ] Consent form displays
- [ ] OTP generates successfully
- [ ] OTP bottom sheet displays
- [ ] 6-digit OTP validation works
- [ ] Resend OTP works with 30s timer
- [ ] Success state stores reference number
- [ ] Vault storage works (if configured)

#### Voter ID Verification
- [ ] Valid EPIC number accepts (e.g., ABC1234567)
- [ ] Invalid format shows error
- [ ] API response parsed correctly
- [ ] Success/error callbacks fire

#### Offline Mode
- [ ] Asset files load correctly
- [ ] Offline response parsing works
- [ ] No API calls made in offline mode

---

## Best Practices

### 1. Form State Management

```dart
// DO: Use FormGroup for complex forms
final form = FormGroup({
  'pan': FormControl<String>(validators: [Validators.required]),
  'aadhaar': FormControl<String>(validators: [Validators.required]),
  'voter': FormControl<String>(),
});

// DON'T: Manage state manually with TextEditingController
TextEditingController controller = TextEditingController();
```

### 2. Error Handling

```dart
// DO: Provide user-friendly error messages
onError: (error) {
  String userMessage;
  if (error.toString().contains('Network')) {
    userMessage = 'Please check your internet connection';
  } else {
    userMessage = 'Verification failed. Please try again.';
  }
  showDialog(...);
}

// DON'T: Show raw error to user
onError: (error) {
  print(error.toString());  // User doesn't see anything
}
```

### 3. Validation Patterns

```dart
// DO: Use predefined patterns from AppConstant
validationPattern: AppConstant.panPattern

// DO: Provide clear error messages
validationPatternErrorMessage: 'PAN format: ABCDE1234F (5 letters, 4 digits, 1 letter)'

// DON'T: Use unclear patterns
validationPattern: RegExp(r'^[A-Z0-9]+$')  // Too generic
```

### 4. API Configuration

```dart
// DO: Use environment variables
apiUrl: dotenv.env['pan_verification_endpoint']

// DO: Provide fallback
apiUrl: dotenv.env['pan_verification_endpoint'] ?? 'https://default-api.com'

// DON'T: Hardcode API URLs
apiUrl: 'https://api.production.com/verify'
```

### 5. Security

```dart
// DO: Store sensitive data securely
final prefs = await SharedPreferences.getInstance();
await prefs.setString('encrypted_token', encryptedToken);

// DO: Clear sensitive data after use
void dispose() {
  aadhaarNumber = '';
  otpValue = '';
  super.dispose();
}

// DON'T: Log sensitive data
print('Aadhaar: $aadhaarNumber');  // NEVER do this
```

### 6. State Management

```dart
// DO: Reset button state on input change
_handleInputChange(String value) {
  setState(() {
    _buttonStateManager.reset('Verify');
  });
}

// DO: Disable button during loading
onPressed: _buttonStateManager.isLoading ? null : _handleVerification

// DON'T: Allow multiple simultaneous verifications
onPressed: _handleVerification  // No loading check
```

### 7. Offline Development

```dart
// DO: Use offline mode for testing
KYCTextBox(
  isOffline: true,
  assetPath: 'assets/mock_responses/pan_success.json',
  // ...
)

// DO: Maintain realistic mock data
{
  "status": "SUCCESS",
  "responseCode": "200",
  "PanValidation": {
    "success": true,
    "name": "JOHN DOE",
    "category": "Individual"
  }
}
```

### 8. Widget Composition

```dart
// DO: Extract reusable configuration
final commonStyleProps = StyleProps(
  textStyle: TextStyle(fontSize: 16),
  borderRadius: 8,
);

// Use across multiple widgets
KYCTextBox(styleProps: commonStyleProps, ...)

// DON'T: Repeat configuration
KYCTextBox(
  styleProps: StyleProps(textStyle: TextStyle(fontSize: 16), ...),
)
KYCTextBox(
  styleProps: StyleProps(textStyle: TextStyle(fontSize: 16), ...),
)
```

### 9. Performance

```dart
// DO: Dispose controllers
@override
void dispose() {
  _maskedController.dispose();
  _aadhaarFocusNode.dispose();
  super.dispose();
}

// DO: Use const constructors
const StyleProps(borderRadius: 8)

// DON'T: Create new objects unnecessarily
StyleProps(borderRadius: 8)  // Without const
```

### 10. Accessibility

```dart
// DO: Provide semantic labels
Semantics(
  label: 'PAN number input field',
  child: KYCTextBox(...),
)

// DO: Support large text sizes
styleProps: StyleProps(
  textStyle: TextStyle(fontSize: 16).copyWith(
    fontSize: MediaQuery.of(context).textScaleFactor * 16,
  ),
)
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: Token Mismatch Error

**Symptom:** API calls fail with "Token does not match expected value"

**Causes:**
- Server not returning encrypted token
- Encryption key mismatch between client and server
- Token modified during transmission

**Solutions:**

```dart
// 1. Verify encryption key matches server
// In app_constant.dart
static const String encKey = 'sysarc@1234INFO@';  // Must match server

// 2. Check server response includes token
final response = {
  'data': {...},
  'token': 'encrypted_token_value'  // Required
};

// 3. Temporarily disable token validation for debugging
// In api_client.dart TokenInterceptor
if (decryptedResponseToken == expectedTokenValue) {
  handler.next(response);
} else {
  // Log for debugging
  print('Expected: $expectedTokenValue');
  print('Received: $decryptedResponseToken');
  
  // Uncomment to bypass (testing only)
  // handler.next(response);
  
  handler.reject(...);
}
```

#### Issue 2: Aadhaar OTP Not Received

**Symptom:** OTP generation succeeds but user doesn't receive OTP

**Causes:**
- Aadhaar number not linked to mobile
- Invalid mobile number in Aadhaar
- Network delay on telecom side

**Solutions:**

```dart
// 1. Extend timeout for OTP generation
await KYCService().verify(
  // ... other params
).timeout(Duration(seconds: 30));

// 2. Add retry mechanism
Future<void> generateOtpWithRetry({int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      await generateOtp();
      return;
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: 2));
    }
  }
}

// 3. Provide user instructions
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: Text('OTP Not Received?'),
    content: Text(
      'Please ensure:\n'
      '• Aadhaar is linked to mobile\n'
      '• Mobile has network coverage\n'
      '• Wait up to 5 minutes for OTP'
    ),
  ),
);
```

#### Issue 3: Validation Pattern Not Working

**Symptom:** Valid inputs shown as invalid

**Causes:**
- Incorrect regex pattern
- Extra whitespace in input
- Case sensitivity issues

**Solutions:**

```dart
// 1. Debug the pattern
print('Pattern: ${AppConstant.panPattern.pattern}');
print('Input: "$panNumber"');
print('Match: ${AppConstant.panPattern.hasMatch(panNumber)}');

// 2. Trim input
final trimmedInput = input.trim().toUpperCase();

// 3. Test pattern independently
void testPanPattern() {
  List<String> validPans = ['ABCDE1234F', 'XYZAB5678C'];
  List<String> invalidPans = ['ABC123', 'abcde1234f'];
  
  for (var pan in validPans) {
    assert(AppConstant.panPattern.hasMatch(pan), 'Valid PAN failed: $pan');
  }
  
  for (var pan in invalidPans) {
    assert(!AppConstant.panPattern.hasMatch(pan), 'Invalid PAN passed: $pan');
  }
}
```

#### Issue 4: Offline Mode Not Loading Assets

**Symptom:** "Failed to load offline data" error

**Causes:**
- Asset file not added to pubspec.yaml
- Incorrect asset path
- Invalid JSON in asset file

**Solutions:**

```yaml
# 1. Add assets to pubspec.yaml
flutter:
  assets:
    - assets/mock_responses/
    - assets/mock_responses/pan_success.json
    - assets/mock_responses/voter_success.json
```

```dart
// 2. Verify asset path
isOffline: true,
assetPath: 'assets/mock_responses/pan_success.json',  // Must start with 'assets/'

// 3. Validate JSON
// Run: flutter pub run json_validator assets/mock_responses/pan_success.json

// 4. Test asset loading manually
Future<void> testAssetLoading() async {
  try {
    final data = await rootBundle.loadString('assets/mock_responses/pan_success.json');
    print('Asset loaded: $data');
    final json = jsonDecode(data);
    print('JSON valid: $json');
  } catch (e) {
    print('Asset loading failed: $e');
  }
}
```

#### Issue 5: Button Stuck in Loading State

**Symptom:** Button shows spinner indefinitely

**Causes:**
- API timeout not handled
- Response parsing throws exception
- Missing setState() call

**Solutions:**

```dart
// 1. Add timeout to API calls
Future<Response> verifyWithTimeout() async {
  return await handler.verify(...).timeout(
    Duration(seconds: 30),
    onTimeout: () {
      throw TimeoutException('Verification timed out');
    },
  );
}

// 2. Ensure finally block resets state
Future<void> _handleVerification() async {
  setState(() {
    _buttonStateManager.setLoading();
  });
  
  try {
    final response = await verifyWithTimeout();
    // Handle success
  } catch (e) {
    // Handle error
  } finally {
    // Always reset loading state
    if (mounted) {
      setState(() {
        _buttonStateManager.stopLoading();
      });
    }
  }
}

// 3. Add safety timeout in button state
void setLoading() {
  _state = ButtonState.loading;
  _disabled = true;
  
  // Safety mechanism: reset after 60 seconds
  Future.delayed(Duration(seconds: 60), () {
    if (_state == ButtonState.loading) {
      setError('Request timeout');
    }
  });
}
```

#### Issue 6: Aadhaar Masking Not Working

**Symptom:** Full Aadhaar number always visible

**Causes:**
- maskAadhaar parameter not set
- Focus management issue

**Solutions:**

```dart
// 1. Enable masking
KYCTextBox(
  maskAadhaar: true,  // Must be true
  // ...
)

// 2. Check focus state
final displayValue = _isFocused
    ? actualValue  // Show full number when typing
    : _getMaskedAadhaar(actualValue);  // Mask when not focused

// 3. Implement masking helper
String _getMaskedAadhaar(String value) {
  if (value.length <= 4) {
    return value;
  }
  final visiblePart = value.substring(value.length - 4);
  final maskedPart = '*' * (value.length - 4);
  return maskedPart + visiblePart;
}
```

#### Issue 7: Environment Variables Not Loading

**Symptom:** API URLs are null or empty

**Causes:**
- .env file not created
- dotenv.load() not called
- Environment variable name mismatch

**Solutions:**

```dart
// 1. Verify .env file exists at project root
// .env
voter_verification_endpoint=https://api.example.com/voter
pan_verification_endpoint=https://api.example.com/pan

// 2. Load in main.dart before runApp
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
    print('Environment loaded successfully');
  } catch (e) {
    print('Error loading .env: $e');
  }
  
  runApp(MyApp());
}

// 3. Add .env to pubspec.yaml assets
flutter:
  assets:
    - .env

// 4. Use fallback values
final apiUrl = dotenv.env['pan_verification_endpoint'] 
    ?? 'https://default-api.com/pan';
```

---

## Future Enhancements

### Planned Features

1. **Biometric Verification**
   - Fingerprint verification for Aadhaar
   - Face recognition support
   - Iris scanning integration

2. **Additional Document Types**
   - Driving License
   - Ration Card
   - Bank Account verification
   - Utility bill verification

3. **Enhanced Security**
   - Certificate pinning
   - Multi-factor authentication
   - Biometric authentication for sensitive operations
   - Secure enclave storage for tokens

4. **Improved UI/UX**
   - Dark mode support
   - Animations and transitions
   - Custom themes
   - Accessibility improvements

5. **Analytics & Monitoring**
   - Firebase Analytics integration
   - Crashlytics integration
   - Performance monitoring
   - User behavior tracking

6. **Internationalization**
   - Multi-language support
   - Regional format support
   - Localized error messages

7. **Offline Capabilities**
   - Local caching of verified documents
   - Sync when online
   - Offline-first architecture

8. **Developer Tools**
   - Debug mode with detailed logs
   - Mock API responses for testing
   - Visual verification flow debugger

### Contribution Guidelines

To contribute to this package:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Follow coding standards**
   - Use consistent naming conventions
   - Add comments for complex logic
   - Write unit tests for new features

4. **Submit Pull Request**
   - Provide clear description
   - Include test coverage
   - Update documentation

5. **Code Review**
   - Address review comments
   - Ensure CI/CD passes

### Roadmap

| Version | Features | Timeline |
|---------|----------|----------|
| 0.1.0 | Current stable version | Released |
| 0.2.0 | Driving License, Dark mode | Q2 2025 |
| 0.3.0 | Biometric verification | Q3 2025 |
| 1.0.0 | Production-ready, Full documentation | Q4 2025 |

---

## Support & Contact

### Resources

- **GitHub Repository**: [Sysmo Verification](https://github.com/gayathribalraj/Sysmo_Verification)
- **Issue Tracker**: [GitHub Issues](https://github.com/gayathribalraj/Sysmo_Verification/issues)
- **Documentation**: [README.md](https://github.com/gayathribalraj/Sysmo_Verification/blob/main/README.md)

### Getting Help

1. **Check Documentation First** - Most questions are answered here
2. **Search Existing Issues** - Someone may have had the same problem
3. **Create New Issue** - Provide details:
   - Flutter version
   - Package version
   - Steps to reproduce
   - Expected vs actual behavior
   - Error logs/screenshots

### Reporting Bugs

When reporting bugs, include:

```
**Environment:**
- Package version: 0.0.17
- Flutter version: 3.8.1
- Platform: Android/iOS
- Device: Pixel 5 / iPhone 12

**Description:**
Clear description of the bug

**Steps to Reproduce:**
1. Go to '...'
2. Click on '....'
3. See error

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**Logs:**
```
[Copy error logs here]
```

**Screenshots:**
[If applicable]
```

---

## License

This project is licensed under the MIT License.

```
MIT License

Copyright (c) 2024 Gayathri Balraj

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Changelog

### Version 0.0.17 (Current)
- Initial public release
- Support for 5 verification types (Aadhaar, PAN, Voter ID, GST, Passport)
- Online and offline verification modes
- AES encryption with OpenSSL compatibility
- Reactive forms integration
- OTP support for Aadhaar
- Aadhaar vault integration
- Customizable UI components
- Token-based security

### Version 0.0.16
- Bug fixes in token validation
- Improved error handling
- Enhanced OTP flow

### Version 0.0.15
- Added Aadhaar masking feature
- Fixed encryption issues
- Performance improvements

---

## Acknowledgments

- **Flutter Team** - For the amazing framework
- **Dio Package** - For HTTP client capabilities
- **Reactive Forms** - For form management
- **Contributors** - For their valuable contributions

---

## Appendix

### A. Validation Patterns

```dart
class AppConstant {
  // PAN: 5 letters, 4 digits, 1 letter (e.g., ABCDE1234F)
  static final RegExp panPattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
  
  // GST: 2 digits, 5 letters, 4 digits, 1 letter, 1 alphanumeric, Z, 1 alphanumeric
  static final RegExp gstPattern = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
  );
  
  // Voter ID: 3 letters, 7 digits (e.g., ABC1234567)
  static final RegExp voterPattern = RegExp(r'^[A-Z]{3}\d{7}$');
  
  // Passport: 1 letter, 1-9, 6 digits (e.g., A1234567)
  static final RegExp passportPattern = RegExp(r'^[A-Z][1-9][0-9]{6}$');
  
  // Aadhaar: 12 digits
  static final RegExp aadhaarPattern = RegExp('[0-9]{12}');
  
  // Encryption key (16 characters)
  static const String encKey = 'sysarc@1234INFO@';
}
```

### B. API Response Codes

| Code | Meaning | Action |
|------|---------|--------|
| 000 | Success | Proceed |
| 001 | Invalid document | Show error |
| 002 | Document not found | Retry or contact support |
| 003 | Service unavailable | Retry later |
| 200 | HTTP Success | Parse response |
| 400 | Bad request | Check request format |
| 401 | Unauthorized | Check API credentials |
| 500 | Server error | Retry or contact support |

### C. String Constants

```dart
class ConstantVariable {
  // Response status
  static const String status = "status";
  static const String camelSuccess = "SUCCESS";
  static const String lowerSuccess = "success";
  static const String responseCode = "responseCode";
  static const String statusCode200 = "200";
  static const String statusCode101 = "101";
  static const String responseData = "responseData";
  
  // Messages
  static const String verifiedSuccessfullyString = "Verified Successfully";
  static const String verificationFaildString = "Verification Failed";
  static const String verifiedString = "Verified";
  static const String verifyString = "Verify";
  static const String failedString = "Failed";
  
  // OTP
  static const String otpString = "OTP";
  static const String verifyOTPString = "Verify OTP";
  static const String consentOTPSendSuccessfullyString = "OTP Send Successfully!!!";
  static const String consentOTPGendrateFailedString = "OTP Generate failed!!!";
  
  // Errors
  static const String noDataProviderString = 
      "No valid data source provided for verification";
  static const String offlineHandlerloadString = 
      "Failed to load offline data from";
}
```

---

**Document Version:** 1.0  
**Last Updated:** March 19, 2026  
**Prepared By:** GitHub Copilot  
**For:** Sysmo Verification Team

---

*End of Knowledge Transfer Documentation*
