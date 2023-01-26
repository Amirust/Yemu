import 'dart:typed_data';
import 'package:yemu/src/types/RequestTypes.dart';
import 'dart:convert';

import '../yemu.dart';
import 'Client.dart';

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
  final String publicKey;

  AuthData(username, this.password, this.serverPassword, this.publicKey) : username = utf8.decode(username.codeUnits);
}

class UserMessageData extends ResovableData {
  final String message;

  UserMessageData(message) : message = utf8.decode(message.codeUnits);
}

class ClientRequest {
  late String message;
  Server server;

  ClientRequest(Uint8List data, this.server) : message = utf8.decode(data);

  Future<ResovableData> parse(Client? client) async {
    if (client != null) message = await client.decrypt(message);
    final json = ResolvedJsonData.fromJson(jsonDecode(message));
    switch (json.type) {
      case RequestTypes.Auth:
        if (json.data['username'] == null) throw Exception('AUTH: No username');
        if (json.data['publicKey'] == null) throw Exception('AUTH: No public key');
        return AuthData(json.data['username'], json.data['password'], json.data['serverPassword'], json.data['publicKey']);
      case RequestTypes.UserMessage:
        if (json.data['message'] == null) throw Exception('USER_MESSAGE: No message');
        return UserMessageData(json.data['message']);
      default:
        throw Exception('Unknown request type');
    }
  }

  get data => message;
}