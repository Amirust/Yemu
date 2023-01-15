import 'package:yaml/yaml.dart';
import 'dart:io';
import 'package:yemu/yemu.dart' as Yemu;

void main(List<String> arguments) async {

  YamlMap config = loadYaml(File('config.yaml').readAsStringSync());
  Yemu.LocalDb db = Yemu.LocalDb(config['db_path']);
  Yemu.Server server = Yemu.Server(config, db);
  int port = config['yemu_port'];
  String address = config['yemu_address'];
  server.start(address, port, () {
    print('Server started on $address:$port');
  }, () {
    print('HTTP Server started on $address:${config['http_port']}');
  });
}
