import 'dart:convert';

import 'package:yemu/src/types/ResponseTypes.dart';

abstract class Response<T> {
  late final ResponseTypes type;
  late final T data;
}

class ServerResponse implements Response<Object> {
  ResponseTypes type;
  Object data;

  ServerResponse(this.type, this.data);

  toJson() {
    return jsonEncode({
      'type': type.index,
      'data': data,
    });
  }

  factory ServerResponse.fromType(ResponseTypes type) {
    return ServerResponse(type, ResponseDescription[type]!);
  }
}

class ErrorResponse implements Response<String> {
  ResponseTypes type;
  String data;

  ErrorResponse(this.type, this.data);

  toJson() {
    return jsonEncode({
      'type': type.index,
      'data': data,
    });
  }

  factory ErrorResponse.fromType(ResponseTypes type) {
    return ErrorResponse(type, ResponseDescription[type]!);
  }
}