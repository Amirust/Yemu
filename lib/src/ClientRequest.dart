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

class HandshakeData extends ResovableData {
  final String publicKey;

  HandshakeData(this.publicKey);
}

class AuthData extends ResovableData {
  final String username;
  final String? password;
  final String? serverPassword;

  AuthData(username, this.password, this.serverPassword) : username = utf8.decode(username.codeUnits);
}

class UserMessageData extends ResovableData {
  final String message;

  UserMessageData(this.message);
}

class ClientRequest {
  late String message;
  Server server;

  ClientRequest(Uint8List data, this.server) : message = utf8.decode(data);

  Future<ResovableData> parse(Client? client) async {
    if (client != null) message = await client.decrypt(message);
    final json = ResolvedJsonData.fromJson(jsonDecode(message));
    switch (json.type) {
      case RequestTypes.Handshake:
        if (json.data['publicKey'] == null) throw Exception('HANDSHAKE: No public key');
        return HandshakeData(json.data['publicKey']);
      case RequestTypes.Auth:
        if (json.data['username'] == null) throw Exception('AUTH: No username');
        return AuthData(json.data['username'], json.data['password'], json.data['serverPassword']);
      case RequestTypes.UserMessage:
        if (json.data['message'] == null) throw Exception('USER_MESSAGE: No message');
        print(json.data['message']);
        return UserMessageData(json.data['message']);
      default:
        throw Exception('Unknown request type');
    }
  }

  get data => message;
}