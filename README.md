# Sysmo Verification 🔐

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/gayathribalraj/Sysmo_Verification)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 📋 Overview

**Sysmo Verification** is a Flutter package that simplifies KYC (Know Your Customer) document verification. It supports **Aadhaar**, **PAN**, **Voter ID**, **Passport**, and **GST** verification with a consistent UI and easy integration.

### ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🎨 **Unified UI** | Consistent interface across all verification types |
| 🔧 **Customizable** | Modify colors, styling, validation patterns, and API endpoints |
| ⚡ **Reactive Forms** | Built on `reactive_forms` for seamless form management |
| 📱 **Offline Support** | Works with both live APIs and local mock data |
| 🔒 **Type Safe** | Full null safety support |

---

## 📦 Installation

### Step 1: Add dependency

Add to your `pubspec.yaml`:

```yaml
dependencies:
  sysmo_verification: ^0.0.12
```

### Step 2: Install packages

```bash
flutter pub get
```

### Step 3: Platform Setup

**Android** — Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS** — Add to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <false/>
</dict>
```

---

## 🚀 Quick Start

### Step 1: Import the package

```dart
import 'package:sysmo_verification/kyc_validation.dart';
```

### Step 2: Create a form with ReactiveFormBuilder

Wrap your verification widget inside a `ReactiveFormBuilder` to manage form state:

```dart
class MyVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ReactiveFormBuilder(
      form: () => FormGroup({
        'panNumber': FormControl<String>(
          validators: [Validators.required],
        ),
      }),
      builder: (context, form, child) {
        return Column(
          children: [
            // Add your KYCTextBox widget here
          ],
        );
      },
    );
  }
}
```

---

## 📖 Usage Examples

### Example 1: PAN Card Verification (Simplest)

```dart
KYCTextBox(
  // Form configuration
  formProps: FormProps(
    formControlName: 'panNumber',
    label: 'PAN Number',
    mandatory: true,
    maxLength: 10,
  ),
  
  // Validation
  validationPattern: RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$'),
  validationPatternErrorMessage: 'Enter valid PAN (e.g., ABCDE1234F)',
  verificationType: VerificationType.pan,
  
  // Styling
  styleProps: StyleProps(),
  buttonProps: ButtonProps(
    label: 'Verify',
    foregroundColor: Colors.white,
  ),
  
  // API Configuration
  isOffline: false,                                    // Set true for testing with mock data
  apiUrl: 'https://your-api.com/verify/pan',          // Your verification API endpoint
  token: 'your-auth-token',
  leadId: 'unique-lead-id',
  
  // Aadhaar-specific fields (required but can be empty for PAN)
  otpGendraassetApiurl: '',
  otpGendrateassetPath: '',
  aadhaarResponseApiurl: '',
  aadhaarResponseassetspath: '',
  aadharvaultassetpath: '',
  aadharvaultApiurl: '',
  aadharvaultlookupassetpath: '',
  aadharvaultlookupapiurl: '',
  
  // Callbacks
  onSuccess: (response) {
    print('Verification successful: ${response.data}');
  },
  onError: (error) {
    print('Verification failed: $error');
  },
)
```

### Example 2: Aadhaar Verification (with OTP)

Aadhaar requires OTP verification. The widget automatically handles the OTP flow:

```dart
KYCTextBox(
  formProps: FormProps(
    formControlName: 'aadhaarNumber',
    label: 'Aadhaar Number',
    mandatory: true,
    maxLength: 12,
  ),
  
  validationPattern: RegExp(r'^\d{12}$'),
  validationPatternErrorMessage: 'Enter 12-digit Aadhaar number',
  verificationType: VerificationType.aadhaar,
  
  styleProps: StyleProps(),
  buttonProps: ButtonProps(
    label: 'Verify with OTP',
    foregroundColor: Colors.white,
  ),
  
  // Online API mode
  isOffline: false,
  apiUrl: 'https://your-api.com/verify/aadhaar',
  token: 'your-auth-token',
  leadId: 'unique-lead-id',
  
  // Aadhaar-specific API endpoints
  otpGendraassetApiurl: 'https://your-api.com/aadhaar/generate-otp',
  aadhaarResponseApiurl: 'https://your-api.com/aadhaar/verify-otp',
  aadharvaultApiurl: 'https://your-api.com/aadhaar/vault',
  aadharvaultlookupapiurl: 'https://your-api.com/aadhaar/vault-lookup',
  
  // Asset paths (empty when using online mode)
  otpGendrateassetPath: '',
  aadhaarResponseassetspath: '',
  aadharvaultassetpath: '',
  aadharvaultlookupassetpath: '',
  
  onSuccess: (response) {
    print('Aadhaar verified: ${response.data}');
  },
  onError: (error) {
    print('Aadhaar verification failed: $error');
  },
)
```

### Example 3: Offline Testing Mode

For development and testing, use mock JSON responses:

```dart
KYCTextBox(
  formProps: FormProps(
    formControlName: 'voterId',
    label: 'Voter ID',
    mandatory: true,
    maxLength: 10,
  ),
  
  validationPattern: RegExp(r'^[A-Z]{3}\d{7}$'),
  validationPatternErrorMessage: 'Enter valid Voter ID (e.g., ABC1234567)',
  verificationType: VerificationType.voterId,
  
  styleProps: StyleProps(),
  buttonProps: ButtonProps(label: 'Verify'),
  
  // Offline mode - uses local asset files
  isOffline: true,
  assetPath: 'assets/mock_data/voter_response.json',
  
  // Empty API URLs for offline mode
  apiUrl: '',
  token: '',
  leadId: '',
  otpGendraassetApiurl: '',
  otpGendrateassetPath: '',
  aadhaarResponseApiurl: '',
  aadhaarResponseassetspath: '',
  aadharvaultassetpath: '',
  aadharvaultApiurl: '',
  aadharvaultlookupassetpath: '',
  aadharvaultlookupapiurl: '',
  
  onSuccess: (response) => print('Success: ${response.data}'),
  onError: (error) => print('Error: $error'),
)
```

### Example 4: Complete Screen Implementation

```dart
import 'package:flutter/material.dart';
import 'package:sysmo_verification/kyc_validation.dart';

class KYCVerificationScreen extends StatelessWidget {
  const KYCVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KYC Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ReactiveFormBuilder(
          form: () => FormGroup({
            'panNumber': FormControl<String>(
              validators: [Validators.required],
            ),
          }),
          builder: (context, form, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PAN Verification Widget
                KYCTextBox(
                  formProps: FormProps(
                    formControlName: 'panNumber',
                    label: 'PAN Number',
                    mandatory: true,
                    maxLength: 10,
                  ),
                  validationPattern: RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$'),
                  validationPatternErrorMessage: 'Enter valid PAN',
                  verificationType: VerificationType.pan,
                  styleProps: StyleProps(),
                  buttonProps: ButtonProps(
                    label: 'Verify PAN',
                    foregroundColor: Colors.white,
                  ),
                  isOffline: true, // Change to false for production
                  assetPath: 'assets/mock_data/pan_response.json',
                  apiUrl: '',
                  token: '',
                  leadId: 'lead-123',
                  otpGendraassetApiurl: '',
                  otpGendrateassetPath: '',
                  aadhaarResponseApiurl: '',
                  aadhaarResponseassetspath: '',
                  aadharvaultassetpath: '',
                  aadharvaultApiurl: '',
                  aadharvaultlookupassetpath: '',
                  aadharvaultlookupapiurl: '',
                  onSuccess: (response) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PAN Verified!')),
                    );
                  },
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $error')),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (form.valid) {
                      print('Form submitted: ${form.value}');
                    } else {
                      form.markAllAsTouched();
                    }
                  },
                  child: const Text('Submit'),
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

---

## 📖 Supported Verification Types

| Type | Validation Pattern | Verification Method | Example |
|------|-------------------|---------------------|---------|
| 🆔 **Aadhaar** | `^\d{12}$` | OTP-based | `123456789012` |
| 💳 **PAN** | `^[A-Z]{5}[0-9]{4}[A-Z]$` | Instant | `ABCDE1234F` |
| 🗳️ **Voter ID** | `^[A-Z]{3}\d{7}$` | Instant | `ABC1234567` |
| 🏢 **GST** | `^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$` | Instant | `22ABCDE1234F1Z5` |
| ✈️ **Passport** | `^[A-Z][1-9][0-9]{6}$` | Instant | `A1234567` |

---

## 🔧 Configuration Reference

### FormProps — Input Field Settings

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `formControlName` | `String` | ✅ | Unique name for form control |
| `label` | `String` | ✅ | Input field label text |
| `mandatory` | `bool` | ❌ | Show asterisk for required fields (default: `false`) |
| `maxLength` | `int?` | ❌ | Maximum character limit |
| `hint` | `String?` | ❌ | Placeholder text |

```dart
FormProps(
  formControlName: 'panNumber',
  label: 'PAN Number',
  mandatory: true,
  maxLength: 10,
  hint: 'Enter your PAN',
)
```

### ButtonProps — Verify Button Settings

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `label` | `String` | ✅ | Button text |
| `foregroundColor` | `Color?` | ❌ | Text/icon color |
| `backgroundColor` | `Color?` | ❌ | Button background color |
| `borderRadius` | `double?` | ❌ | Corner radius |
| `disabled` | `bool` | ❌ | Disable button (default: `false`) |

```dart
ButtonProps(
  label: 'Verify',
  foregroundColor: Colors.white,
  backgroundColor: Colors.blue,
  borderRadius: 8.0,
)
```

### StyleProps — Visual Styling

| Property | Type | Description |
|----------|------|-------------|
| `textStyle` | `TextStyle?` | Input text styling |
| `borderRadius` | `double?` | Input field corner radius |
| `padding` | `EdgeInsets?` | Widget padding |
| `inputDecoration` | `InputDecoration?` | Custom input decoration |

```dart
StyleProps(
  textStyle: TextStyle(fontSize: 16, color: Colors.black87),
  borderRadius: 8.0,
  padding: EdgeInsets.all(16),
)
```

---

## 🔄 Online vs Offline Mode

### Online Mode (Production)

Set `isOffline: false` and provide API endpoints:

```dart
KYCTextBox(
  isOffline: false,
  apiUrl: 'https://your-api.com/verify/pan',
  token: 'Bearer your-auth-token',
  // ... other properties
)
```

### Offline Mode (Testing/Development)

Set `isOffline: true` and provide asset paths:

```dart
KYCTextBox(
  isOffline: true,
  assetPath: 'assets/mock_data/pan_response.json',
  // ... other properties
)
```

**Setup for Offline Mode:**

1. Create mock JSON files in your assets folder:

```
assets/
└── mock_data/
    ├── pan_response.json
    ├── aadhaar_response.json
    └── voter_response.json
```

2. Add to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/mock_data/
```

3. Example mock response (`pan_response.json`):

```json
{
  "Success": true,
  "PanValidation": {
    "success": true,
    "name": "John Doe",
    "panNumber": "ABCDE1234F"
  }
}
```

---

## ⚠️ Error Handling

Handle verification results using callbacks:

```dart
KYCTextBox(
  onSuccess: (response) {
    // response.data contains the verification result
    final data = response.data;
    print('Verification successful!');
    print('Name: ${data['name']}');
  },
  onError: (error) {
    // Handle different error scenarios
    if (error.toString().contains('network')) {
      showDialog(/* Network error dialog */);
    } else if (error.toString().contains('invalid')) {
      showDialog(/* Invalid document dialog */);
    } else {
      showDialog(/* Generic error dialog */);
    }
  },
  // ... other properties
)
```

### Error Types

| Exception | Description |
|-----------|-------------|
| `NetworkException` | Network connectivity issues |
| `ValidationException` | Invalid input format |
| `AuthException` | Authentication/token errors |
| `ConfigurationException` | Missing or invalid configuration |
| `OtpException` | OTP verification failures |

---

## 🧪 Testing

### Widget Test Example

```dart
testWidgets('PAN verification widget renders correctly', (tester) async {
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
                mandatory: true,
              ),
              verificationType: VerificationType.pan,
              validationPattern: RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$'),
              isOffline: true,
              assetPath: 'assets/mock_data/pan_response.json',
              // ... other required properties
            );
          },
        ),
      ),
    ),
  );

  expect(find.text('PAN Number'), findsOneWidget);
  expect(find.text('Verify'), findsOneWidget);
});
```

---

## 📚 API Quick Reference

### Core Classes

| Class | Purpose |
|-------|---------|
| `KYCTextBox` | Main verification widget (input + button) |
| `KYCInputField` | Standalone input field only |
| `VerifyButton` | Standalone verify button only |
| `FormProps` | Input field configuration |
| `ButtonProps` | Button configuration |
| `StyleProps` | Visual styling configuration |

### Verification Types (Enum)

```dart
enum VerificationType {
  aadhaar,   // Aadhaar card (12 digits, OTP required)
  pan,       // PAN card (10 characters)
  voterId,   // Voter ID (10 characters)
  gst,       // GST number (15 characters)
  passport,  // Passport number (8 characters)
}
```

---

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

MIT License — see [LICENSE](LICENSE) for details.

## 📞 Support

- 🐛 [Report bugs](https://github.com/gayathribalraj/Sysmo_Verification/issues)
- 💬 [Discussions](https://github.com/gayathribalraj/Sysmo_Verification/discussions)
- 📧 Email: support@sysmo.com

---

*Made with ❤️ for the Mobile Development Team*
