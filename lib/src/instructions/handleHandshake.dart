import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:yemu/src/Client.dart';
import 'package:yemu/src/ClientRequest.dart';
import 'package:yemu/src/responses/Handshake.dart';
import 'package:yemu/src/ServerResponse.dart';
import '../../yemu.dart';


void handleHandshakeRequest(Server server, Socket socket, HandshakeData data) {
  BigInt key = BigInt.parse(data.publicKey, radix: 16);
  SecretKey secretKey = SecretKey(server.dhEngine.computeSecretKey(key).toRadixString(16).substring(0, 32).codeUnits);
  Client client = Client.fromHandshake(socket, secretKey);

  server.clients[client.id] = client;
  ServerResponse handshake = Handshake(server.dhEngine.publicKey.toRadixString(16));
  client.send(handshake.toJson(), false);
  print('Client ${socket.remoteAddress.address} handshake success');
}