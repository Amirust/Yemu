import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:yemu/src/types/RequestTypes.dart';
import 'dart:convert';

abstract class ResolvedData<T> {
  late final RequestTypes type;
  late final T data;
}

class ResolvedJsonData<T> implements ResolvedData<T> {
  RequestTypes type;
  T data;

  ResolvedJsonData({
    required this.type,
    required this.data,
  });

  factory ResolvedJsonData.fromJson(Map<String, dynamic> json) {
    return ResolvedJsonData(
      type: RequestTypes.values[json['type']],
      data: json['data'],
    );
  }
}

abstract class ResovableData {}

class AuthData extends ResovableData {
  final String username;
  final String? password;
  final String? serverPassword;

  AuthData(username, password, serverPassword) : username = utf8.decode(username.codeUnits), password = password, serverPassword = serverPassword;
}

class UserMessageData extends ResovableData {
  final String message;

  UserMessageData(message) : message = utf8.decode(message.codeUnits);
}

class ClientRequest {
  late String message;

  ClientRequest(Uint8List data) : message = String.fromCharCodes(data);

  ResovableData parse() {
    final json = ResolvedJsonData.fromJson(jsonDecode(message));
    switch (json.type) {
      case RequestTypes.Auth:
        if (json.data['username'] == null) throw Exception('Invalid auth data');
        return AuthData(json.data['username'], json.data['password'], json.data['serverPassword']);
      case RequestTypes.UserMessage:
        if (json.data['message'] == null) throw Exception('Invalid user message data');
        return UserMessageData(json.data['message']);
      default:
        throw Exception('Unknown request type');
    }
  }

  get data => message;
}