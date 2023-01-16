import '../ServerResponse.dart';
import '../types/ResponseTypes.dart';

class Accepted extends ServerResponse {
  Accepted(httpPort)
      : super(ResponseTypes.Accepted, {
        'httpPort': httpPort,
      });
}