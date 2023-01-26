import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:yemu/src/Client.dart';
import 'package:yemu/src/ClientRequest.dart';
import 'package:yemu/src/responses/Accepted.dart';
import 'package:yemu/src/responses/UserAdd.dart';
import 'package:yemu/src/types/ResponseTypes.dart';
import 'package:yemu/src/ServerResponse.dart';
import '../../yemu.dart';


void handleAuthRequest(Server server, Socket socket, AuthData data) {
  BigInt key = BigInt.parse(data.publicKey, radix: 16);
  SecretKey secretKey = SecretKey(server.dhEngine.computeSecretKey(key).toRadixString(16).substring(0, 32).codeUnits);
  Client client = Client(data.username, socket, secretKey);
  if (server.clients.containsKey(client.id)) {
    client.send(ErrorResponse.fromType(ResponseTypes.AlreadyConnected).toJson(), false);
  }
  for (Client client in server.clients.values) {
    if (client.socket.remoteAddress.address == socket.remoteAddress.address) {
      client.send(ErrorResponse.fromType(ResponseTypes.AlreadyConnected).toJson(), false);
      break;
    }
  }
  server.clients[client.id] = client;
  ServerResponse accepted = Accepted(
      server.config['http_enabled'],
      server.config['http_port'],
      server.config['http_address'],
      server.dhEngine.publicKey.toRadixString(16)
  );
  client.send(accepted.toJson(), false);
  ServerResponse response = UserAdd(client.username, server.clients.values.map((e) => e.username).toList());
  server.broadcast(response.toJson());
  print('Client ${client.username} connected');
}