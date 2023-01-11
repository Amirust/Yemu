import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class Client {
  String username;
  Socket socket;
  late String id;

  Client(this.username, this.socket) {
   id = md5.convert(utf8.encode(username)).toString();
  }

  void send(String message) {
    socket.write(message);
  }
}