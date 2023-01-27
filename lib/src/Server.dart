import 'dart:io';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'dart:typed_data';
import 'package:diffie_hellman/diffie_hellman.dart';
import 'package:yaml/yaml.dart';
import 'package:yemu/src/Client.dart';
import 'package:yemu/src/ClientRequest.dart';
import 'package:yemu/src/LocalDb.dart';
import 'package:yemu/src/instructions/handleAuthRequest.dart';
import 'package:yemu/src/instructions/handleUserMessageRequest.dart';
import 'package:yemu/src/responses/UserRemove.dart';
import 'package:yemu/src/types/ResponseTypes.dart';
import 'ServerResponse.dart';
import 'HTTPServer.dart';
import 'instructions/handleHandshake.dart';

class Server {
  late final void net;
  late final HTTPServer http;
  YamlMap config;
  LocalDb db;
  Map<String, Client> clients = {};
  DhPkcs3Engine dhEngine = DhPkcs3Engine.fromGroup(5);

  Server(this.config, this.db) {
    dhEngine.generateKeyPair();
  }

  void handleConnection(Socket socket) {
    try {
      socket.listen((Uint8List data) async {
        ClientRequest request = ClientRequest(data, this);
        try {
          String id = md5.convert(socket.remoteAddress.address.toString().codeUnits).toString();
          Client? client = clients[id];
          ResovableData parsed = await request.parse(client);
          if (parsed is HandshakeData) return handleHandshakeRequest(this, socket, parsed);
          if (client == null) throw Exception('REQUIRED_HANDSHAKE');
          if (parsed is AuthData) return handleAuthRequest(client, this, parsed);
          if (parsed is UserMessageData) return handleUserMessageRequest(this, socket, parsed);
        } catch (e) {
          if (e.toString().startsWith('Exception: AUTH')) {
            socket.write(ErrorResponse(ResponseTypes.AuthDataInvalid, e.toString()).toJson());
          }
          if (e.toString().startsWith('Exception: USER_MESSAGE')) {
            socket.write(ErrorResponse.fromType(ResponseTypes.MessageDataInvalid).toJson());
          }
          if (e.toString().startsWith('Exception: HANDSHAKE')) {
            socket.write(ErrorResponse.fromType(ResponseTypes.HandshakeDataInvalid).toJson());
          }
          if (e.toString().startsWith('Exception: REQUIRED_HANDSHAKE')) {
            socket.write(ErrorResponse.fromType(ResponseTypes.HandshakeRequired).toJson());
          }
          print(e);
        }
      }, onDone: () {
        Client? client = clients.values.firstWhereOrNull((element) => element.socket.remoteAddress.address == socket.remoteAddress.address);
        print('Client ${client?.username ?? 'NO USERNAME'} disconnected');
        if (client != null) {
          client.socket.close();
          clients.remove(client.id);
          ServerResponse response = UserRemove(client.username);
          broadcast(response.toJson());
        }
      }, onError: (e) {
        print(e);
        Client? client = clients.values.firstWhereOrNull((element) => element.socket.remoteAddress.address == socket.remoteAddress.address);
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
    net = ServerSocket.bind(address, port).then((ServerSocket server) {
      server.listen((Socket socket) {
        handleConnection(socket);
      });
      callback();
    });
    if (config['http_enabled'] == false) return;

    http = HTTPServer(db, clients, address, config['http_port']);
    http.start(address, config['http_port'], httpCallback);
  }
}
