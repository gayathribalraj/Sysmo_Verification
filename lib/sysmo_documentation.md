# Sysmo Verification - Technical Documentation
**Version:** 0.0.18  
**Author:** Gayathri  
**Last Updated:** March 25, 2026

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Core Components](#core-components)
3. [Features](#features)
4. [Security Features](#security-features)
5. [API Reference](#api-reference)
6. [Implementation Guide](#implementation-guide)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

### Design Philosophy

Sysmo Verification follows a **modular, factory-pattern architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────┐
│              KYCTextBox Widget (UI Layer)           │
│  - User interaction                                 │
│  - Input field & verify button                      │
│  - State management                                 │
└──────────────────────┬──────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
┌───────▼────────┐          ┌─────────▼──────────┐
│ KYCInputField  │          │  VerifyButton      │
│ - Reactive form│          │  - Button states   │
│ - Masking      │          │  - Visual feedback │
│ - Validation   │          └────────────────────┘
└────────────────┘
        │
┌───────▼──────────────────────────────────────────┐
│        Core Components (Business Logic)          │
│                                                   │
│  ┌──────────────────┐  ┌────────────────────┐   │
│  │VerificationHandler│  │ ResponseParser     │   │
│  │ Factory Pattern   │  │ Factory Pattern    │   │
│  └──────────────────┘  └────────────────────┘   │
│                                                   │
│  ┌──────────────────┐  ┌────────────────────┐   │
│  │ButtonStateManager│  │InputValidationMgr  │   │
│  └──────────────────┘  └────────────────────┘   │
└───────────────────────────────────────────────────┘
        │
┌───────▼──────────────────────────────────────────┐
│         API Layer (Network/Storage)              │
│                                                   │
│  ┌──────────────┐       ┌────────────────────┐  │
│  │  ApiClient   │       │OfflineVerification │  │
│  │   (Dio)      │       │   Handler          │  │
│  └──────────────┘       └────────────────────┘  │
└───────────────────────────────────────────────────┘
```

### Directory Structure

```
lib/
├── kyc_validation.dart              # Main export file
├── main.dart                         # Example implementation
├── sysmo_documentation.md            # This file
│
└── src/
    ├── core/                         # Business logic & state
    │   ├── enums_and_state.dart      # Enums, state managers
    │   ├── response_parsers.dart     # API response parsing
    │   ├── verification_handlers.dart # Verification logic
    │   └── api/                      # Network layer
    │       ├── api_client.dart       # Dio HTTP client
    │       ├── api_config.dart       # Endpoint configuration
    │       ├── app_constant.dart     # App constants
    │       ├── constant_variable.dart # String constants
    │       └── offline_verification_handler.dart
    │
    ├── Utils/                        # Utilities
    │   ├── aes_utils.dart            # Encryption utilities
    │   └── service.dart              # Helper services
    │
    └── widget/                       # UI Components
        ├── kyc_verification.dart     # Verification mixin
        └── uiwidgetprops/            # Widget properties
            ├── button_props.dart     # Button configuration
            ├── consent_form.dart     # Aadhaar consent UI
            ├── form_props.dart       # Form field config
            ├── kyc_input_field.dart  # Input field widget
            ├── kyc_verification_widget.dart # Main widget
            ├── kyc_wrapper_class.dart
            ├── otp_sheet.dart        # OTP input UI
            ├── pan_request.dart      # PAN request model
            ├── style_props.dart      # Style configuration
            ├── sysmo_alert.dart      # Alert dialogs
            ├── verify_button.dart    # Verify button widget
            └── voterid_request.dart  # Voter ID request model
```

---

## Core Components

### 1. Verification Types (Enums)

```dart
enum VerificationType {
  voter,      // Voter ID verification
  aadhaar,    // Aadhaar with OTP
  pan,        // PAN card
  gst,        // GST number
  passport    // Passport number
}
```

### 2. State Management

#### ButtonStateManager

Manages the verify button's visual and interactive states:

```dart
class ButtonStateManager {
  ButtonState _state;    // idle, loading, success, error
  String _text;          // Button display text
  bool _disabled;        // Enable/disable state
  
  // State checks
  bool get isLoading;
  bool get isSuccess;
  bool get isError;
  bool get isDisabled;
  
  // State transitions
  void initialize(String initialText);
  void setLoading();
  void setSuccess(String successText);
  void setError(String errorText);
  void reset(String defaultText);
  
  // UI color based on state
  Color getBackgroundColor({
    Color? idleColor,
    Color? loadingColor,
    Color? successColor,
    Color? errorColor,
  });
}
```

**State Flow:**
```
idle → loading → success ✓
  ↑       ↓
  └──── error → reset
```

#### InputValidationManager

Manages input field validation state:

```dart
class InputValidationManager {
  bool _isValid;
  List<RegExp> _patterns;
  
  bool get isValid;
  void addPattern(RegExp pattern);
  void validate(String value);
}
```

### 3. Verification Handler (Factory Pattern)

Abstract handler with concrete implementations for each verification type:

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

// Factory creates appropriate handler
class VerificationHandlerFactory {
  static VerificationHandler create(VerificationType type) {
    return switch (type) {
      VerificationType.voter => VoterVerificationHandler(),
      VerificationType.pan => PanVerificationHandler(),
      VerificationType.gst => GstVerificationHandler(),
      VerificationType.passport => PassportVerificationHandler(),
      VerificationType.aadhaar => AadhaarVerificationHandler(),
    };
  }
}
```

**Implementations:**
- `VoterVerificationHandler`
- `PanVerificationHandler`
- `GstVerificationHandler`
- `PassportVerificationHandler`
- `AadhaarVerificationHandler`

### 4. Response Parser (Factory Pattern)

Parses API responses for different verification types:

```dart
abstract class ResponseParser {
  bool parseOnlineResponse(dynamic data);
  bool parseOfflineResponse(dynamic data);
}

class ResponseParserFactory {
  static ResponseParser create(VerificationType type);
}
```

---

## Features

### 1. Multi-Document Verification

Supports 5 document types with type-specific validation:

| Document | Pattern | Length | Format Example |
|----------|---------|--------|----------------|
| **Aadhaar** | `^\d{12}$` | 12 digits | `123456789012` |
| **PAN** | `^[A-Z]{5}[0-9]{4}[A-Z]$` | 10 chars | `ABCDE1234F` |
| **Voter ID** | `^[A-Z]{3}\d{7}$` | 10 chars | `ABC1234567` |
| **GST** | `^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$` | 15 chars | `22ABCDE1234F1Z5` |
| **Passport** | `^[A-Z][1-9][0-9]{6}$` | 8 chars | `A1234567` |

### 2. Reactive Forms Integration

Built on **reactive_forms** for powerful form management:

```dart
ReactiveFormBuilder(
  form: () => FormGroup({
    'panNumber': FormControl<String>(
      validators: [Validators.required],
    ),
  }),
  builder: (context, form, child) {
    return KYCTextBox(
      formProps: FormProps(
        formControlName: 'panNumber',
        label: 'PAN Number',
        mandatory: true,
      ),
      // ... other props
    );
  },
)
```

### 3. Online & Offline Modes

#### Online Mode (Production)
```dart
isOffline: false,
apiUrl: 'https://api.example.com/verify/pan',
token: 'your-auth-token',
```

#### Offline Mode (Testing/Development)
```dart
isOffline: true,
assetPath: 'assets/mock_data/pan_response.json',
```

### 4. Aadhaar OTP Verification Flow

Aadhaar verification follows a multi-step process:

```
1. User enters Aadhaar number
          ↓
2. Show consent form (user agreement)
          ↓
3. Select verification method (OTP/Biometric)
          ↓
4. Generate OTP → Send to registered mobile
          ↓
5. User enters OTP
          ↓
6. Validate OTP with API
          ↓
7. Retrieve Aadhaar reference number
   - Check OTP response
   - If not present → Vault Lookup
   - If still not found → Create Vault Entry
          ↓
8. Success → Return verification data
```

**API Endpoints Required:**
- OTP Generation: `otpGendraassetApiurl`
- OTP Validation: `aadhaarResponseApiurl`
- Vault Registration: `aadharvaultApiurl`
- Vault Lookup: `aadharvaultlookupapiurl`

---

## Security Features

### 1. Aadhaar Masking (`maskAadhaar`)

**Purpose:** Protect Aadhaar numbers from shoulder surfing and screenshots.

**Behavior:**
- **When NOT Focused:** Displays masked pattern (e.g., `********1234`)
- **When Focused:** Shows full number for editing
- **Masking Pattern:** First 8 digits as `*`, last 4 digits visible

**Implementation:**
```dart
KYCTextBox(
  maskAadhaar: true,  // Enable masking
  verificationType: VerificationType.aadhaar,
  // ... other props
)
```

**Technical Details:**
- Uses `Stack` widget with `Opacity` to switch between masked and full views
- Masked display uses read-only `TextField`
- Actual input uses `ReactiveTextField` with `inputFormatters`
- Focus state (`_isFocused`) triggers view switching

**Code Structure:**
```dart
Stack(
  children: [
    // Actual input (visible when focused)
    Opacity(
      opacity: _isFocused ? 1.0 : 0.0,
      child: ReactiveTextField(/* ... */),
    ),
    
    // Masked display (visible when NOT focused)
    if (!_isFocused)
      TextField(
        controller: TextEditingController(
          text: _getMaskedAadhaar(actualValue)
        ),
        readOnly: true,
      ),
  ],
)
```

**Masking Function:**
```dart
String _getMaskedAadhaar(String value) {
  if (value.isEmpty) return '';
  if (value.length <= 4) return value;
  
  final visiblePart = value.substring(value.length - 4);
  final maskedLength = value.length - 4;
  return '${'*' * maskedLength}$visiblePart';
}
```

### 2. Obscure Text (`obscureText`)

**Purpose:** Hide input characters (like password fields) with toggle visibility.

**Features:**
- Replaces characters with dots (`•••`)
- Eye icon toggle to show/hide
- Works with all verification types
- Can be combined with `maskAadhaar`

**Implementation:**
```dart
KYCTextBox(
  obscureText: true,  // Enable obscure mode
  // ... other props
)
```

**Toggle Functionality:**
```dart
IconButton(
  icon: Icon(
    _isObscured ? Icons.visibility_off : Icons.visibility,
    color: Colors.grey,
  ),
  onPressed: _toggleObscure,
)
```

### 3. Combined Security: `maskAadhaar` + `obscureText`

**Most Secure Configuration:**
```dart
KYCTextBox(
  obscureText: true,
  maskAadhaar: true,
  verificationType: VerificationType.aadhaar,
  // ... other props
)
```

**Behavior Table:**

| State | maskAadhaar | obscureText | Not Focused | Focused | Toggle Icon |
|-------|-------------|-------------|-------------|---------|-------------|
| **Default** | `false` | `false` | `123456789012` | `123456789012` | ❌ |
| **Masked Only** | `true` | `false` | `********1234` | `123456789012` | ❌ |
| **Obscured Only** | `false` | `true` | `••••••••••••` | `••••••••••••` | ✅ |
| **Both** | `true` | `true` | `********••••` | `••••••••••••` | ✅ |

**With Toggle (Click Eye Icon):**
```
Visibility OFF: ********••••
Visibility ON:  ********1234
```

---

## API Reference

### KYCTextBox Widget

Main widget for KYC verification.

```dart
class KYCTextBox extends StatefulWidget {
  const KYCTextBox({
    // Form Configuration
    required FormProps formProps,
    required StyleProps styleProps,
    required ButtonProps buttonProps,
    
    // Verification Type
    required VerificationType verificationType,
    
    // Online/Offline Mode
    required bool isOffline,
    String? apiUrl,
    String? assetPath,
    
    // Authentication
    required String token,
    required String leadId,
    
    // Aadhaar-specific APIs
    required String otpGendraassetApiurl,
    String? otpGendrateassetPath,
    required String aadhaarResponseApiurl,
    required String aadhaarResponseassetspath,
    required String aadharvaultApiurl,
    required String aadharvaultassetpath,
    required String aadharvaultlookupapiurl,
    required String aadharvaultlookupassetpath,
    
    // Callbacks
    required ValueChanged<dynamic> onSuccess,
    required ValueChanged<dynamic> onError,
    
    // Optional Features
    String? kycNumber,              // Pre-filled value
    bool showVerifyButton = false,
    RegExp? validationPattern,
    String? validationPatternErrorMessage,
    ReactiveFormFieldCallback<String>? onChange,
    bool obscureText = false,       // NEW: Hide input
    bool maskAadhaar = false,       // NEW: Mask Aadhaar
    List<String>? usedAadhaarRefNumbers,
    Key? fieldKey,
  });
}
```

### FormProps

```dart
class FormProps {
  final String formControlName;    // Reactive form control name
  final String label;              // Input field label
  final String? hint;              // Placeholder text
  final bool mandatory;            // Show asterisk (*)
  final int? maxLength;            // Character limit
  final ValidationFunction? validator;  // Custom validator
  
  const FormProps({
    required this.formControlName,
    required this.label,
    this.hint,
    this.mandatory = false,
    this.maxLength,
    this.validator,
  });
}
```

### ButtonProps

```dart
class ButtonProps {
  final String label;              // Button text
  final VoidCallback? onPressed;   // Callback (usually null)
  final Color? backgroundColor;    // Button background
  final Color? foregroundColor;    // Text/icon color
  final double borderRadius;       // Corner radius (default: 8.0)
  final EdgeInsetsGeometry? padding;
  final bool disabled;             // Disable button
  
  const ButtonProps({
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 8.0,
    this.padding,
    this.disabled = false,
  });
}
```

### StyleProps

```dart
class StyleProps {
  final double borderRadius;       // Input border radius (default: 8)
  final TextStyle? textStyle;      // Input text style
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final InputDecoration? inputDecoration;  // Custom decoration
  final CrossAxisAlignment? crossAxisAlignment;
  
  const StyleProps({
    this.borderRadius = 8,
    this.textStyle,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.inputDecoration,
    this.crossAxisAlignment,
  });
}
```

---

## Implementation Guide

### Basic PAN Verification

```dart
import 'package:flutter/material.dart';
import 'package:sysmo_verification/kyc_validation.dart';

class PANVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PAN Verification')),
      body: ReactiveFormBuilder(
        form: () => FormGroup({
          'panNumber': FormControl<String>(
            validators: [Validators.required],
          ),
        }),
        builder: (context, form, child) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: KYCTextBox(
              formProps: FormProps(
                formControlName: 'panNumber',
                label: 'PAN Number',
                mandatory: true,
                maxLength: 10,
              ),
              styleProps: StyleProps(),
              buttonProps: ButtonProps(
                label: 'Verify',
                foregroundColor: Colors.white,
              ),
              verificationType: VerificationType.pan,
              validationPattern: RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$'),
              validationPatternErrorMessage: 'Enter valid PAN',
              isOffline: false,
              apiUrl: 'https://api.example.com/verify/pan',
              token: 'your-token',
              leadId: 'lead-123',
              
              // Aadhaar fields (empty for PAN)
              otpGendraassetApiurl: '',
              aadhaarResponseApiurl: '',
              aadharvaultApiurl: '',
              aadharvaultlookupapiurl: '',
              aadhaarResponseassetspath: '',
              aadharvaultassetpath: '',
              aadharvaultlookupassetpath: '',
              
              onSuccess: (response) {
                print('Success: ${response.data}');
              },
              onError: (error) {
                print('Error: $error');
              },
            ),
          );
        },
      ),
    );
  }
}
```

### Secure Aadhaar Verification (with Masking)

```dart
KYCTextBox(
  formProps: FormProps(
    formControlName: 'aadhaarNumber',
    label: 'Aadhaar Number',
    mandatory: true,
    maxLength: 12,
  ),
  styleProps: StyleProps(),
  buttonProps: ButtonProps(
    label: 'Verify with OTP',
    foregroundColor: Colors.white,
  ),
  verificationType: VerificationType.aadhaar,
  validationPattern: RegExp(r'^\d{12}$'),
  validationPatternErrorMessage: 'Enter 12-digit Aadhaar',
  
  // Security features
  maskAadhaar: true,       // Mask first 8 digits
  obscureText: true,       // Hide with dots + toggle
  
  // Online mode
  isOffline: false,
  apiUrl: 'https://api.example.com/aadhaar/verify',
  token: 'your-token',
  leadId: 'lead-123',
  
  // Aadhaar-specific APIs
  otpGendraassetApiurl: 'https://api.example.com/aadhaar/generate-otp',
  aadhaarResponseApiurl: 'https://api.example.com/aadhaar/verify-otp',
  aadharvaultApiurl: 'https://api.example.com/aadhaar/vault',
  aadharvaultlookupapiurl: 'https://api.example.com/aadhaar/vault-lookup',
  
  // Asset paths (empty for online)
  aadhaarResponseassetspath: '',
  aadharvaultassetpath: '',
  aadharvaultlookupassetpath: '',
  
  onSuccess: (response) {
    final aadhaarRefNum = response.data['aadhaarRefNumber'];
    print('Aadhaar verified. Ref: $aadhaarRefNum');
  },
  onError: (error) {
    print('Verification failed: $error');
  },
)
```

### Offline Testing Mode

```dart
KYCTextBox(
  formProps: FormProps(
    formControlName: 'voterId',
    label: 'Voter ID',
    mandatory: true,
  ),
  styleProps: StyleProps(),
  buttonProps: ButtonProps(label: 'Verify'),
  verificationType: VerificationType.voter,
  validationPattern: RegExp(r'^[A-Z]{3}\d{7}$'),
  
  // Offline mode
  isOffline: true,
  assetPath: 'assets/mock/voter_response.json',
  
  // Empty fields for offline
  apiUrl: '',
  token: '',
  leadId: '',
  otpGendraassetApiurl: '',
  aadhaarResponseApiurl: '',
  aadharvaultApiurl: '',
  aadharvaultlookupapiurl: '',
  aadhaarResponseassetspath: '',
  aadharvaultassetpath: '',
  aadharvaultlookupassetpath: '',
  
  onSuccess: (response) => print('Mock success'),
  onError: (error) => print('Mock error'),
)
```

### Custom Styling

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
    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    inputDecoration: InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blueAccent, width: 2),
      ),
    ),
  ),
  buttonProps: ButtonProps(
    label: 'Verify Now',
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    borderRadius: 12,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  ),
  // ... other props
)
```

---

## Best Practices

### 1. Security

✅ **DO:**
- Enable `maskAadhaar` for Aadhaar verification
- Use `obscureText` for sensitive document numbers
- Store tokens securely (never hardcode)
- Use HTTPS for all API endpoints
- Implement proper error handling

❌ **DON'T:**
- Log sensitive data (Aadhaar, PAN numbers)
- Store verification responses in plain text
- Reuse tokens across environments

### 2. Form Management

✅ **DO:**
```dart
// Wrap in ReactiveFormBuilder
ReactiveFormBuilder(
  form: () => FormGroup({
    'aadhaar': FormControl<String>(
      validators: [
        Validators.required,
        Validators.pattern(r'^\d{12}$'),
      ],
    ),
  }),
  builder: (context, form, child) {
    // Your KYCTextBox here
  },
)
```

❌ **DON'T:**
```dart
// Using KYCTextBox outside ReactiveFormBuilder
KYCTextBox(/* ... */)  // Will throw error!
```

### 3. Error Handling

```dart
onError: (error) {
  if (error.toString().contains('Network')) {
    // Show network error dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Connection Error'),
        content: Text('Please check your internet connection'),
      ),
    );
  } else if (error.toString().contains('Invalid')) {
    // Show validation error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invalid document number')),
    );
  } else {
    // Generic error
    print('Verification error: $error');
  }
}
```

### 4. Testing Strategy

**Development Phase:**
```dart
isOffline: true,
assetPath: 'assets/mock/success_response.json',
```

**Staging Phase:**
```dart
isOffline: false,
apiUrl: 'https://staging-api.example.com/verify',
```

**Production Phase:**
```dart
isOffline: false,
apiUrl: 'https://api.example.com/verify',
```

### 5. Performance

- **Debounce input:** Add delay before validation
- **Cache responses:** Store successful verifications
- **Lazy load:** Initialize handlers only when needed
- **Dispose properly:** Clean up controllers and focus nodes

---

## Troubleshooting

### Issue: "FormControl not found"

**Problem:** KYCTextBox used outside ReactiveFormBuilder

**Solution:**
```dart
// Wrap your widget tree
ReactiveFormBuilder(
  form: () => FormGroup({
    'yourControlName': FormControl<String>(),
  }),
  builder: (context, form, child) {
    return KYCTextBox(
      formProps: FormProps(
        formControlName: 'yourControlName',  // Must match!
        // ...
      ),
    );
  },
)
```

### Issue: Masking not working

**Problem:** `maskAadhaar` not showing masked pattern

**Checklist:**
1. Ensure `maskAadhaar: true` is set
2. Check `verificationType` is set
3. Field must lose focus to show masking
4. If `obscureText: true`, masking is overridden

**Solution:**
```dart
KYCTextBox(
  maskAadhaar: true,
  obscureText: false,  // Or true for both features
  verificationType: VerificationType.aadhaar,
  // ...
)
```

### Issue: OTP not received for Aadhaar

**Problem:** Aadhaar OTP verification failing

**Checklist:**
1. Verify API endpoint is correct: `otpGendraassetApiurl`
2. Check network connectivity
3. Ensure valid Aadhaar number (12 digits)
4. Verify token is not expired
5. Check API logs for detailed error

**Debug:**
```dart
onError: (error) {
  print('Aadhaar Error: $error');
  print('Token: $token');
  print('Lead ID: $leadId');
}
```

### Issue: Validation pattern not working

**Problem:** Custom validation pattern not triggering

**Solution:**
```dart
KYCTextBox(
  validationPattern: RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$'),
  validationPatternErrorMessage: 'Enter valid PAN',  // Must provide message!
  // ...
)
```

### Issue: Button stays disabled

**Problem:** Verify button remains disabled

**Possible causes:**
1. Form validation failing
2. Input doesn't match validation pattern
3. Button state stuck in error/success

**Solution:**
```dart
// Reset button state on input change
onChange: (control) {
  print('Input changed: ${control.value}');
  print('Is valid: ${control.valid}');
}
```

---

## Changelog

### Version 0.0.18 (Latest)

**New Features:**
- ✨ Added `obscureText` property for password-like input hiding
- ✨ Added `maskAadhaar` property for Aadhaar number masking
- ✨ Combined security: both features can work together
- ✨ Visibility toggle icon for obscured text

**Improvements:**
- 🔒 Enhanced Aadhaar security with dual-layer protection
- 🎨 Improved focus/blur state handling in masked fields
- 📱 Better UX with visual feedback for sensitive data

**Technical:**
- Refactored `KYCInputField` to support masking and obscuring
- Added `_buildMaskedAadhaarField()` method with Stack-based UI
- Implemented `_getMaskedAadhaar()` for pattern masking
- Added `_toggleObscure()` for visibility control

---

## Support & Contributing

**Documentation:** [README.md](../README.md)  
**Repository:** [GitHub](https://github.com/gayathribalraj/Sysmo_Verification)  
**Issues:** Report bugs on GitHub Issues  
**License:** MIT

---

## Appendix: Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:sysmo_verification/kyc_validation.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sysmo Verification Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: VerificationDemo(),
    );
  }
}

class VerificationDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('KYC Verification')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: ReactiveFormBuilder(
          form: () => FormGroup({
            'aadhaar': FormControl<String>(
              validators: [Validators.required],
            ),
            'pan': FormControl<String>(
              validators: [Validators.required],
            ),
          }),
          builder: (context, form, child) {
            return Column(
              children: [
                // Aadhaar with masking
                KYCTextBox(
                  formProps: FormProps(
                    formControlName: 'aadhaar',
                    label: 'Aadhaar Number',
                    mandatory: true,
                    maxLength: 12,
                  ),
                  styleProps: StyleProps(),
                  buttonProps: ButtonProps(
                    label: 'Verify Aadhaar',
                    foregroundColor: Colors.white,
                  ),
                  verificationType: VerificationType.aadhaar,
                  validationPattern: RegExp(r'^\d{12}$'),
                  validationPatternErrorMessage: 'Enter 12 digits',
                  maskAadhaar: true,
                  obscureText: true,
                  isOffline: true,
                  assetPath: 'assets/mock/aadhaar_response.json',
                  apiUrl: '',
                  token: '',
                  leadId: '',
                  otpGendraassetApiurl: '',
                  aadhaarResponseApiurl: '',
                  aadharvaultApiurl: '',
                  aadharvaultlookupapiurl: '',
                  aadhaarResponseassetspath: '',
                  aadharvaultassetpath: '',
                  aadharvaultlookupassetpath: '',
                  onSuccess: (response) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Aadhaar Verified!')),
                    );
                  },
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $error')),
                    );
                  },
                ),
                
                SizedBox(height: 24),
                
                // PAN verification
                KYCTextBox(
                  formProps: FormProps(
                    formControlName: 'pan',
                    label: 'PAN Number',
                    mandatory: true,
                    maxLength: 10,
                  ),
                  styleProps: StyleProps(),
                  buttonProps: ButtonProps(
                    label: 'Verify PAN',
                    foregroundColor: Colors.white,
                  ),
                  verificationType: VerificationType.pan,
                  validationPattern: RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$'),
                  validationPatternErrorMessage: 'Enter valid PAN',
                  isOffline: true,
                  assetPath: 'assets/mock/pan_response.json',
                  apiUrl: '',
                  token: '',
                  leadId: '',
                  otpGendraassetApiurl: '',
                  aadhaarResponseApiurl: '',
                  aadharvaultApiurl: '',
                  aadharvaultlookupapiurl: '',
                  aadhaarResponseassetspath: '',
                  aadharvaultassetpath: '',
                  aadharvaultlookupassetpath: '',
                  onSuccess: (response) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PAN Verified!')),
                    );
                  },
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $error')),
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

---

*End of Documentation*
