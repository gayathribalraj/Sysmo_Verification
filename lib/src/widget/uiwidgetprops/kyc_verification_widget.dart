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
  final String? otpGendrateassetPath;
  final String otpGendraassetApiurl;
  final String aadhaarResponseassetspath;
  final String aadhaarResponseApiurl;
  final String aadharvaultassetpath;
  final String aadharvaultApiurl;
  final String aadharvaultlookupassetpath;
  final String aadharvaultlookupapiurl;
  final String? apiUrl;
  final ValueChanged<dynamic> onSuccess;
  final ValueChanged<dynamic> onError;
  final Key? fieldKey;
  final VerificationType verificationType;
  final String? kycNumber;
  final ReactiveFormFieldCallback<String>? onChange;
  final bool showVerifyButton;
  final String? validationPatternErrorMessage;
  final RegExp? validationPattern;
  final String token ;
  final String leadId;

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
    this.apiUrl,
    required this.verificationType,
    this.kycNumber,
    this.validationPatternErrorMessage,
    required this.validationPattern,
    this.otpGendrateassetPath,
    required this.otpGendraassetApiurl,
    required this.aadhaarResponseassetspath,
    required this.aadhaarResponseApiurl,
    required this.aadharvaultassetpath,
    required this.aadharvaultApiurl,
    required this.aadharvaultlookupassetpath,
    required this.aadharvaultlookupapiurl,
    required this.leadId,
    required this.token
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
  
  // Aadhaar verification state flags
  bool otpVerified = false;
  bool otpVrfy = true;
  String? aadhaarRefNumber;

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
        _handleVerificationSuccess(
          'Voter ID ${ConstantVariable.verifiedSuccessfullyString}',
          response,
        );
      } else {
        _handleVerificationError(
          'Voter ID ${ConstantVariable.verificationFaildString}',
        );
      }
    } catch (e) {
      _handleVerificationError(
        'Voter ${ConstantVariable.verificationFaildString}',
      );
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
        _handleVerificationSuccess(
          'Pan ID ${ConstantVariable.verifiedSuccessfullyString}',
          response,
        );
      } else {
        _handleVerificationError(
          'PAN ${ConstantVariable.verificationFaildString}',
        );
      }
    } catch (e) {
      _handleVerificationError(
        'PAN ${ConstantVariable.verificationFaildString}',
      );
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
        _handleVerificationSuccess(
          'GST ${ConstantVariable.verifiedSuccessfullyString}',
          response,
        );
      } else {
        _handleVerificationError(
          'GST ${ConstantVariable.verificationFaildString}',
        );
      }
    } catch (e) {
      _handleVerificationError(
        'GST ${ConstantVariable.verificationFaildString}',
      );
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
        _handleVerificationSuccess(
          'Passport ${ConstantVariable.verifiedSuccessfullyString}',
          response,
        );
      } else {
        _handleVerificationError(
          'Passport ${ConstantVariable.verificationFaildString}',
        );
      }
    } catch (e) {
      _handleVerificationError(
        'Passport ${ConstantVariable.verificationFaildString}',
      );
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
            assetPath: widget.otpGendrateassetPath ?? '',
            url: widget.otpGendraassetApiurl,
            aadhaarResponseassetspath: widget.aadhaarResponseassetspath,
            aadhaarResponseApiurl: widget.aadhaarResponseApiurl,
            leadId:widget.leadId ,
            token: widget.token, 
            isOffline: widget.isOffline,
            
          ),
        ),
      );

      // Check OTP validation response
      if (consentResponse != null && consentResponse.data != null) {
        final responseData = consentResponse.data;
        final otpValidation = responseData['otpValidationNew'];

        if (otpValidation != null &&
            otpValidation['ErrorCode'] == '000' &&
            otpValidation['Status'] == 'Y') {
          
          debugPrint("OTP Verification SUCCESS");
          await handleOtpSuccessAndVault(otpValidation, consentResponse);
        } else {
          final errorStatus =
              otpValidation?['ErrorStatus'] ?? 'Aadhaar verification failed';
          final errorCode = otpValidation?['ErrorCode'] ?? 'Unknown error';

          debugPrint("Aadhaar Verification Failed");
          debugPrint("ErrorCode: $errorCode");
          debugPrint("ErrorStatus: $errorStatus");

          _handleVerificationError(
            'Aadhaar ID ${ConstantVariable.verificationFaildString}',
          );
        }
      } else {
        _handleVerificationError(
          'Aadhaar ID ${ConstantVariable.verificationFaildString}',
        );
      }
    } catch (e) {
      debugPrint('Aadhaar Verification Error: $e');
      _handleVerificationError(
        'Aadhaar ${ConstantVariable.verificationFaildString}',
      );
    }
  }

  
  Future<void> handleOtpSuccessAndVault(
    Map<String, dynamic> otpValidation,
    Response otpResponse,
  ) async {
    try {
      setState(() {
        _buttonStateManager.setLoading();
      });

      final kycDetails = otpValidation['KycDetails'];
      final transactionId = otpValidation['TransactionId'];
      final refNumFromOtp = otpValidation['aadharRefNum'];

      debugPrint(" OTP SUCCESS HANDLER");
      debugPrint("TransactionId: $transactionId");
      debugPrint("Name: ${kycDetails?['name']}");
      debugPrint("aadharRefNum from OTP: $refNumFromOtp");

      // SCENARIO 1: Check if aadharRefNum already exists in OTP response
      if (refNumFromOtp != null && refNumFromOtp.toString().isNotEmpty) {
        debugPrint(" aadharRefNum found in OTP response");
        debugPrint("RefNum: $refNumFromOtp");

        // Mark as verified and store reference number
        aadhaarRefNumber = refNumFromOtp.toString();
        otpVerified = true;
        otpVrfy = false;

        debugPrint(" otpVerified = true");
        debugPrint(" otpVrfy = false");
        debugPrint(" aadhaarRefNumber = $aadhaarRefNumber");

        _handleVaultVerificationSuccess(otpValidation, {}, aadhaarRefNumber!);
      } else {
        // aadharRefNum not in OTP response, call Vault Lookup
        debugPrint(" aadharRefNum NOT found in OTP response");
        debugPrint(" Calling Vault Lookup API...");

        await aadharVaultLookup(_currentInput, '323234434334', otpValidation);
      }
    } catch (e) {
      debugPrint(' handleOtpSuccessAndVault Error: $e');
      _handleVerificationError(
        'Aadhaar ${ConstantVariable.verificationFaildString}',
      );
    } finally {
      // Only reset button if verification was not successful
      if (!otpVerified) {
        setState(() {
          _buttonStateManager.reset(widget.buttonProps.label);
        });
      }
    }
  }

  /// Aadhaar Vault Lookup API call
  ///
  /// SCENARIO 1: If errorCode == "000" and aadharRefNum exists
  ///   -> Set otpVerified = true, otpVrfy = false
  ///   -> Store aadhaarRefNumber
  ///
  /// SCENARIO 2: If errorCode == "2"
  ///   -> Call triggerAadharVault()
  Future<void> aadharVaultLookup(
    String aadhaarNumber,
    String leadId ,
    Map<String, dynamic> otpValidation,
  ) async {
    try {
      debugPrint(" VAULT LOOKUP");
      debugPrint("aadhaarNumber: $aadhaarNumber");
      debugPrint("leadId: $widget.leadId");

      // Build Vault Lookup request
      final vaultLookupRequest = {
        'aadharNumber': aadhaarNumber,
        'uniqueId': widget.leadId,
        'token': widget.token,
      };

      debugPrint(" Request: $vaultLookupRequest");

      // Call Vault Lookup API
      final vaultLookupResponse = await _verificationHandler.verify(
        isOffline: widget.isOffline,
        url: widget.aadharvaultlookupapiurl,
        assetPath: widget.aadharvaultlookupassetpath,
        request: vaultLookupRequest,
      );

      debugPrint(" Response Status: ${vaultLookupResponse.statusCode}");

      if (vaultLookupResponse.data != null) {
        final vaultData = vaultLookupResponse.data;
        final vaultLookup = vaultData is Map 
            ? (vaultData['VaultLoolUp'] ?? vaultData) 
            : vaultData;

        // Extract response fields
        final errorCode = vaultLookup is Map 
            ? (vaultLookup['errorCode'] ??
                vaultLookup['ErrorCode'] ??
                vaultLookup['error_code']) 
            : null;
        final refNum = vaultLookup is Map 
            ? vaultLookup['aadharRefNum'] 
            : null;

        debugPrint(" Vault Lookup Response:");
        debugPrint("   ErrorCode: $errorCode");
        debugPrint("   aadharRefNum: $refNum");

        if (errorCode == null) {
          throw Exception('No errorCode in Vault Lookup response');
        }

        // SCENARIO 1: errorCode == "000" and aadharRefNum exists
        if ((errorCode == '000' || errorCode == 0) && refNum != null) {
          debugPrint("  Vault Lookup Success");
          debugPrint("   ErrorCode: 000");
          debugPrint("   aadharRefNum: $refNum");

          aadhaarRefNumber = refNum.toString();
          otpVerified = true;
          otpVrfy = false;

          debugPrint(" otpVerified = true");
          debugPrint(" otpVrfy = false");
          debugPrint(" aadhaarRefNumber = $aadhaarRefNumber");

          _handleVaultVerificationSuccess(
            otpValidation,
            vaultLookup is Map<String, dynamic> ? vaultLookup : {},
            aadhaarRefNumber!,
          );
        }
        // SCENARIO 2: errorCode == "2"
        else if (errorCode == '2' || errorCode == 2) {
          debugPrint(" ErrorCode 2 - Triggering Aadhaar Vault");
          debugPrint("   Calling triggerAadharVault()...");

          await triggerAadharVault(
            aadhaarNumber,
            widget.leadId,
            otpValidation,
          );
        } else {
          throw Exception('Vault Lookup failed with errorCode: $errorCode');
        }
      } else {
        throw Exception(
            'Vault Lookup returned null data. Status: ${vaultLookupResponse.statusCode}');
      }
    } catch (e) {
      debugPrint(' aadharVaultLookup Error: $e');
      _handleVerificationError(
        'Aadhaar ${ConstantVariable.verificationFaildString}',
      );
    } finally {
      // Only reset button if verification was not successful
      if (!otpVerified) {
        setState(() {
          _buttonStateManager.reset(widget.buttonProps.label);
        });
      }
    }
  }

  /// Trigger Aadhaar Vault API when Vault Lookup returns errorCode == "2"
  ///
  /// If errorCode == "000" and aadharRefNum exists
  ///   -> Set otpVerified = true, otpVrfy = false
  ///   -> Store aadhaarRefNumber from Trigger response
  Future<void> triggerAadharVault(
    String aadhaarNumber,
    String leadId,
    Map<String, dynamic> otpValidation,
  ) async {
    try {
      debugPrint(" TRIGGER AADHAAR VAULT");
      debugPrint("aadhaarNumber: $aadhaarNumber");
      debugPrint("leadId: $leadId");

      // Build Trigger Aadhaar Vault request
      final vaultRequest = {
        'aadharNumber': aadhaarNumber,
        'uniqueId': widget.leadId,
        'token': widget.token,
      };

      debugPrint(" Request: $vaultRequest");

      // Call Trigger Aadhaar Vault API
      final vaultResponse = await _verificationHandler.verify(
        isOffline: widget.isOffline,
        url: widget.aadharvaultApiurl,
        assetPath: widget.aadharvaultassetpath,
        request: vaultRequest,
      );

      debugPrint(" Response Status: ${vaultResponse.statusCode}");

      if (vaultResponse.data != null) {
        final vaultData = vaultResponse.data;
        final aadharVault = vaultData is Map 
            ? (vaultData['AadharValut'] ?? vaultData) 
            : vaultData;

        // Extract response fields
        final errorCode = aadharVault is Map 
            ? (aadharVault['errorCode'] ??
                aadharVault['ErrorCode'] ??
                aadharVault['error_code']) 
            : null;
        final refNum = aadharVault is Map 
            ? aadharVault['aadharRefNum'] 
            : null;

        debugPrint(" Aadhaar Vault Response:");
        debugPrint("   ErrorCode: $errorCode");
        debugPrint("   aadharRefNum: $refNum");

        if (errorCode == null) {
          throw Exception('No errorCode in Aadhaar Vault response');
        }

        // Check for success and aadharRefNum
        if ((errorCode == '000' || errorCode == 0) && refNum != null) {
          debugPrint(" TRIGGER SUCCESS");
          debugPrint("   ErrorCode: 000");
          debugPrint("   aadharRefNum: $refNum");

          aadhaarRefNumber = refNum.toString();
          otpVerified = true;
          otpVrfy = false;

          debugPrint(" otpVerified = true");
          debugPrint(" otpVrfy = false");
          debugPrint(" aadhaarRefNumber = $aadhaarRefNumber");

          _handleVaultVerificationSuccess(
            otpValidation,
            aadharVault is Map<String, dynamic> ? aadharVault : {},
            aadhaarRefNumber!,
          );
        } else {
          throw Exception(
              'Aadhaar Vault failed - ErrorCode: $errorCode, RefNum: $refNum');
        }
      } else {
        throw Exception(
            'Aadhaar Vault returned null data. Status: ${vaultResponse.statusCode}');
      }
    } catch (e) {
      debugPrint(' triggerAadharVault Error: $e');
      _handleVerificationError(
        'Aadhaar ${ConstantVariable.verificationFaildString}',
      );
    } finally {
      // Only reset button if verification was not successful
      if (!otpVerified) {
        setState(() {
          _buttonStateManager.reset(widget.buttonProps.label);
        });
      }
    }
  }

  /// Handle successful vault verification
  void _handleVaultVerificationSuccess(
    Map<String, dynamic> otpValidation,
    Map<String, dynamic> vaultData,
    String aadhaarRefNumber,
  ) {
    debugPrint("Aadhaar Verification SUCCESS");
    debugPrint("Aadhaar Ref Number: $aadhaarRefNumber");
    debugPrint("Vault Data: $vaultData");

    // Create combined response
    final finalResponse = Response(
      requestOptions: RequestOptions(path: ''),
      data: {
        'otpValidation': otpValidation,
        'vaultData': vaultData,
        'aadhaarRefNumber': aadhaarRefNumber,
      },
      statusCode: 200,
    );

    _handleVerificationSuccess(
      'Aadhaar ID ${ConstantVariable.verifiedSuccessfullyString}',
      finalResponse,
    );
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
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
          const SizedBox(width: 16),
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
