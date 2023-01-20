import 'dart:io';
import 'package:yemu/src/Client.dart';
import 'package:yemu/src/ClientRequest.dart';
import 'package:yemu/src/responses/Accepted.dart';
import 'package:yemu/src/responses/UserAdd.dart';
import 'package:yemu/src/types/ResponseTypes.dart';
import 'package:yemu/src/ServerResponse.dart';
import '../../yemu.dart';


void handleAuthRequest(Server server, SecureSocket socket, AuthData data) {
  Client client = Client(data.username, socket);
  if (server.clients.containsKey(client.id)) {
    client.send(ErrorResponse.fromType(ResponseTypes.AlreadyConnected).toJson());
  }
  for (Client client in server.clients.values) {
    if (client.socket.remoteAddress.address == socket.remoteAddress.address) {
      client.send(ErrorResponse.fromType(ResponseTypes.AlreadyConnected).toJson());
      break;
    }
  }
  server.clients[client.id] = client;
  ServerResponse response = UserAdd(client.username, server.clients.values.map((e) => e.username).toList());
  server.broadcast(response.toJson());
  ServerResponse accepted = Accepted(server.config['http_enabled'] ? server.config['http_port'] : null);
  client.send(accepted.toJson());
  print('Client ${client.username} connected');
}