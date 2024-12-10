import 'package:flutter_acrcloud/flutter_acrcloud.dart';

const _okErrorCodes = {/* Success: */ 0, /* No results: */ 1001};
const _limitExceededErrorCodes = {/* Request count: */ 3003, /* QpS: */ 3015};
const _noFingerprintCode = 2004;

extension ACRCloudResponseError on ACRCloudResponse {
  String? get errorMessage {
    final statusCode = status.code;

    if (_okErrorCodes.contains(statusCode)) {
      return null;
    }

    if (_limitExceededErrorCodes.contains(statusCode)) {
      return 'Too many people are using Finale right now. Please try again '
          'later.';
    }

    if (statusCode == _noFingerprintCode) {
      return 'No sound detected.';
    }

    return status.msg;
  }
}
