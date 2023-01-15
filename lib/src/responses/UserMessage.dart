import '../ServerResponse.dart';
import '../types/ResponseTypes.dart';

class UserMessage extends ServerResponse {
  UserMessage(String username, String message)
      : super(ResponseTypes.UserMessage, {
    'username': username,
    'message': message,
  });
}