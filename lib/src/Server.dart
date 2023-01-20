import 'dart:io';
import 'dart:typed_data';
import 'package:yaml/yaml.dart';
import 'package:yemu/src/Client.dart';
import 'package:yemu/src/ClientRequest.dart';
import 'package:yemu/src/LocalDb.dart';
import 'package:yemu/src/instructions/handleAuthRequest.dart';
import 'package:yemu/src/instructions/handleUserMessageRequest.dart';
import 'package:yemu/src/responses/UserRemove.dart';
import 'ServerResponse.dart';
import 'HTTPServer.dart';

class Server {
  late final net;
  late final HTTPServer http;
  YamlMap config;
  LocalDb db;
  Map<String, Client> clients = {};

  Server(this.config, this.db);

  void handleConnection(SecureSocket socket) {
    try {
      socket.listen((Uint8List data) {
        ClientRequest request = ClientRequest(data);
        try {
          ResovableData parsed = request.parse();
          if (parsed is AuthData) handleAuthRequest(this, socket, parsed);
          if (parsed is UserMessageData) handleUserMessageRequest(this, socket, parsed);
        } catch (e) {
          print(e);
        }
      }, onDone: () {
        Client client = clients.values.firstWhere((element) =>
        element.socket.remoteAddress.address == socket.remoteAddress.address);
        print('Client ${client?.username ?? 'NO USERNAME'} disconnected');
        if (client != null) {
          client.socket.close();
          clients.remove(client.id);
          ServerResponse response = UserRemove(client.username);
          broadcast(response.toJson());
        }
      }, onError: (e) {
        print(e);
        Client client = clients.values.firstWhere((element) =>
        element.socket.remoteAddress.address == socket.remoteAddress.address);
        if (client != null) {
          client.socket.close();
          clients.remove(client.id);
          ServerResponse response = UserRemove(client.username);
          broadcast(response.toJson());
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> broadcast(message) async {
    await Future.forEach(clients.values, (Client client) async {
      client.send(message);
    });
  }

  void start(String address, int port, Function callback, Function httpCallback) {
    SecurityContext context = SecurityContext();
    context.useCertificateChain(config['cert_path']);
    context.usePrivateKey(config['key_path']);
    net = SecureServerSocket.bind(address, port, context).then((SecureServerSocket server) {
      server.listen((SecureSocket socket) {
        handleConnection(socket);
      });
      callback();
    });
    http = HTTPServer(db, clients, context, address, config['http_port']);
    config['http_enabled'] ? http.start(address, config['http_port'], httpCallback) : null;
  }
}