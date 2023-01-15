import 'dart:convert';
import 'dart:io';

class LocalDb {
  String path;
  Map<String, dynamic>? _data;

  LocalDb(this.path);

  Map<String, dynamic> read() {
    File file = File(path);
    if (!file.existsSync()) {
      file.createSync();
      file.writeAsStringSync('{"users":{}}');
    }
    _data = jsonDecode(File(path).readAsStringSync());
    return _data!;
  }

  void write() {
    File(path).writeAsStringSync(jsonEncode(_data));
  }

  get(String key) {
    Map<String, dynamic> data = _data ?? read();
    return data[key];
  }
}