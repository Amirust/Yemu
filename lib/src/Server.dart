import 'dart:io';
import 'dart:typed_data';
import 'package:yemu/src/Client.dart';
import 'package:yemu/src/ClientRequest.dart';
import 'package:yemu/src/types/ResponseTypes.dart';
import 'ServerResponse.dart';

class Server {
  late final net;
  Map<String, Client> clients = {};

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
        clients.removeWhere((key, value) => value.socket.remoteAddress.address == socket.remoteAddress.address);
        broadcast(ServerResponse(ResponseTypes.UserRemove, { 'username': client.username }).toJson());
      }
    }, onError: (e) {
      print(e);
      Client client = clients.values.firstWhere((element) => element.socket.remoteAddress.address == socket.remoteAddress.address);
      if (client != null) {
        client.socket.close();
        clients.removeWhere((key, value) => value.socket.remoteAddress.address == socket.remoteAddress.address);
        broadcast(ServerResponse(ResponseTypes.UserRemove, { 'username': client.username }).toJson());
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
    broadcast(ServerResponse(ResponseTypes.UserAdd, { 'username': client.username, 'allUsers': clients.values.map((e) => e.username).toList() }).toJson());
    client.send(ServerResponse.fromType(ResponseTypes.Accepted).toJson());
  }

  void handleUserMessageRequest(Socket socket, UserMessageData data) {
    Client client = clients.values.firstWhere((element) => element.socket.remoteAddress.address == socket.remoteAddress.address);
    if (client == null) {
      client.send(ErrorResponse.fromType(ResponseTypes.UserNotFound).toJson());
      return;
    }
    broadcast(ServerResponse(ResponseTypes.UserMessage, { 'message': data.message, 'username': client.username }).toJson());
  }

  Future<void> broadcast(message) async {
    await Future.forEach(clients.values, (Client client) async {
      client.send(message);
    });
  }

  void start(int port, Function callback) {
    net = ServerSocket.bind('localhost', port).then((ServerSocket server) {
      server.listen((Socket socket) {
        handleConnection(socket);
      });
      callback();
    });
  }
}