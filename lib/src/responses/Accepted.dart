import '../ServerResponse.dart';
import '../types/ResponseTypes.dart';

class Accepted extends ServerResponse {
  Accepted(httpPort, String publicKey)
      : super(ResponseTypes.Accepted, {
        'httpPort': httpPort,
        'publicKey': publicKey,
      });
}