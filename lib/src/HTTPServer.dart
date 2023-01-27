import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:jaguar/jaguar.dart';
import 'package:yemu/src/Client.dart';
import 'package:yemu/src/LocalDb.dart';

class HTTPServer {
  late final Jaguar app;
  LocalDb _db;
  Map<String, Client> clients;
  Map<String, dynamic> db;

  HTTPServer(this._db, this.clients, address, port) : db = _db.read() {
    final app = Jaguar(port: port, address: address);

    app.post('/register', (ctx) async {
      final json = await ctx.bodyAsJsonMap();
      if (json['username'] == null || json['password'] == null) return Response(statusCode: 400, body: 'Bad request');
      String username = json['username'];
      String password = json['password'];
      if (db['users'][username] != null) return Response(statusCode: 400, body: 'User already exists');
      db['users'][username] = {};
      db['users'][username]['password'] = password;
      _db.write();
      return Response(statusCode: 200, body: 'User created');
    });

    app.get('/images/:image', (ctx) async {
      Client? client = checkAccessToken(ctx);
      if (client == null) {
        return Response(statusCode: 401, body: 'Unauthorized');
      }

      if (ctx.pathParams['image'] == null) return Response(statusCode: 404, body: 'Image not found');
      String image = ctx.pathParams.get('image')!;
      File file = File('images/$image');
      if (!file.existsSync()) {
        return Response(statusCode: 404, body: 'Image not found');
      }
      return StreamResponse.fromFile(file);
    });

    app.post('/images', (ctx) async {
      Client? client = checkAccessToken(ctx);
      if (client == null) {
        return Response(statusCode: 401, body: 'Unauthorized');
      }

      final form = await ctx.bodyAsFormData();
      if (form['username'] == null || form['image'] == null) return Response(statusCode: 400, body: 'Bad request');
      StringFormField username = form['username']! as StringFormField;
      BinaryFileFormField image = form['image']! as BinaryFileFormField;

      if (!clients.containsKey(md5.convert(utf8.encode(username.value)).toString())) return Response(statusCode: 400, body: 'User not connected');
      String ext = image.filename!.split('.').last;
      String filename = md5.convert(utf8.encode(username.value + ';${image.filename}')).toString();
      if (filename.length > 30) filename = filename.substring(0, 30);
      String path = Directory.current.path + '/images/' + filename + '.$ext';
      image.writeTo(path);
      return Response(statusCode: 200, body: { 'file': filename + '.$ext' });
    });

    app.get('/user/:username/avatar', (ctx) async {
      Client? client = checkAccessToken(ctx);
      if (client == null) {
        return Response(statusCode: 401, body: 'Unauthorized');
      }

      if (db['users'][ctx.pathParams['username']] == null) {
        return Response(statusCode: 404, body: 'User not found');
      }
      if (db['users'][ctx.pathParams['username']]['avatar'] == null) {
        return Response(statusCode: 404, body: 'User not have avatar');
      }
      return StreamResponse.fromFile(File(db['users'][ctx.pathParams['username']]['avatar']));
    });

    app.post('/user/:username/avatar', (ctx) async {
      Client? client = checkAccessToken(ctx);
      if (client == null) {
        return Response(statusCode: 401, body: 'Unauthorized');
      }
      if (client.username != ctx.pathParams['username']) {
        return Response(statusCode: 403, body: 'Forbidden');
      }

      BinaryFileFormField file;
      try {
        file = (await ctx.bodyAsFormData()).values.firstWhere((element) => element.name == 'avatar') as BinaryFileFormField;
      } catch (e) {
        return Response(statusCode: 400, body: 'Invalid file');
      }
      if (db['users'][ctx.pathParams['username']] == null) {
        return Response(statusCode: 404, body: 'User not found');
      }
      if (!(file.contentType?.mimeType ?? '').startsWith('image/')) {
        return Response(statusCode: 415, body: 'Invalid file type');
      }
      if (db['users'][ctx.pathParams['username']]['avatar'] != null) {
        File(db['users'][ctx.pathParams['username']]['avatar']).deleteSync();
      }
      String filename = md5.convert(utf8.encode(ctx.pathParams['username']! + ';${file.filename}')).toString();
      if (filename.length > 30) filename = filename.substring(0, 30);
      String ext = file.filename!.split('.').last;
      String path = Directory.current.path + '/avatars/' + filename + '.$ext';
      file.writeTo(path);
      db['users'][ctx.pathParams['username']]['avatar'] = path;
      _db.write();
      return Response(statusCode: 200, body: 'Avatar uploaded');
    });

    this.app = app;
  }

  Client? checkAccessToken(ctx) {
    if (ctx.headers['Authorization'] == null) {
      return null;
    }
    String token = ctx.headers['Authorization'];
    Client? client = clients.values.firstWhereOrNull((value) => value.accessToken == token);
    return client;
  }

  void start(String address, int port, Function onStarted) async {
    app.serve().then((_) => onStarted());
  }
}
