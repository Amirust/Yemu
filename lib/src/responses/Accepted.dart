import '../ServerResponse.dart';
import '../types/ResponseTypes.dart';

class Accepted extends ServerResponse {
  Accepted(httpEnabled, httpPort, httpHost, String publicKey)
      : super(ResponseTypes.Accepted, {
        'http': httpEnabled ? '${httpHost}${httpPort == null || httpPort == 80 || httpPort == 443 ? '' : ':$httpPort'}' : null,
        'publicKey': publicKey,
      });
}