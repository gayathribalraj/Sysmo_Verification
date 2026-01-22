import 'package:sysmo_verification/kyc_validation.dart';
import 'package:sysmo_verification/src/widget/kyc_verification.dart' hide OfflineVerificationHandler;

class KYCService extends KycVerification{
  Future<Response> verify({
    required bool isOffline,
    String? request,
    String? url,
    String? assetPath,
  }) async {
    try {
      if (isOffline && assetPath!.isNotEmpty) {
        return await verifyOffline(assetPath);
      } else if (!isOffline && url!.isNotEmpty) {
        // Parse request body and send as POST request
        dynamic requestData;
        if (request != null && request.isNotEmpty) {
          try {
            requestData = jsonDecode(request);
          } catch (e) {
            // If JSON decode fails, try to parse as string representation of map
            requestData = request;
          }
        }
        return await verifyOnlineWithData(url, requestData);
      } else {
        throw Exception(ConstantVariable.noDataProviderString);
      }
    } catch (error) {
      throw Exception(error.toString());
    }
    
  }
    
}

class KycVerification with VerificationMixin {
 @override
  Future<Response> verifyOffline(String assetPath) =>
      OfflineVerificationHandler.loadData(assetPath);

  @override
  Future<Response> verifyOnline(String url) async => ApiClient().callGet(url);

  @override
  Future<Response> verifyOnlineWithData(String url, dynamic data) async => 
      ApiClient().callPost(url, data: data);
}