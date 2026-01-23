/*
  @author   : Gayathri
  @created  : 08/11/2025
  @desc     : Refactored OTP bottom sheet widget
*/

import 'package:sysmo_verification/kyc_validation.dart';

/// OTP bottom sheet dialog
class OtpSheet extends StatefulWidget {
  final String assetPath;
  final String url;
  final dynamic isOffline;
  final String aadhaarNumber;
  final String leadId;
  final String token;

  const OtpSheet({
    super.key,
    required this.assetPath,
    required this.url,
    this.isOffline ,
    required this.aadhaarNumber,
    required this.leadId,
    required this.token,
  });

  @override
  State<OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<OtpSheet> {
  late String otpPin;
  late ValueNotifier<bool> isLoading;

  @override
  void initState() {
    super.initState();
    otpPin = '';
    isLoading = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    isLoading.dispose();
    super.dispose();
  }

  Future<void> _handleOtpVerification() async {
    if (otpPin.length != 6) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Build OTP verification request
      final requestBody = {
        'otp': otpPin,
        'uid': widget.aadhaarNumber,
        'uniqueId': widget.leadId,
        'token': widget.token
      };

      final response = await KYCService().verify(
        isOffline: widget.isOffline,
        request: jsonEncode(requestBody),
        assetPath: widget.assetPath,
        url: widget.url,
      );

      isLoading.value = false;

      if (mounted) {
        // Parse otpValidationNew response
        final responseData = response.data;
        final otpValidation = responseData['otpValidationNew'];
        debugPrint("OTP Validation Response Data: $responseData");
        
        if (otpValidation != null && 
            otpValidation['ErrorCode'] == '000' && 
            otpValidation['Status'] == 'Y') {
          
          final kycDetails = otpValidation['KycDetails'];
          final transactionId = otpValidation['TransactionId'];
         
          
          debugPrint(" OTP Verification Success");
          debugPrint("TransactionId: $transactionId");
          debugPrint("Name: ${kycDetails?['name']}");
          debugPrint("KycDetails: $kycDetails");
          
          // Return response with KycDetails
          if (mounted) {
            Navigator.pop(context);
            Navigator.pop(context, response);
          }
        } else {
          final errorStatus = otpValidation?['ErrorStatus'] ?? 'OTP verification failed';
          final errorCode = otpValidation?['ErrorCode'] ?? 'Unknown error';
          
          debugPrint(" OTP Verification Failed");
          debugPrint("ErrorCode: $errorCode");
          debugPrint("ErrorStatus: $errorStatus");
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$errorStatus'),
                backgroundColor: Colors.black,
              ),
            );
          }
        }
      }
    } catch (e) {
      isLoading.value = false;
      if (mounted) {
        debugPrint("OTP Verification Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${ConstantVariable.otpString} ${ConstantVariable.verificationFaildString}: $e'),
            duration: const Duration(seconds: 4),
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

        top: 30,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enter OTP',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          OtpTextField(
            numberOfFields: 6,
            showFieldAsBox: true,
            fieldWidth: 45,
            filled: true,
            fillColor: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            onCodeChanged: (value) {
              otpPin = value;
            },
            onSubmit: (value) {
              otpPin = value;
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
  dynamic cryptoService, {
  dynamic isOffline
}) async {
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => OtpSheet(
      assetPath: assetPath,
      url: url,
      isOffline: isOffline,
      aadhaarNumber: aadhaarNumber,
      leadId: leadId,
      token: cryptoService,
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

