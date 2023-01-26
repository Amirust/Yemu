import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'dart:math';

import 'package:yemu/src/ServerResponse.dart';
import 'package:yemu/src/types/ResponseTypes.dart';

class Client {
  String username;
  Socket socket;
  SecretKey secretKey;
  late String id;
  late String accessToken;

  Client(this.username, this.socket, this.secretKey) {
   id = md5.convert(utf8.encode(username)).toString();
   Timer.periodic(Duration(seconds: 10 * 60), (timer) {
     send(ServerResponse(ResponseTypes.UpdateAccessToken, {'accessToken': generateAccessToken()}).toJson());
   });
  }

  String generateAccessToken() {
    List<int> bytes = List.generate(8, (index) => Random().nextInt(256));
    accessToken = base64.encode(bytes) + base64.encode(sha1.convert(utf8.encode(username)).bytes);
    return accessToken;
  }

  Future<String> encrypt(String message) async {
    List<int> iv = List.generate(16, (index) => 0);
    AesCtr aesCtr = AesCtr.with256bits(macAlgorithm: MacAlgorithm.empty);
    SecretBox encrypted = await aesCtr.encrypt(
      utf8.encode(message),
      secretKey: secretKey,
      nonce: iv,
    );
    return base64.encode(encrypted.cipherText);
  }

  Future<String> decrypt(String message) async {
    List<int> iv = List.generate(16, (index) => 0);
    AesCtr aesCtr = AesCtr.with256bits(macAlgorithm: MacAlgorithm.empty);
    SecretBox encrypted = SecretBox(base64.decode(message), nonce: iv, mac: Mac.empty);
    return utf8.decode(await aesCtr.decrypt(
      encrypted,
      secretKey: secretKey
    ));
  }

  void send(String message, [bool encryptMessage = true]) {
    if (encryptMessage) {
      encrypt(message).then((value) {
        socket.write(value);
      });
      return;
    }
    socket.write(message);
  }
}