import 'dart:io';
import 'dart:typed_data';
import 'package:yaml/yaml.dart';
import 'package:yemu/src/Client.dart';
import 'package:yemu/src/ClientRequest.dart';
import 'package:yemu/src/LocalDb.dart';
import 'package:yemu/src/responses/UserAdd.dart';
import 'package:yemu/src/responses/UserMessage.dart';
import 'package:yemu/src/responses/UserRemove.dart';
import 'package:yemu/src/types/ResponseTypes.dart';
import 'ServerResponse.dart';
import 'HTTPServer.dart';

class Server {
  late final net;
  late final http;
  YamlMap config;
  LocalDb db;
  Map<String, Client> clients = {};

  Server(this.config, this.db);

  void handleConnection(Socket socket) {
    socket.listen((Uint8List data) {
      ClientRequest request = ClientRequest(data);
      try {
        ResovableData parsed = request.parse();
        if (parsed is AuthData) handleAuthRequest(socket, parsed);
        if (parsed is UserMessageData) handleUserMessageRequest(socket, parsed);
      } catch (e) {
        print(e);
      }
    }, onDone: () {
      Client client = clients.values.firstWhere((element) => element.socket.remoteAddress.address == socket.remoteAddress.address);
      print('Client ${client?.username ?? 'NO USERNAME'} disconnected');
      if (client != null) {
        client.socket.close();
        clients.remove(client.id);
        ServerResponse response = UserRemove(client.username);
        broadcast(response.toJson());
      }
    }, onError: (e) {
      print(e);
      Client client = clients.values.firstWhere((element) => element.socket.remoteAddress.address == socket.remoteAddress.address);
      if (client != null) {
        client.socket.close();
        clients.remove(client.id);
        ServerResponse response = UserRemove(client.username);
        broadcast(response.toJson());
      }
    });
  }

  void handleAuthRequest(Socket socket, AuthData data) {
    Client client = Client(data.username, socket);
    if (clients.containsKey(client.id)) {
      client.send(ErrorResponse.fromType(ResponseTypes.AlreadyConnected).toJson());
    }
    for (Client client in clients.values) {
      if (client.socket.remoteAddress.address == socket.remoteAddress.address) {
        client.send(ErrorResponse.fromType(ResponseTypes.AlreadyConnected).toJson());
        break;
      }
    }
    clients[client.id] = client;
    ServerResponse response = UserAdd(client.username, clients.values.map((e) => e.username).toList());
    broadcast(response.toJson());
    client.send(ServerResponse.fromType(ResponseTypes.Accepted).toJson());
  }

  void handleUserMessageRequest(Socket socket, UserMessageData data) {
    Client client = clients.values.firstWhere((element) => element.socket.remoteAddress.address == socket.remoteAddress.address);
    if (client == null) {
      client.send(ErrorResponse.fromType(ResponseTypes.UserNotFound).toJson());
      return;
    }
    ServerResponse response = UserMessage(client.username, data.message);
    broadcast(response.toJson());
  }

  Future<void> broadcast(message) async {
    await Future.forEach(clients.values, (Client client) async {
      client.send(message);
    });
  }

  void start(String address, int port, Function callback, Function httpCallback) {
    net = ServerSocket.bind(address, port).then((ServerSocket server) {
      server.listen((Socket socket) {
        handleConnection(socket);
      });
      callback();
    });
    http = HTTPServer(db, address, config['http_port']);
    config['http_enabled'] ? http.start(address, config['http_port'], httpCallback) : null;
  }
}