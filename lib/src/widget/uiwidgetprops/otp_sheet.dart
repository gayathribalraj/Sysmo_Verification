/*
  @author   : Gayathri
  @created  : 08/11/2025
  @desc     : Refactored OTP bottom sheet widget
*/

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:sysmo_verification/kyc_validation.dart';
import 'package:sysmo_verification/src/widget/uiwidgetprops/sysmo_alert.dart';

/// OTP bottom sheet dialog
class OtpSheet extends StatefulWidget {
  final String assetPath;
  final String url;
  final bool isOffline;
  final String aadhaarNumber;
  final String leadId;
  final String token;
  final String aadharvaultlookupassetpath;
  final String aadharvaultlookupapiurl;
  final String aadharvaultassetpath;
  final String aadharvaultApiurl;
  final String otpGenerateAssetPath;
  final String otpGenerateApiUrl;

  const OtpSheet({
    super.key,
    required this.assetPath,
    required this.url,
    this.isOffline = false,
    required this.aadhaarNumber,
    required this.leadId,
    required this.token,
    required this.aadharvaultlookupassetpath,
    required this.aadharvaultlookupapiurl,
    required this.aadharvaultassetpath,
    required this.aadharvaultApiurl,
    required this.otpGenerateAssetPath,
    required this.otpGenerateApiUrl,
  });

  @override
  State<OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<OtpSheet> {
  late String otpPin;
  late ValueNotifier<bool> isLoading;
  late ValueNotifier<int> resendTimer;
  late ValueNotifier<bool> isResending;
  late ValueNotifier<int> otpFieldKey;
  Timer? _timer;

  // Theme colors
  static const Color _primaryColor = Color(0xFF009688);
  static const Color _primaryDark = Color(0xFF00796B);
  static const Color _surfaceColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    otpPin = '';
    isLoading = ValueNotifier<bool>(false);
    resendTimer = ValueNotifier<int>(30);
    isResending = ValueNotifier<bool>(false);
    otpFieldKey = ValueNotifier<int>(0);
    _startResendTimer();
  }

  void _resetOtpField() {
    otpPin = '';
    otpFieldKey.value++;
  }

  void _startResendTimer() {
    resendTimer.value = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleResendOtp() async {
    if (isResending.value) return;
    if (!mounted) return;

    isResending.value = true;

    try {
      final requestBody = {
        'aadharNumber': widget.aadhaarNumber,
        'uniqueId': widget.leadId,
        'token': widget.token,
      };

      final response = await KYCService().verify(
        isOffline: widget.otpGenerateApiUrl.isEmpty ? true : widget.isOffline,
        request: jsonEncode(requestBody),
        assetPath: widget.otpGenerateAssetPath,
        url: widget.otpGenerateApiUrl,
      );

      if (!mounted) return;

      final responseData = response.data;
      final otpGeneration = responseData['OtpGeneration'] ?? responseData;

      if (otpGeneration != null && otpGeneration['ErrorCode'] == '000') {
        debugPrint("OTP Resend Success");
        isResending.value = false;
        _startResendTimer();
        _resetOtpField();

        if (!mounted) return;
        await showDialog(
          context: context,
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
      } else {
        final errorStatus =
            otpGeneration?['ErrorStatus'] ?? 'OTP generation failed';
        debugPrint("OTP Resend Failed: $errorStatus");
        isResending.value = false;

        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (dialogContext) => Dialog(
            backgroundColor: Colors.transparent,
            child: SysmoAlert.failure(
              message: 'Resend OTP Failed',
              detailMessage: errorStatus,
              viewButtonText: 'View',
              onButtonPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("OTP Resend Error: $e");
      isResending.value = false;
      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          backgroundColor: Colors.transparent,
          child: SysmoAlert.failure(
            message: 'Resend OTP Failed',
            detailMessage: e.toString(),
            viewButtonText: 'View',
            onButtonPressed: () {
              Navigator.pop(dialogContext);
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    isLoading.dispose();
    resendTimer.dispose();
    isResending.dispose();
    otpFieldKey.dispose();
    super.dispose();
  }

  Future<void> _handleOtpVerification() async {
    if (otpPin.isEmpty || otpPin.length != 6) {
      isLoading.value = false;
      await showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          backgroundColor: Colors.transparent,
          child: SysmoAlert.failure(
            message: 'Please enter a valid 6-digit OTP',
            detailMessage: 'All OTP fields are required',
            onButtonPressed: () {
              Navigator.pop(dialogContext);
            },
          ),
        ),
      );
      return;
    }

    isLoading.value = true;

    try {
      // await Future.delayed(const Duration(seconds: 1));

      // Build OTP verification request
      final requestBody = {
        'otp': otpPin,
        'uid': widget.aadhaarNumber,
        'uniqueId': widget.leadId,
        'token': widget.token,
      };

      final response = await KYCService().verify(
        isOffline: widget.url.isEmpty ? true : widget.isOffline,
        request: jsonEncode(requestBody),
        assetPath: widget.assetPath,
        url: widget.url,
      );

      if (mounted) {
        // Parse otpValidationNew response - handle both nested and root level response
        final responseData = response.data;
        final otpValidation = responseData['otpValidationNew'] ?? responseData;
        debugPrint("OTP Validation Response Data: $responseData");

        if (otpValidation != null &&
            otpValidation['ErrorCode'] == '000' &&
            (otpValidation['Status'] == 'Y' ||
                otpValidation['Status'] == 'Success')) {
          final kycDetails = otpValidation['KycDetails'];
          final transactionId = otpValidation['TransactionId'];

          debugPrint(" OTP Verification Success");
          debugPrint("TransactionId: $transactionId");
          debugPrint("Name: ${kycDetails?['name']}");
          debugPrint("KycDetails: $kycDetails");

          // Check if aadharRefNum exists in OTP response
          final refNumFromOtp = otpValidation['aadharRefNum'];
          if (refNumFromOtp != null && refNumFromOtp.toString().isNotEmpty) {
            debugPrint("Using aadharRefNum from OTP response: $refNumFromOtp");
            isLoading.value = false;
            if (mounted) {
              await showDialog(
                context: context,
                builder: (dialogContext) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: SysmoAlert.success(
                    message:
                        "${ConstantVariable.otpString} ${ConstantVariable.verifiedSuccessfullyString}",
                    onButtonPressed: () {
                      Navigator.pop(dialogContext);
                    },
                  ),
                ),
              );
              if (mounted) {
                Navigator.pop(context, response);
              }
            }
            return;
          }

          // Keep loading and call vault operations
          debugPrint("Calling vault lookup API...");
          try {
            final vaultLookupRequest = {
              'aadharNumber': widget.aadhaarNumber,
              'uniqueId': widget.leadId,
              'token': widget.token,
            };

            final vaultLookupResponse = await KYCService().verify(
              isOffline: widget.aadharvaultlookupapiurl.isEmpty
                  ? true
                  : widget.isOffline,
              request: jsonEncode(vaultLookupRequest),
              assetPath: widget.aadharvaultlookupassetpath,
              url: widget.aadharvaultlookupapiurl,
            );

            debugPrint("Vault Lookup Response: ${vaultLookupResponse.data}");

            final vaultData = vaultLookupResponse.data;
            final vaultLookup = vaultData is Map
                ? (vaultData['VaultLoolUp'] ?? vaultData)
                : vaultData;
            final errorCode = vaultLookup is Map
                ? (vaultLookup['errorCode'] ?? vaultLookup['ErrorCode'])
                : null;
            final refNum = vaultLookup is Map
                ? vaultLookup['aadharRefNum']
                : null;

            if ((errorCode == '000' || errorCode == 0) && refNum != null) {
              debugPrint("Vault Lookup SUCCESS - RefNum: $refNum");
              final finalData = Map<String, dynamic>.from(response.data);
              finalData['aadharRefNum'] = refNum;
              finalData['vaultData'] = vaultLookup;
              final finalResponse = Response(
                requestOptions: response.requestOptions,
                data: finalData,
                statusCode: 200,
              );
              isLoading.value = false;
              if (mounted) {
                await showDialog(
                  context: context,
                  builder: (dialogContext) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: SysmoAlert.success(
                      message:
                          "${ConstantVariable.otpString} ${ConstantVariable.verifiedSuccessfullyString}",
                      onButtonPressed: () {
                        Navigator.pop(dialogContext);
                      },
                    ),
                  ),
                );
                if (mounted) {
                  Navigator.pop(context, finalResponse);
                }
              }
              return;
            }

            // If errorCode=2, trigger vault registration
            if (errorCode == '2' || errorCode == 2) {
              debugPrint(
                "Vault Lookup errorCode 2 - triggering vault registration",
              );
              final vaultRequest = {
                'aadharNumber': widget.aadhaarNumber,
                'uniqueId': widget.leadId,
                'token': widget.token,
              };

              final vaultResponse = await KYCService().verify(
                isOffline: widget.aadharvaultApiurl.isEmpty
                    ? true
                    : widget.isOffline,
                request: jsonEncode(vaultRequest),
                assetPath: widget.aadharvaultassetpath,
                url: widget.aadharvaultApiurl,
              );

              debugPrint("Vault Registration Response: ${vaultResponse.data}");

              final aadharVaultData = vaultResponse.data;
              final aadharVault = aadharVaultData is Map
                  ? (aadharVaultData['AadharValut'] ?? aadharVaultData)
                  : aadharVaultData;
              final vaultErrorCode = aadharVault is Map
                  ? (aadharVault['errorCode'] ?? aadharVault['ErrorCode'])
                  : null;
              final vaultRefNum = aadharVault is Map
                  ? aadharVault['aadharRefNum']
                  : null;

              if ((vaultErrorCode == '000' || vaultErrorCode == 0) &&
                  vaultRefNum != null) {
                debugPrint("Vault Registration SUCCESS - RefNum: $vaultRefNum");
                final finalData = Map<String, dynamic>.from(response.data);
                finalData['aadharRefNum'] = vaultRefNum;
                finalData['vaultData'] = aadharVault;
                final finalResponse = Response(
                  requestOptions: response.requestOptions,
                  data: finalData,
                  statusCode: 200,
                );
                isLoading.value = false;
                if (mounted) {
                  await showDialog(
                    context: context,
                    builder: (dialogContext) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: SysmoAlert.success(
                        message:
                            "${ConstantVariable.otpString} ${ConstantVariable.verifiedSuccessfullyString}",
                        onButtonPressed: () {
                          Navigator.pop(dialogContext);
                        },
                      ),
                    ),
                  );
                  if (mounted) {
                    Navigator.pop(context, finalResponse);
                  }
                }
                return;
              }
            }

            // Vault failed - still return OTP response
            debugPrint("Vault operations failed - returning OTP response");
            isLoading.value = false;
            if (mounted) {
              Navigator.pop(context, response);
            }
          } catch (e) {
            debugPrint("Vault operation error: $e");
            isLoading.value = false;
            if (mounted) {
              Navigator.pop(context, response);
            }
          }
        } else {
          // Get error message from response - check both nested and root level
          final errorStatus =
              otpValidation?['ErrorStatus'] ??
              responseData['ErrorStatus'] ??
              'OTP verification failed';
          final errorCode =
              otpValidation?['ErrorCode'] ??
              responseData['ErrorCode'] ??
              'Unknown error';

          debugPrint("OTP Verification Failed");
          debugPrint("ErrorCode: $errorCode");
          debugPrint("ErrorStatus: $errorStatus");

          isLoading.value = false;
          _resetOtpField();

          if (mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogcontext) => Dialog(
                backgroundColor: Colors.transparent,
                child: SysmoAlert.failure(
                  detailMessage:
                      "ErrorStatus: $errorStatus, ErrorCode: $errorCode",
                  message:
                      "${ConstantVariable.otpString} ${ConstantVariable.verificationFaildString}",
                  viewButtonText: "View",
                  onButtonPressed: () {
                    Navigator.pop(dialogcontext);
                  },
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      isLoading.value = false;
      _resetOtpField();
      if (mounted) {
        debugPrint("OTP Verification Error: $e");
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogcontext) => Dialog(
            backgroundColor: Colors.transparent,
            child: SysmoAlert.failure(
              detailMessage: "$e",
              message:
                  "${ConstantVariable.otpString} ${ConstantVariable.verificationFaildString}",
              viewButtonText: "View",
              onButtonPressed: () {
                Navigator.pop(dialogcontext);
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final isKeyboardOpen = keyboardInset > 0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Container(
        constraints: BoxConstraints(
          minHeight: mediaQuery.size.height * (isKeyboardOpen ? 0.65 : 0.80),
          maxHeight: mediaQuery.size.height * 0.95,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header section
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primaryColor, _primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                        Icons.lock_outline,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'OTP Verification',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter the 6-digit code sent to your registered mobile number',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // OTP Input Fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Enter OTP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<int>(
                        valueListenable: otpFieldKey,
                        builder: (context, keyValue, _) {
                          return ValueListenableBuilder<bool>(
                            valueListenable: isLoading,
                            builder: (context, loading, _) {
                              return KeyedSubtree(
                                key: ValueKey(keyValue),
                                child: OtpTextField(
                                  numberOfFields: 6,
                                  showFieldAsBox: true,
                                  fieldWidth: 42,
                                  fieldHeight: 52,
                                  margin: const EdgeInsets.only(right: 6),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  filled: true,
                                  fillColor: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  borderColor: Colors.grey.shade300,
                                  focusedBorderColor: _primaryColor,
                                  enabled: !loading,
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryDark,
                                  ),
                                  onCodeChanged: (value) {
                                    otpPin = value;
                                  },
                                  onSubmit: (value) {
                                    otpPin = value;
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Resend OTP section
              ValueListenableBuilder<int>(
                valueListenable: resendTimer,
                // builder: (context, timerValue, _) {
                  builder: (context, _, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: isResending,
                    builder: (context, resending, _) {
                      // final bool canResend = timerValue == 0 && !resending;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive the code? ",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (resending)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _primaryColor,
                              ),
                            )
                          else
                            GestureDetector(
                              onTap:
                                  // canResend ?
                                  _handleResendOtp,
                              child:
                                  // timerValue > 0
                                  //     ? Container(
                                  //         padding: const EdgeInsets.symmetric(
                                  //           horizontal: 12,
                                  //           vertical: 6,
                                  //         ),
                                  //         decoration: BoxDecoration(
                                  //           color: Colors.grey.shade200,
                                  //           borderRadius: BorderRadius.circular(20),
                                  //         ),
                                  //         child: Row(
                                  //           mainAxisSize: MainAxisSize.min,
                                  //           children: [
                                  //             Icon(
                                  //               Icons.timer_outlined,
                                  //               size: 16,
                                  //               color: Colors.grey.shade600,
                                  //             ),
                                  //             const SizedBox(width: 4),
                                  //             Text(
                                  //               '${timerValue}s',
                                  //               style: TextStyle(
                                  //                 fontSize: 14,
                                  //                 fontWeight: FontWeight.w600,
                                  //                 color: Colors.grey.shade600,
                                  //               ),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       )
                                  Text(
                                    'Resend',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _primaryColor,
                                    ),
                                  ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isLoading,
                        builder: (context, loading, _) {
                          return OutlinedButton(
                            onPressed: loading
                                ? null
                                : () {
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: SysmoAlert.warning(
                                          message:
                                              'If you close now, the verification will be incomplete.',
                                          buttonText: 'Close Anyway',
                                          onButtonPressed: () {
                                            Navigator.pop(dialogContext);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: loading
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade400,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: loading
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Verify button
                    Expanded(
                      flex: 2,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isLoading,
                        builder: (context, loading, _) {
                          return ElevatedButton(
                            onPressed: loading ? null : _handleOtpVerification,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: _primaryColor,
                              disabledBackgroundColor: _primaryColor.withValues(
                                alpha: 0.6,
                              ),
                              foregroundColor: Colors.white,
                              elevation: loading ? 0 : 4,
                              shadowColor: _primaryColor.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.verified_user_outlined,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Verify OTP',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: mediaQuery.padding.bottom + (isKeyboardOpen ? 16 : 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Show OTP bottom sheet dialog
Future<dynamic> showOtpBottomSheet(
  BuildContext context,
  String assetPath,
  String url,
  String aadhaarNumber,
  String leadId,
  dynamic token, {
  dynamic isOffline,
  required String aadharvaultlookupassetpath,
  required String aadharvaultlookupapiurl,
  required String aadharvaultassetpath,
  required String aadharvaultApiurl,
  required String otpGenerateAssetPath,
  required String otpGenerateApiUrl,
}) async {
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => PopScope(
      canPop: false,
      child: OtpSheet(
        assetPath: assetPath,
        url: url,
        isOffline: isOffline,
        aadhaarNumber: aadhaarNumber,
        leadId: leadId,
        token: token,
        aadharvaultlookupassetpath: aadharvaultlookupassetpath,
        aadharvaultlookupapiurl: aadharvaultlookupapiurl,
        aadharvaultassetpath: aadharvaultassetpath,
        aadharvaultApiurl: aadharvaultApiurl,
        otpGenerateAssetPath: otpGenerateAssetPath,
        otpGenerateApiUrl: otpGenerateApiUrl,
      ),
    ),
  );
}

Future showValidateOptions(BuildContext context) async {
  const Color primaryColor = Color(0xFF009688);
  const Color primaryDark = Color(0xFF00796B);

  return await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            // Header
            const Text(
              'Select Verification Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Choose how you want to verify your Aadhaar',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 24),

            // Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Biometric option
                  Expanded(
                    child: _VerificationOptionCard(
                      icon: Icons.fingerprint,
                      title: 'Biometric',
                      subtitle: 'Use fingerprint',
                      primaryColor: primaryColor,
                      onTap: () => Navigator.pop(context, 'bio'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // OTP option
                  Expanded(
                    child: _VerificationOptionCard(
                      icon: Icons.sms_outlined,
                      title: 'OTP',
                      subtitle: 'Via mobile SMS',
                      primaryColor: primaryColor,
                      onTap: () => Navigator.pop(context, 'otp'),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
          ],
        ),
      );
    },
  );
}

/// Verification option card widget
class _VerificationOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color primaryColor;
  final VoidCallback onTap;

  const _VerificationOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: primaryColor),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
