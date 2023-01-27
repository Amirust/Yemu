import 'package:yemu/src/Client.dart';
import 'package:yemu/src/ClientRequest.dart';
import 'package:yemu/src/responses/Accepted.dart';
import 'package:yemu/src/responses/UserAdd.dart';
import 'package:yemu/src/types/ResponseTypes.dart';
import 'package:yemu/src/ServerResponse.dart';
import '../../yemu.dart';


void handleAuthRequest(Client client, Server server, AuthData data) {
  for (Client clientIter in server.clients.values) {
    if (clientIter.username == data.username) {
      client.send(
          ErrorResponse.fromType(ResponseTypes.AlreadyConnected).toJson(),
          false);
      client.socket.close();
      break;
    }
  }

  server.clients[client.id]?.username = data.username;

  if (server.config['registration_required'] == true && (server.db.read()['users'][client.username] == null)) {
    client.send(ErrorResponse.fromType(ResponseTypes.UserNotRegistered).toJson(), false);
    client.socket.close();
    return;
  }
  if (data.password == null && server.config['registration_required'] == true) {
    client.send(ErrorResponse.fromType(ResponseTypes.UserPasswordRequired).toJson(), false);
    server.clients[client.id]?.username = ''; // Just dont ask lmao
    return;
  }
  if (server.config['registration_required'] == true && server.db.read()['users'][client.username]['password'] != data.password) {
    client.send(ErrorResponse.fromType(ResponseTypes.InvalidPassword).toJson(), false);
    server.clients[client.id]?.username = '';
    return;
  }

  ServerResponse accepted = Accepted(
      server.config['http_enabled'],
      server.config['http_port'],
      server.config['http_address'],
      client.generateAccessToken()
  );
  client.send(accepted.toJson(), false);
  ServerResponse response = UserAdd(client.username, server.clients.values.map((e) => e.username).toList());
  server.broadcast(response.toJson());
  print('Client ${client.username} connected');
}