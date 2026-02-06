/*
  @author   : Gayathri
  @created  : 08/11/2025
  @desc     : Refactored OTP bottom sheet widget
*/

import 'dart:async';
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
    if (resendTimer.value > 0 || isResending.value) return;
    if (!mounted) return;

    isResending.value = true;

    // Save reference before async operation to avoid deactivated widget issues
    final currentContext = context;

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

       await showDialog(
          context: currentContext,
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

      await  showDialog(
          context: currentContext,
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

    await  showDialog(
        context: currentContext,
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.35,
        top: 10,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button row
          Align(
            alignment: Alignment.topRight,
            child: ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (context, loading, _) {
                return IconButton(
                  onPressed: loading
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: SysmoAlert.failure(
                                message:
                                    'if you close now, the verification will be incomplete.',
                                onButtonPressed: () {
                                  Navigator.pop(dialogContext);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        },
                  icon: Icon(
                    Icons.close,
                    color: loading ? Colors.grey.shade300 : Colors.grey,
                  ),
                );
              },
            ),
          ),
          const Text(
            'Enter OTP',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      fieldWidth: 45,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      enabled: !loading,
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _handleOtpVerification,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: const Color.fromARGB(255, 3, 9, 110),
              foregroundColor: Colors.white,
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (context, loading, _) {
                return loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text(ConstantVariable.verifyOTPString);
              },
            ),
          ),
          const SizedBox(height: 16),
          // Resend OTP button with timer
          ValueListenableBuilder<int>(
            valueListenable: resendTimer,
            builder: (context, timerValue, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: isResending,
                builder: (context, resending, _) {
                  final bool canResend = timerValue == 0 && !resending;
                  return TextButton(
                    onPressed: canResend ? _handleResendOtp : null,
                    child: resending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color.fromARGB(255, 3, 9, 110),
                            ),
                          )
                        : Text(
                            timerValue > 0
                                ? 'Resend OTP in ${timerValue}s'
                                : 'Resend OTP',
                            style: TextStyle(
                              color: canResend
                                  ? const Color.fromARGB(255, 3, 9, 110)
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
        ],
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
  // BuildContext ctx = context;
  return await showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.25,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.qr_code_scanner),
              title: Text(ConstantVariable.consentBioMetricString),
              onTap: () {
                Navigator.pop(context, 'bio');
              },
            ),
            ListTile(
              leading: Icon(Icons.text_fields),
              title: Text(ConstantVariable.otpString),
              onTap: () {
                Navigator.pop(context, 'otp');
              },
            ),
          ],
        ),
      );
    },
  );
}
