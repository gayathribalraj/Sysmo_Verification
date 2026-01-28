# Sysmo Verification 🔐

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/gayathribalraj/Sysmo_Verification)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 📋 Package Introduction

**Sysmo Verification** is a comprehensive Flutter package designed to simplify multiple KYC (Know Your Customer) verification processes including **Aadhaar**, **PAN**, **Voter ID**, **Passport**, **GST**, and **OTP** workflows.

The package provides a unified approach to document verification with consistent UI/UX patterns, robust error handling, and flexible configuration options.

### ✨ Key Features

- **🎨 Unified UI**: Consistent interface across all verification types
- **🔧 Highly Customizable**: Easily modify colors, styling, validation patterns, and API endpoints
- **🔄 Reusable Components**: Common UI widgets and base classes shared across all KYC modules
- **⚡ Reactive Forms**: Built on reactive_forms for better form management
- **🛡️ Robust Error Handling**: Comprehensive error handling with specific exception types
- **📱 Offline Support**: Both online API and offline asset-based verification
- **🔒 Type Safety**: Full null safety support with improved type checking
- **🧪 Test Ready**: Designed with testing in mind

## 🎯 Why Use This Package?

- **🚀 Saves Development Time** — No need to rebuild KYC flows repeatedly
- **🎨 Ensures Consistency** — All document types follow the same UI/UX pattern
- **🏗️ Modular & Maintainable** — Clear separation between UI, data models, and service layers
- **🛡️ Production Ready** — Comprehensive error handling and null safety
- **🔒 Security First** — Built-in encryption, secure token management, and input validation
- **📱 Cross-Platform** — Works on Android, iOS, Web, and Desktop
- **🧪 Well Tested** — High test coverage with unit, widget, and integration tests
- **📚 Comprehensive Documentation** — Detailed guides, examples, and API reference
- **🔄 Flexible Architecture** — Supports both online API and offline verification modes
- **⚡ Performance Optimized** — Efficient state management and network operations

## 📦 Installation

### Add to pubspec.yaml

```yaml
dependencies:
  sysmo_verification: ^0.0.7

  # For local development:
  # sysmo_verification:
  #   path: ../path_to_sysmo_verification

  # For Git dependency:
  # sysmo_verification:
  #   git:
  #     url: https://github.com/gayathribalraj/Sysmo_Verification.git
  #     ref: main
```

Then run:

```bash
flutter pub get
```

### Platform-specific setup

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

## 🚀 Quick Start

### 1. Import the package

```dart
import 'package:sysmo_verification/kyc_validation.dart';
```

### 2. Basic Usage Example

```dart
class MyVerificationScreen extends StatelessWidget {
  final FormGroup form = FormGroup({
    'pan': FormControl<String>(
      validators: [Validators.required],
    ),
  });

  @override
  AadhaarVerification(
                        kycTextBox: KYCTextBox(
                          fieldKey: GlobalKey(),
                          validationPattern:
                              AppConstants.AADHAAR_PATTERN,
                          validationPatternErrorMessage:
                              'Please enter a valid AadhaarNumber (e.g. 123456789012)',

                          formProps: FormProps(
                            formControlName: 'idProofValue',
                            label: 'ID proof Value',
                            mandatory: true,
                            maxLength: 12,
                          ),
                          styleProps: StyleProps(),
                          apiUrl: '',
                          buttonProps: ButtonProps(
                            label: 'verify',
                            foregroundColor: Colors.white,
                          ),
                          isOffline: true,
                          onSuccess: (value) async {
                            print('onSuccess ${value.data}');
                           
                          },
                          onError: (value) {
                            print(" onerror $value");
                          },
                          verificationType: VerificationType.aadhaar,
                          otpGendraassetApiurl: '',
                          otpGendrateassetPath:
                              AppConstants.otpGendrateResponse,
                          aadhaarResponseApiurl: '',
                          aadhaarResponseassetspath:
                              AppConstants.aadhaarResponse,
                          aadharvaultassetpath:
                              AppConstants.aadharvault,
                          aadharvaultApiurl: '',
                          aadharvaultlookupassetpath:
                              AppConstants.aadharvaultlookup,
                          aadharvaultlookupapiurl: '',
                           leadId: leadId,
                            token: '',
                        ),
                      ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 3, 9, 110),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            print("Form values: ${Form.value}");
                            if (Form.valid) {
                              print(
                                "Form is valid",
                              );
                            }
                          }
                        )
}
```

## 📖 Supported Verification Types

| Type        | Document        | Verification Method | Special Features                |
| ----------- | --------------- | ------------------- | ------------------------------- |
| 🆔 Aadhaar  | Aadhaar Number  | OTP-based           | Shows OTP verification sheet    |
| 💳 PAN      | PAN Number      | Instant verify      | Single request → instant result |
| 🗳️ Voter ID | Voter Number    | Instant verify      | Single request → instant result |
| 🏢 GST      | GST Number      | Instant verify      | Single request → instant result |
| ✈️ Passport | Passport Number | Instant verify      | Single request → instant result |

## 🔧 Configuration Options

### FormProps - Input Field Configuration

```dart
FormProps(
  formControlName: 'document_number',    // Name of the form control
  label: 'Document Number',              // Input field label
  hint: 'Enter your document number',    // Placeholder text
  mandatory: true,                       // Whether the field is required
  maxLength: 10,                        // Maximum character limit
  validator: (control) => /* custom validation */,
)
```

### ButtonProps - Button Behavior & Appearance

```dart
ButtonProps(
  label: 'Verify Document',                    // Button text
  backgroundColor: Colors.blue,                // Background color
  foregroundColor: Colors.white,               // Text/icon color
  borderRadius: 8.0,                          // Corner radius
  padding: EdgeInsets.all(16),                // Inner padding
  disabled: false,                            // Whether button is disabled
)
```

### StyleProps - Visual Styling

```dart
StyleProps(
  borderRadius: 8.0,                          // Input field corner radius
  textStyle: TextStyle(fontSize: 16),         // Text styling
  padding: EdgeInsets.all(16),                // Widget padding
  backgroundColor: Colors.grey[50],           // Background color
  borderColor: Colors.grey,                   // Border color
  inputDecoration: InputDecoration(/* custom */), // Custom input decoration
)
```

## 🔄 Advanced Usage

### Error Handling with Result Pattern

```dart
// Using the safe verification method
final result = await KYCService().verifySafe(
  isOffline: false,
  url: 'https://api.example.com/verify',
  request: jsonEncode({'pan': panNumber}),
);

result.fold(
  (exception) {
    // Handle different error types
    if (exception is NetworkException) {
      print('Network error: ${exception.message}');
    } else if (exception is ValidationException) {
      print('Validation error: ${exception.message}');
      print('Field: ${exception.field}');
    } else if (exception is AuthException) {
      print('Authentication error: ${exception.message}');
    }
  },
  (response) {
    print('Success: ${response.data}');
  },
);
```

### Custom Validation Patterns

```dart
// PAN validation
final panPattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');

// Aadhaar validation
final aadhaarPattern = RegExp(r'^\d{4}\s?\d{4}\s?\d{4}$');

// GST validation
final gstPattern = RegExp(r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[A-Z\d]{1}[Z]{1}[A-Z\d]{1}$');
```

### Offline Verification Setup

For offline verification, prepare JSON files in your assets:

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/mock_data/
```

Example mock data structure:

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

## 🎨 UI Components

### KYCTextBox

The main widget that combines input field and verification button:

```dart
KYCTextBox(
  verificationType: VerificationType.pan,
  validationPattern: RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$'),
  // ... other properties
)
```

### Standalone Components

```dart
// Input field only
KYCInputField(
  formProps: FormProps(/* ... */),
  styleProps: StyleProps(/* ... */),
  validationManager: InputValidationManager(),
)

// Button only
VerifyButton(
  buttonProps: ButtonProps(/* ... */),
  onPressed: () { /* handle verification */ },
)
```

## 🧪 Testing

The package is designed with testing in mind:

```dart
// Example test
testWidgets('Aadhaar verification widget test', (WidgetTester tester) async {
  final formGroup = FormGroup({'aadhar': FormControl<String>()});

  await tester.pumpWidget(
    MaterialApp(
      home: ReactiveForm(
        formGroup: formGroup,
        child: KYCTextBox(
          verificationType: VerificationType.pan,
          // ... other props
        ),
      ),
    ),
  );

  // Test widget behavior
  expect(find.text('Aadhaar Number'), findsOneWidget);
  // ... more tests
});
```

## 🔍 Debugging

Enable detailed logging:

```dart
// In your main.dart or initialization code
ApiClient client = ApiClient(enableLogging: true);
```

## 📚 API Reference

### Core Classes

- `KYCTextBox` - Main verification widget
- `KYCService` - Service for handling verification requests
- `VerificationHandler` - Abstract handler for different verification types
- `ResponseParser` - Parse API responses
- `ButtonStateManager` - Manage button states
- `InputValidationManager` - Handle input validation

### Error Types

- `KycException` - Base exception class
- `NetworkException` - Network-related errors
- `ValidationException` - Input validation errors
- `AuthException` - Authentication errors
- `ConfigurationException` - Configuration errors
- `OtpException` - OTP-specific errors

## 📚 Documentation

### Getting Started

- 🚀 **[Quick Start Guide](#quick-start)** - Get up and running in minutes
- 📦 **[Installation Guide](#installation)** - Platform-specific setup instructions
- 🎯 **[Supported Verification Types](#supported-verification-types)** - Available document types

### Comprehensive Guides

- 📖 **[API Reference](API_REFERENCE.md)** - Complete API documentation with examples
- 🔧 **[Configuration Guide](#configuration-options)** - Detailed configuration options
- 📝 **[Examples](EXAMPLES.md)** - Practical usage examples and code samples
- 🧪 **[Testing Guide](TESTING.md)** - Unit, widget, and integration testing
- 🔄 **[Migration Guide](MIGRATION.md)** - Version migration instructions

### Advanced Topics

- 🔐 **[Security Guide](SECURITY.md)** - Security best practices and compliance
- 🤝 **[Contributing](CONTRIBUTING.md)** - How to contribute to this project
- 📋 **[Changelog](CHANGELOG.md)** - Version history and release notes

### Resources

- 💡 **[Usage Examples](#basic-usage-example)** - Common implementation patterns
- 🎨 **[Custom Styling](#configuration-options)** - UI customization options
- 🛠️ **[Error Handling](#advanced-usage)** - Robust error management strategies

## 🤝 Contributing

We welcome contributions! Please read our [Contributing Guide](CONTRIBUTING.md) for details on:

- Code of conduct
- Development setup
- Pull request process
- Code style guidelines

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For issues and questions:

- 🐛 [Report bugs](https://github.com/gayathribalraj/Sysmo_Verification/issues)
- 💬 [Discussions](https://github.com/gayathribalraj/Sysmo_Verification/discussions)
- 📧 Email: support@sysmo.com
- 🔐 Security issues: security@sysmo.com

## 🎯 Roadmap

### Upcoming Features

- [ ] **Biometric Verification** - Fingerprint and face recognition support
- [ ] **Additional Document Types** - Driving License, Passport enhancements
- [ ] **Enhanced Offline Mode** - Improved offline capabilities and caching
- [ ] **Multi-language Support** - Localization for multiple languages
- [ ] **Advanced Analytics** - Verification metrics and reporting

### Performance & Quality

- [ ] **Performance Optimizations** - Faster verification processing
- [ ] **Enhanced Testing** - Improved test coverage and automation
- [ ] **Better Error Handling** - More specific error types and messages
- [ ] **Accessibility Improvements** - Better screen reader and keyboard support

### Developer Experience

- [ ] **Flutter DevTools Integration** - Enhanced debugging capabilities
- [ ] **Code Generation** - Auto-generate configuration classes
- [ ] **Documentation Enhancements** - Interactive examples and tutorials
- [ ] **CLI Tools** - Command-line utilities for common tasks

## 🏆 Contributors

Thanks to all contributors who help make this package better:

<!-- Contributors will be added here -->

## 📊 Statistics

- **Downloads**: [![Pub Downloads](https://img.shields.io/pub/v/sysmo_verification)](https://pub.dev/packages/sysmo_verification)
- **Issues**: [![GitHub issues](https://img.shields.io/github/issues/gayathribalraj/Sysmo_Verification)](https://github.com/gayathribalraj/Sysmo_Verification/issues)
- **Stars**: [![GitHub stars](https://img.shields.io/github/stars/gayathribalraj/Sysmo_Verification)](https://github.com/gayathribalraj/Sysmo_Verification/stargazers)

---

\*_Made with ❤️ for the Mobile Development Team_
