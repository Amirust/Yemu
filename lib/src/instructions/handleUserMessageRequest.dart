import 'dart:io';
import 'package:yemu/src/Client.dart';
import 'package:yemu/src/ClientRequest.dart';
import 'package:yemu/src/responses/UserMessage.dart';
import 'package:yemu/src/types/ResponseTypes.dart';
import 'package:yemu/src/ServerResponse.dart';

import '../../yemu.dart';

void handleUserMessageRequest(Server server, SecureSocket socket, UserMessageData data) {
  Client client = server.clients.values.firstWhere((element) => element.socket.remoteAddress.address == socket.remoteAddress.address);
  if (client == null) {
    client.send(ErrorResponse.fromType(ResponseTypes.UserNotFound).toJson());
    return;
  }
  ServerResponse response = UserMessage(client.username, data.message);
  server.broadcast(response.toJson());
}