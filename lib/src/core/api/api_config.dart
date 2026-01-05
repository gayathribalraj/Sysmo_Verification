import 'package:sysmo_verification/kyc_validation.dart';

/// API endpoints loaded from .env file
/// These are lazy getters to ensure dotenv is initialized before access
String get voterId =>
    dotenv.env['voter_verification_endpoint'] ?? '';

String get panCard =>
    dotenv.env['pan_verification_endpoint'] ?? '';
