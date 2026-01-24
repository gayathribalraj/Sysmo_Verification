
/*
  @author   : Gayathri
  @created  : 08/11/2025
  @desc     : REFACTORED - A reusable and reactive input field for user verification workflows
*/

import 'package:sysmo_verification/kyc_validation.dart';

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

class _KYCTextBoxState extends State<KYCTextBox> {
  late ButtonStateManager _buttonStateManager;
  late InputValidationManager _inputValidator;
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

  void _initializeManagers() {
    _buttonStateManager = ButtonStateManager();
    _inputValidator = InputValidationManager();

    if (widget.kycNumber != null && widget.kycNumber!.isNotEmpty) {
      _buttonStateManager.setSuccess('verified');
    } else {
      _buttonStateManager.initialize(widget.buttonProps.label);
    }
  }

  void _initializeHandlers() {
    _verificationHandler = VerificationHandlerFactory.create(
      widget.verificationType,
    );
    _responseParser = ResponseParserFactory.create(widget.verificationType);
  }

  void _handleInputChange(String value) {
    _currentInput = value.trim();
    setState(() {
      _buttonStateManager.reset(widget.buttonProps.label);
    });
  }

  Future<void> _handleVerification() async {
    if (_currentInput.isEmpty) return;

    setState(() {
      _buttonStateManager.setLoading();
    });

    try {
      switch (widget.verificationType) {
        case VerificationType.aadhaar:
          await _verifyAadhaar();
          break;
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
      }
    } catch (e) {
      debugPrint('Verification error: $e');
      _handleVerificationError(ConstantVariable.verificationFaildString);
    }
  }

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
          'PAN ID ${ConstantVariable.verifiedSuccessfullyString}',
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

  Future<void> _verifyAadhaar() async {
    final methodType = await showValidateOptions(context);

    if (methodType == null) {
      if (!mounted) return;
      setState(() {
        _buttonStateManager.reset(widget.buttonProps.label);
      });
      return;
    }

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
            leadId: widget.leadId,
            token: widget.token,
            isOffline: widget.isOffline,
          ),
        ),
      );

      if (consentResponse != null && consentResponse.data != null) {
        final otpValidation = consentResponse.data['otpValidationNew'];

        if (otpValidation != null &&
            otpValidation['ErrorCode'] == '000' &&
            otpValidation['Status'] == 'Y') {
          debugPrint("OTP Verification SUCCESS");

          await handleOtpSuccessAndVault(
            otpValidation,
            consentResponse,
          );
        } else {
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
      final kycDetails = otpValidation['KycDetails'];
      final refNumFromOtp = otpValidation['aadharRefNum'];

      if (refNumFromOtp != null && refNumFromOtp.toString().isNotEmpty) {
        aadhaarRefNumber = refNumFromOtp.toString();
        otpVerified = true;
        otpVrfy = false;

        _handleVaultVerificationSuccess(otpValidation, {}, aadhaarRefNumber!);
      } else {
        await aadharVaultLookup(_currentInput, widget.leadId, otpValidation);
      }
    } catch (e) {
      debugPrint(' handleOtpSuccessAndVault Error: $e');
      _handleVerificationError(
        'Aadhaar ${ConstantVariable.verificationFaildString}',
      );
    } finally {
      if (!mounted) return;
      if (!otpVerified) {
        setState(() {
          _buttonStateManager.reset(widget.buttonProps.label);
        });
      }
    }
  }

  Future<void> aadharVaultLookup(
    String aadhaarNumber,
    String leadId,
    Map<String, dynamic> otpValidation,
  ) async {
    try {
      final vaultLookupRequest = {
        'aadharNumber': aadhaarNumber,
        'uniqueId': widget.leadId,
        'token': widget.token,
      };

      final vaultLookupResponse = await _verificationHandler.verify(
        isOffline: widget.isOffline,
        url: widget.aadharvaultlookupapiurl,
        assetPath: widget.aadharvaultlookupassetpath,
        request: vaultLookupRequest,
      );

      if (vaultLookupResponse.data != null) {
        final vaultData = vaultLookupResponse.data;
        final vaultLookup = vaultData is Map 
            ? (vaultData['VaultLoolUp'] ?? vaultData) 
            : vaultData;

        final errorCode = vaultLookup is Map 
            ? (vaultLookup['errorCode'] ?? vaultLookup['ErrorCode'] ?? vaultLookup['error_code']) 
            : null;
        final refNum = vaultLookup is Map ? vaultLookup['aadharRefNum'] : null;

        if ((errorCode == '000' || errorCode == 0) && refNum != null) {
          aadhaarRefNumber = refNum.toString();
          otpVerified = true;
          otpVrfy = false;

          _handleVaultVerificationSuccess(
            otpValidation,
            vaultLookup is Map<String, dynamic> ? vaultLookup : {},
            aadhaarRefNumber!,
          );
        } else if (errorCode == '2' || errorCode == 2) {
          await triggerAadharVault(aadhaarNumber, widget.leadId, otpValidation);
        } else {
          throw Exception('Vault Lookup failed with errorCode: $errorCode');
        }
      } else {
        throw Exception('Vault Lookup returned null data');
      }
    } catch (e) {
      debugPrint(' aadharVaultLookup Error: $e');
      _handleVerificationError(
        'Aadhaar ${ConstantVariable.verificationFaildString}',
      );
    } finally {
      if (!mounted) return;
      if (!otpVerified) {
        setState(() {
          _buttonStateManager.reset(widget.buttonProps.label);
        });
      }
    }
  }

  Future<void> triggerAadharVault(
    String aadhaarNumber,
    String leadId,
    Map<String, dynamic> otpValidation,
  ) async {
    try {
      final vaultRequest = {
        'aadharNumber': aadhaarNumber,
        'uniqueId': widget.leadId,
        'token': widget.token,
      };

      final vaultResponse = await _verificationHandler.verify(
        isOffline: widget.isOffline,
        url: widget.aadharvaultApiurl,
        assetPath: widget.aadharvaultassetpath,
        request: vaultRequest,
      );

      if (vaultResponse.data != null) {
        final vaultData = vaultResponse.data;
        final aadharVault = vaultData is Map 
            ? (vaultData['AadharValut'] ?? vaultData) 
            : vaultData;

        final errorCode = aadharVault is Map 
            ? (aadharVault['errorCode'] ?? aadharVault['ErrorCode'] ?? aadharVault['error_code']) 
            : null;
        final refNum = aadharVault is Map ? aadharVault['aadharRefNum'] : null;

        if ((errorCode == '000' || errorCode == 0) && refNum != null) {
          aadhaarRefNumber = refNum.toString();
          otpVerified = true;
          otpVrfy = false;

          _handleVaultVerificationSuccess(
            otpValidation,
            aadharVault is Map<String, dynamic> ? aadharVault : {},
            aadhaarRefNumber!,
          );
        } else {
          throw Exception('Aadhaar Vault failed - ErrorCode: $errorCode');
        }
      } else {
        throw Exception('Aadhaar Vault returned null data');
      }
    } catch (e) {
      debugPrint(' triggerAadharVault Error: $e');
      _handleVerificationError(
        'Aadhaar ${ConstantVariable.verificationFaildString}',
      );
    } finally {
      if (!mounted) return;
      if (!otpVerified) {
        setState(() {
          _buttonStateManager.reset(widget.buttonProps.label);
        });
      }
    }
  }

  void _handleVaultVerificationSuccess(
    Map<String, dynamic> otpValidation,
    Map<String, dynamic> vaultData,
    String aadhaarRefNumber,
  ) {
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

  void _handleVerificationSuccess(String message, Response response) {
    if (!mounted) return;

    widget.onSuccess(response);
    setState(() {
      _buttonStateManager.setSuccess(ConstantVariable.verifiedString);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleVerificationError(String message) {
    if (!mounted) return;

    widget.onError(message);
    setState(() {
      _buttonStateManager.setError(ConstantVariable.failedString);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
            onPressed: (!_inputValidator.isValid ||
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
