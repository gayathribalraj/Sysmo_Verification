import 'package:sysmo_verification/kyc_validation.dart';
import 'package:sysmo_verification/src/widget/uiwidgetprops/sysmo_alert.dart';

class ConsentForm extends StatefulWidget {
  final String aadhaarmethod;
  final String aadhaarNumber;
  final String assetPath;
  final String url;
  final String? aadhaarResponseassetspath;
  final String? aadhaarResponseApiurl;
  final String leadId;
  final String token;
  final bool isOffline;
  final String aadharvaultlookupassetpath;
  final String aadharvaultlookupapiurl;
  final String aadharvaultassetpath;
  final String aadharvaultApiurl;
  const ConsentForm({
    super.key,
    required this.aadhaarmethod,
    required this.aadhaarNumber,
    required this.assetPath,
    required this.url,
    this.aadhaarResponseassetspath,
    this.aadhaarResponseApiurl,
    required this.leadId,
    required this.token,
    required this.isOffline,
    required this.aadharvaultlookupassetpath,
    required this.aadharvaultlookupapiurl,
    required this.aadharvaultassetpath,
    required this.aadharvaultApiurl,
  });

  @override
  State<ConsentForm> createState() => _ConsoultFormState();
}

class _ConsoultFormState extends State<ConsentForm> {
  bool isChecked = false;
  bool isLoading = false;

  // Theme colors
  static const Color _primaryColor = Color(0xFF009688);
  static const Color _primaryDark = Color(0xFF00796B);
  static const Color _surfaceColor = Color(0xFFF5F5F5);
  static const Color _cardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: _surfaceColor,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 35,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: isLoading
                ? null
                : () {
                    Navigator.pop(context);
                  },
          ),
          title: const Text(
            "Terms & Conditions",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor, _primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Header section with icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor,_primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Please read and accept',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Terms card
                    Container(
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _primaryColor.withValues(alpha: 0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.gavel_rounded,
                                  color: _primaryColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Agreement Definitions',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Terms content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildIntroText(
                                  "The following definitions apply throughout this Agreement unless otherwise stated:",
                                ),
                                const SizedBox(height: 16),
                                _buildTermItem(
                                  'a',
                                  'Any expression, which has not been defined in this Agreement but is defined in the General Clauses Act, 1897 shall have the same meaning thereof.',
                                ),
                                _buildTermItem(
                                  'b',
                                  'The reference to masculine gender shall be deemed to include reference to feminine gender and vice versa. The meaning of defined terms shall be equally applicable to both the singular and plural forms of the terms defined.',
                                ),
                                _buildTermItem(
                                  'c',
                                  'The word herein hereto, hereunder and the like mean and refer to this Agreement or any other document as a whole and not merely to the specific article, section, subsection, paragraph or clause in which the respective word appears.',
                                ),
                                _buildTermItem(
                                  'd',
                                  'The words including and include shall be deemed to be followed by the words without limitation.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Consent checkbox card
                    Container(
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isChecked ? _primaryColor : Colors.grey.shade300,
                          width: isChecked ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isChecked
                                ? _primaryColor.withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isChecked = !isChecked;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isChecked ? _primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isChecked ? _primaryColor : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: isChecked
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  ConstantVariable.consentTermsConditionString,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: isChecked ? _primaryDark : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Button
                    _buildActionButton(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the introduction text widget
  Widget _buildIntroText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: Colors.grey.shade700,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  /// Builds a term item with letter indicator
  Widget _buildTermItem(String letter, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the action button based on aadhaar method
  Widget _buildActionButton() {
    final bool isOtpMethod =
        widget.aadhaarmethod == ConstantVariable.consentOTPString;
    final String buttonText = isOtpMethod
        ? ConstantVariable.consentOTPVerificationString
        : 'Proceed with Biometric';

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isChecked ? (isOtpMethod ? _handleOtpVerification : _handleBiometricVerification) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.grey.shade500,
          elevation: isChecked ? 4 : 0,
          shadowColor: _primaryColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOtpMethod ? Icons.sms_outlined : Icons.fingerprint,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Handles biometric verification
  Future<void> _handleBiometricVerification() async {
    final biometricResponse = Response(
      requestOptions: RequestOptions(path: ''),
      data: {
        'leadId': widget.leadId,
        'aadharNumber': widget.aadhaarNumber,
        'type': ConstantVariable.consentBioMetricString,
      },
      statusCode: 200,
    );
    Navigator.pop(context, biometricResponse);
  }

  /// Handles OTP verification flow
  Future<void> _handleOtpVerification() async {
    setState(() {
      isLoading = true;
    });

    try {
      debugPrint("requestBody here");
      // Build OTP generation request
      final requestBody = {
        'aadharNumber': widget.aadhaarNumber,
        'uniqueId': widget.leadId,
        'token': widget.token,
      };
      debugPrint("requestBody here $requestBody");

      final response = await KYCService().verify(
        isOffline: widget.isOffline,
        request: jsonEncode(requestBody),
        assetPath: widget.assetPath,
        url: widget.url,
      );

      debugPrint("OTP Generation Response: $response");

      if (response.toString().isNotEmpty) {
        // Parse OtpGeneration response - handle both nested and root level response
        final responseData = response.data;
        final otpGeneration = responseData['OtpGeneration'] ?? responseData;

        debugPrint("Parsed OtpGeneration: $otpGeneration");
        debugPrint("ErrorCode value: ${otpGeneration?['ErrorCode']}");
        debugPrint("ErrorCode type: ${otpGeneration?['ErrorCode']?.runtimeType}");

        // Check if ErrorCode is '000' for success
        final errorCode = otpGeneration?['ErrorCode']?.toString() ?? '';

        if (otpGeneration != null && errorCode == '000') {
          final transactionId = otpGeneration['transactionId'];
          debugPrint("OTP Generation Success - TransactionId: $transactionId");

          setState(() {
            isLoading = false;
          });

          // Show success alert and wait for OK button press
          if (!mounted) return;
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => Dialog(
              backgroundColor: Colors.transparent,
              child: SysmoAlert.success(
                message: 'OTP sent successfully',
                onButtonPressed: () {
                  Navigator.pop(dialogContext);
                },
              ),
            ),
          );

          if (!mounted) return;

          final optionOTPSheet = await showOtpBottomSheet(
            context,
            widget.aadhaarResponseassetspath!,
            widget.aadhaarResponseApiurl!,
            widget.aadhaarNumber,
            widget.leadId,
            widget.token,
            isOffline: widget.isOffline,
            aadharvaultlookupassetpath: widget.aadharvaultlookupassetpath,
            aadharvaultlookupapiurl: widget.aadharvaultlookupapiurl,
            aadharvaultassetpath: widget.aadharvaultassetpath,
            aadharvaultApiurl: widget.aadharvaultApiurl,
            otpGenerateAssetPath: widget.assetPath,
            otpGenerateApiUrl: widget.url,
          );

          debugPrint("OTP Verification Response: $optionOTPSheet");
          debugPrint("OTP Verification Response Data: ${optionOTPSheet?.data}");

          // Return the OTP verification response (vault operations done in OTP sheet)
          if (optionOTPSheet != null && mounted) {
            Navigator.pop(context, optionOTPSheet);
            return;
          }
        } else {
          if (!mounted) return;
          setState(() {
            isLoading = false;
          });

          // Get error message from response - check both nested and root level
          final errorStatus = otpGeneration?['ErrorStatus'] ??
              responseData['ErrorStatus'] ??
              ConstantVariable.consentOTPGendrateFailedString;
          final errCode = otpGeneration?['ErrorCode'] ??
              responseData['ErrorCode'] ??
              '';
          debugPrint(
            "OTP Generation Failed - ErrorCode: $errCode, ErrorStatus: $errorStatus",
          );

          if (!mounted) return;
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => Dialog(
              backgroundColor: Colors.transparent,
              child: SysmoAlert.failure(
                message: '${ConstantVariable.otpString} Generation Failed',
                detailMessage: 'ErrorCode: $errCode, ErrorStatus: $errorStatus',
                viewButtonText: 'View',
                onButtonPressed: () {
                  Navigator.pop(dialogContext);
                },
              ),
            ),
          );
        }
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => Dialog(
              backgroundColor: Colors.transparent,
              child: SysmoAlert.failure(
                message: ConstantVariable.consentOTPGendrateFailedString,
                onButtonPressed: () {
                  Navigator.pop(dialogContext);
                },
              ),
            ),
          );
        }
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      debugPrint("OTP Generation Error: $error");
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Dialog(
          backgroundColor: Colors.transparent,
          child: SysmoAlert.failure(
            message: 'Aadhaar Verification Failed',
            detailMessage: error.toString(),
            viewButtonText: 'View Log',
            onButtonPressed: () {
              Navigator.pop(dialogContext);
            },
          ),
        ),
      );
    }
  }
}
