import 'dart:io';
import 'package:jaguar/jaguar.dart';
import 'package:yemu/src/LocalDb.dart';

class HTTPServer {
  late final Jaguar app;
  LocalDb _db;
  Map<String, dynamic> db;

  HTTPServer(this._db, address, port) : db = _db.read() {
    final app = Jaguar(port: port, address: address);

    app.get('/user/:username/avatar', (ctx) async {
      if (db['users'][ctx.pathParams['username']] == null) {
        return Response(statusCode: 404, body: 'User not found');
      }
      if (db['users'][ctx.pathParams['username']]['avatar'] == null) {
        return Response(statusCode: 404, body: 'User not found');
      }
      return StreamResponse.fromFile(File(db['users'][ctx.pathParams['username']]['avatar']));
    });
    app.post('/user/:username/avatar', (ctx) async {
      final file = (await ctx.bodyAsFormData()).values.first as FileFormField;
      if (!(file.contentType?.mimeType ?? '').startsWith('image/')) {
        return Response(statusCode: 400, body: 'Invalid file type');
      }
      String path = Directory.current.path + '/avatars/' + file.name + '.${file.contentType!.subType}';
      file.writeTo(path);
      db['users'][ctx.pathParams['username']]['avatar'] = path;
      _db.write();
      return Response(statusCode: 200, body: 'Avatar uploaded');
    });

    this.app = app;
  }

  void start(String address, int port, Function onStarted) async {
    app.serve().then((_) => onStarted());
  }
}