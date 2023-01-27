import '../ServerResponse.dart';
import '../types/ResponseTypes.dart';

class Accepted extends ServerResponse {
  Accepted(httpEnabled, httpPort, httpHost, accessToken)
      : super(ResponseTypes.Accepted, {
        'http': httpEnabled ? '${httpHost}${httpPort == null || httpPort == 80 || httpPort == 443 ? '' : ':$httpPort'}' : null,
        'accessToken': accessToken
      });
}