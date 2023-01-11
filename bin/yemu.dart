import 'package:yemu/yemu.dart' as Yemu;

void main(List<String> arguments) async {
  Yemu.Server server = Yemu.Server();
  int port = 3072;
  server.start(port, () {
    print('Server started on localhost:$port');
  });
}
