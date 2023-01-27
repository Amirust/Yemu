import '../ServerResponse.dart';
import '../types/ResponseTypes.dart';

class Handshake extends ServerResponse {
  Handshake(String publicKey)
      : super(ResponseTypes.Handshake, {
        'publicKey': publicKey
      });
}