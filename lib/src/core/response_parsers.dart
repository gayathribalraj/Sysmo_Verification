/*
  @author   : Gayathri
  @created  : 08/11/2025
  @desc     : Response parser interface and implementations for different verification types
*/

import 'package:sysmo_verification/kyc_validation.dart';

/// Abstract parser for verification responses
abstract class ResponseParser {
  /// Parse online API response and return success status
  bool parseOnlineResponse(dynamic responseData);

  /// Parse offline asset response and return success status
  bool parseOfflineResponse(dynamic responseData);
}

/// Parser for Voter ID verification responses
class VoterResponseParser implements ResponseParser {
  @override
  bool parseOnlineResponse(dynamic responseData) {
    try {
      return responseData[ConstantVariable.status] == ConstantVariable.camelSuccess &&
          responseData[ConstantVariable.responseCode] == ConstantVariable.statusCode200;
    } catch (e) {
      return false;
    }
  }

  @override
  bool parseOfflineResponse(dynamic responseData) {
    try {
      final decodedResponse = jsonDecode(responseData[ConstantVariable.capitalResponse]);
      final status = decodedResponse['ursh']?[ConstantVariable.status]?.toString().toUpperCase();
      final responseCode = decodedResponse['ursh']?[ConstantVariable.responseCode]?.toString();
      return status == ConstantVariable.camelSuccess && responseCode == ConstantVariable.statusCode200;
    } catch (e) {
      return false;
    }
  }
}

/// Parser for PAN verification responses
class PanResponseParser implements ResponseParser {
  @override
  bool parseOnlineResponse(dynamic responseData) {
    try {
      return responseData[ConstantVariable.status] == ConstantVariable.camelSuccess &&
          responseData[ConstantVariable.responseCode] == ConstantVariable.statusCode200;
    } catch (e) {
      return false;
    }
  }

  @override
  bool parseOfflineResponse(dynamic responseData) {
    try {
      final panValidation = responseData["PanValidation"];
      return responseData["Success"] == true &&
          panValidation != null &&
          panValidation[ConstantVariable.lowerSuccess] == true;
    } catch (e) {
      return false;
    }
  }
}

/// Parser for GST verification responses
class GstResponseParser implements ResponseParser {
  @override
  bool parseOnlineResponse(dynamic responseData) {
    try {
      final gstResp = responseData["gstResp"];
      final statusCode = gstResp?[ConstantVariable.responseData]?["status_code"]?.toString();
      return gstResp?[ConstantVariable.lowerSuccess] == true && statusCode == ConstantVariable.statusCode101;
    } catch (e) {
      return false;
    }
  }

  @override
  bool parseOfflineResponse(dynamic responseData) => parseOnlineResponse(responseData);
}

/// Parser for Passport verification responses
class PassportResponseParser implements ResponseParser {
  @override
  bool parseOnlineResponse(dynamic responseData) {
    try {
      final passportResp = responseData["passportResp"];
      final statusCode = passportResp?[ConstantVariable.responseData]?["status_code"]?.toString();
      return passportResp?[ConstantVariable.lowerSuccess] == true && statusCode == ConstantVariable.statusCode101;
    } catch (e) {
      return false;
    }
  }

  @override
  bool parseOfflineResponse(dynamic responseData) => parseOnlineResponse(responseData);
}

/// Factory for creating response parsers
class ResponseParserFactory {
  static ResponseParser create(VerificationType type) {
    return switch (type) {
      VerificationType.voter => VoterResponseParser(),
      VerificationType.pan => PanResponseParser(),
      VerificationType.gst => GstResponseParser(),
      VerificationType.passport => PassportResponseParser(),
      VerificationType.aadhaar => VoterResponseParser(), // Default
    };
  }
}
