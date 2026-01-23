import 'package:sysmo_verification/kyc_validation.dart';

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
    required this.isOffline
  });

  @override
  State<ConsentForm> createState() => _ConsoultFormState();
}

class _ConsoultFormState extends State<ConsentForm> {
  bool isChecked = false;
  String inputForm = '';
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Terms & Conditions"),
          backgroundColor: Colors.teal,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
      
                buildParagraph(
                  "The following definitions apply throughout this Agreement unless otherwise stated:",
                ),
      
                SizedBox(height: 10),
                buildParagraph(
                  'a) Any expression, which has not been defined in this Agreement but is defined in the General Clauses Act, 1897 shall have the same meaning thereof.',
                ),
      
                SizedBox(height: 10),
                buildParagraph(
                  "b) The reference to masculine gender shall be deemed to include reference to feminine gender and vice versa. The meaning of defined terms shall be equally applicable to both the singular and plural forms of the terms defined.",
                ),
                SizedBox(height: 10),
                buildParagraph(
                  "c) The word herein hereto, hereunder and the like mean and refer to this Agreement or any other document as a whole and not merely to the specific article, section, subsection, paragraph or clause in which the respective word appears.",
                ),
                SizedBox(height: 10),
      
                buildParagraph(
                  "d) The words including and include shall be deemed to be followed by the words without limitation.",
                ),
      
                SizedBox(height: 20),
      
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) => {
                        setState(() {
                          isChecked = value ?? false;
                        }),
                      },
                    ),
                    SizedBox(width: 10),
                    Text('I Agree terms & condition'),
                  ],
                ),
                
                SizedBox(height: 20),
                
                widget.aadhaarmethod == ConstantVariable.consentOTPString
                    ? ElevatedButton(
                        onPressed: () async {
                          if (isChecked == true) {
                            setState(() {
                              isLoading = true;
                            });
                            
                            try {
                              // Build OTP generation request
                              final requestBody = {
                                'aadharNumber': widget.aadhaarNumber,
                                'uniqueId': widget.leadId,
                                'token': widget.token
                              };
                              
                              final response = await KYCService().verify(
                                isOffline: widget.isOffline,
                                request: requestBody.toString(),
                                assetPath: widget.assetPath,
                                url: widget.url,
                              );
                              
                              debugPrint("OTP Generation Response: $response");
                              await Future.delayed(const Duration(seconds: 1));
      
                              if (response.toString().isNotEmpty) {
                                // Parse OtpGeneration response
                                final responseData = response.data;
                                final otpGeneration = responseData['OtpGeneration'];
                                
                                if (otpGeneration != null && otpGeneration['ErrorCode'] == '000') {
                                  final transactionId = otpGeneration['transactionId'];
                                  debugPrint("OTP Generation Success - TransactionId: $transactionId");
                                  
                                  setState(() {
                                    isLoading = false;
                                  });
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(ConstantVariable.consentOTPSendSuccessfullyString),
                                    ),
                                  );
                                  await Future.delayed(const Duration(seconds: 2));
      
                                  final optionOTPSheet = await showOtpBottomSheet(
                                    context,
                                    widget.aadhaarResponseassetspath!,
                                    widget.aadhaarResponseApiurl!,
                                    widget.aadhaarNumber,
                                    widget.leadId,
                                    widget.token,
                                    isOffline: widget.isOffline
                                  );
                                  await Future.delayed(const Duration(seconds: 1));
      
                                  debugPrint("OTP Verification Response: $optionOTPSheet");
                                } else {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  
                                  final errorStatus = otpGeneration?['ErrorStatus'] ?? ConstantVariable.consentOTPGendrateFailedString;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(errorStatus),
                                    ),
                                  );
                                }
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(ConstantVariable.consentOTPGendrateFailedString)),
                                );
                              }
                            } catch (error) {
                              setState(() {
                                isLoading = false;
                              });
                              debugPrint("OTP Generation Error: $error");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${error.toString()}')),
                              );
                            }
                          }
                        },
                        child: isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(ConstantVariable.consentOTPVerificationString),
                      )
                    : ElevatedButton(
                        onPressed: () async {},
                        child: Text(ConstantVariable.consentBioMetricString),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper UI Component for repeated text blocks
Widget buildParagraph(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Text(text, style: TextStyle(fontSize: 15, height: 1.4)),
  );
}
