import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';

class Client {
  String username;
  Socket socket;
  SecretKey secretKey;
  late String id;

  Client(this.username, this.socket, this.secretKey) {
   id = md5.convert(utf8.encode(username)).toString();
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