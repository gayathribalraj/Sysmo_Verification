/*
  @author   : Gayathri
  @created  : 08/11/2025
  @desc     : REFACTORED - A reusable and reactive input field for user verification workflows
  

*/

import 'package:sysmo_verification/kyc_validation.dart';

// KYCTextBox Widget - Refactored to use cleaner state management

class KYCTextBox extends StatefulWidget {
  final FormProps formProps;
  final StyleProps styleProps;
  final ButtonProps buttonProps;
  final bool isOffline;
  final String? assetPath;
  final String apiUrl;
  final ValueChanged<dynamic> onSuccess;
  final ValueChanged<dynamic> onError;
  final Key? fieldKey;
  final VerificationType verificationType;
  final String? kycNumber;
  final ReactiveFormFieldCallback<String>? onChange;
  final bool showVerifyButton;
  final String? validationPatternErrorMessage;
  final RegExp? validationPattern;

  const KYCTextBox({
    super.key,
    this.fieldKey,
    required this.formProps,
    required this.styleProps,
    this.showVerifyButton = false,
    this.onChange,
    required this.buttonProps,
    required this.isOffline,
    this.assetPath,
    required this.onSuccess,
    required this.onError,
    required this.apiUrl,
    required this.verificationType,
    this.kycNumber,
    this.validationPatternErrorMessage,
    required this.validationPattern,
  });

  @override
  State<StatefulWidget> createState() => _KYCTextBoxState();
}

// _KYCTextBoxState - Refactored state with better separation of concerns
class _KYCTextBoxState extends State<KYCTextBox> {
  // Use extracted state managers instead of raw booleans
  late ButtonStateManager _buttonStateManager;
  late InputValidationManager _inputValidator;

  // Verification components
  late VerificationHandler _verificationHandler;
  late ResponseParser _responseParser;

  String _currentInput = '';

  @override
  void initState() {
    super.initState();
    _initializeManagers();
    _initializeHandlers();
  }

  /// Initialize state managers
  void _initializeManagers() {
    _buttonStateManager = ButtonStateManager();
    _inputValidator = InputValidationManager();

   

    // Initialize button with label or "verified" state if kycNumber exists
    if (widget.kycNumber != null && widget.kycNumber!.isNotEmpty) {
      _buttonStateManager.setSuccess('verified');
    } else {
      _buttonStateManager.initialize(widget.buttonProps.label);
    }
  }

  /// Initialize verification and response parsing handlers
  void _initializeHandlers() {
    _verificationHandler = VerificationHandlerFactory.create(
      widget.verificationType,
    );
    _responseParser = ResponseParserFactory.create(widget.verificationType);
  }

  /// Handle input change and validation
  void _handleInputChange(String value) {
    _currentInput = value.trim();

    setState(() {
      // Reset button state when input changes
      _buttonStateManager.reset(widget.buttonProps.label);
    });
  }

  /// Perform verification based on type
  Future<void> _handleVerification() async {
    if (_currentInput.isEmpty) return;

    setState(() {
      _buttonStateManager.setLoading();
    });

    try {
      switch (widget.verificationType) {
        case VerificationType.voter:
          await _verifyVoter();
          break;
        case VerificationType.pan:
          await _verifyPan();
          break;
        case VerificationType.gst:
          await _verifyGst();
          break;
        case VerificationType.passport:
          await _verifyPassport();
          break;
        case VerificationType.aadhaar:
          await _verifyAadhaar();
          break;
      }
    } catch (e) {
      debugPrint('Verification error: $e');
      _handleVerificationError(ConstantVariable.verificationFaildString);
    } finally {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _buttonStateManager.isLoading;
      });
    }
  }

  /// Verify Voter ID
  Future<void> _verifyVoter() async {
    await Future.delayed(const Duration(seconds: 2));

    final voterRequest = VoteridRequest(epicNo: _currentInput);

    try {
      final response = await _verificationHandler.verify(
        isOffline: widget.isOffline,
        url: widget.apiUrl,
        assetPath: widget.assetPath,
        request: voterRequest,
      );

      if (_responseParser.parseOfflineResponse(response.data) ||
          _responseParser.parseOnlineResponse(response.data)) {
        _handleVerificationSuccess('Voter ID ${ConstantVariable.verifiedSuccessfullyString}', response);
      } else {
        _handleVerificationError('Voter ID ${ConstantVariable.verificationFaildString}');
      }
    } catch (e) {
      _handleVerificationError('Voter ${ConstantVariable.verificationFaildString}');
    }
  }

  /// Verify PAN
  Future<void> _verifyPan() async {
    await Future.delayed(const Duration(seconds: 2));

    final panRequest = PanidRequest(pan: _currentInput);

    try {
      final response = await _verificationHandler.verify(
        isOffline: widget.isOffline,
        url: widget.apiUrl,
        assetPath: widget.assetPath,
        request: panRequest,
      );

      if (_responseParser.parseOfflineResponse(response.data) ||
          _responseParser.parseOnlineResponse(response.data)) {
        _handleVerificationSuccess('Pan ID ${ConstantVariable.verifiedSuccessfullyString}', response);
      } else {
        _handleVerificationError('PAN ${ConstantVariable.verificationFaildString}');
      }
    } catch (e) {
      _handleVerificationError('PAN ${ConstantVariable.verificationFaildString}');
    }
  }

  /// Verify GST
  Future<void> _verifyGst() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final response = await _verificationHandler.verify(
        isOffline: widget.isOffline,
        url: widget.apiUrl,
        assetPath: widget.assetPath,
      );

      if (_responseParser.parseOfflineResponse(response.data) ||
          _responseParser.parseOnlineResponse(response.data)) {
        _handleVerificationSuccess('GST ${ConstantVariable.verifiedSuccessfullyString}', response);
      } else {
        _handleVerificationError('GST ${ConstantVariable.verificationFaildString}');
      }
    } catch (e) {
      _handleVerificationError('GST ${ConstantVariable.verificationFaildString}');
    }
  }

  /// Verify Passport
  Future<void> _verifyPassport() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final response = await _verificationHandler.verify(
        isOffline: widget.isOffline,
        url: widget.apiUrl,
        assetPath: widget.assetPath,
      );

      if (_responseParser.parseOfflineResponse(response.data) ||
          _responseParser.parseOnlineResponse(response.data)) {
        _handleVerificationSuccess('Passport ${ConstantVariable.verifiedSuccessfullyString}', response);
      } else {
        _handleVerificationError('Passport ${ConstantVariable.verificationFaildString}');
      }
    } catch (e) {
      _handleVerificationError('Passport ${ConstantVariable.verificationFaildString}');
    }
  }

  /// Verify Aadhaar
  Future<void> _verifyAadhaar() async {
    setState(() {
      _buttonStateManager.reset(widget.buttonProps.label);
    });
    final methodType = await showValidateOptions(context);

    if (methodType == null) return;

    try {
      final consentResponse = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConsentForm(
            aadhaarNumber: _currentInput,
            aadhaarmethod: methodType,
            assetPath: widget.assetPath ?? '',
            url: widget.apiUrl,
          ),
        ),
      );

      if (consentResponse?.data['Success'] == true) {
        _handleVerificationSuccess(
          'Aadhaar ID ${ConstantVariable.verifiedSuccessfullyString}',
          consentResponse,
        );
      } else {
        _handleVerificationError('Aadhaar ID ${ConstantVariable.verificationFaildString}');
      }
    } catch (e) {
      _handleVerificationError('Aadhaar ${ConstantVariable.verificationFaildString}');
    }
  }

  /// Handle successful verification
  void _handleVerificationSuccess(String message, Response response) {
    widget.onSuccess(response);
    setState(() {
      _buttonStateManager.setSuccess(ConstantVariable.verifiedString);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Handle verification error
  void _handleVerificationError(String message) {
    widget.onError(message);
    setState(() {
      _buttonStateManager.setError(ConstantVariable.failedString);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: KYCInputField(
              formProps: widget.formProps,
              styleProps: widget.styleProps,
              validationManager: _inputValidator,
              validationPatternErrorMessage:
                  widget.validationPatternErrorMessage,
              validationPattern: widget.validationPattern,
              disabled: _buttonStateManager.isDisabled,
              keyboardType: _getKeyboardType(widget.verificationType),
              onChange: (control) {
                _handleInputChange(control.value ?? '');
                widget.onChange?.call(control);
              },
            ),
          ),
          const SizedBox(width: 10),
          VerifyButton(
            stateManager: _buttonStateManager,
            buttonProps: widget.buttonProps,
            onPressed:
                (!_inputValidator.isValid ||
                    (widget.validationPattern != null &&
                        !widget.validationPattern!.hasMatch(_currentInput)) ||
                    _buttonStateManager.isLoading ||
                    _buttonStateManager.isDisabled)
                ? null
                : _handleVerification,
          ),
        ],
      ),
    );
  }

  /// Get keyboard type based on verification type
  TextInputType _getKeyboardType(VerificationType type) {
    return switch (type) {
      VerificationType.aadhaar => TextInputType.number,
      VerificationType.pan ||
      VerificationType.voter ||
      VerificationType.gst ||
      VerificationType.passport => TextInputType.text,
    };
  }
}

/// Helper function to get keyboard type (kept for backward compatibility)
TextInputType getKeyboardType(VerificationType type) {
  return switch (type) {
    VerificationType.aadhaar => TextInputType.number,
    VerificationType.pan ||
    VerificationType.voter ||
    VerificationType.gst ||
    VerificationType.passport => TextInputType.text,
  };
}
