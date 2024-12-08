import 'package:finale/util/constants.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';

const _okErrorCodes = {/* Success: */ 0, /* No results: */ 1001};
const _limitExceededErrorCodes = {/* Request count: */ 3003, /* QpS: */ 3015};

extension ACRCloudResponseError on ACRCloudResponse {
  String? get errorMessage {
    final statusCode = status.code;
    if (!_okErrorCodes.contains(statusCode)) {
      return _limitExceededErrorCodes.contains(statusCode)
          ? rateLimitExceededMessage
          : status.msg;
    }

    return null;
  }
}
