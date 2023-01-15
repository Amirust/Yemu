import '../ServerResponse.dart';
import '../types/ResponseTypes.dart';

class UserRemove extends ServerResponse {
  UserRemove(String username)
      : super(ResponseTypes.UserRemove, {
    'username': username,
  });
}