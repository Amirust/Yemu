import '../ServerResponse.dart';
import '../types/ResponseTypes.dart';

class UserAdd extends ServerResponse {
  UserAdd(String username, List<String> allUsers)
      : super(ResponseTypes.UserAdd, {
    'username': username,
    'allUsers': allUsers,
  });
}