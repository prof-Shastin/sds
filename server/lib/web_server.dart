import 'dart:io';
import 'api/api.dart';

class WebServer {
  late final String path;
  final Api api;
  final int port;
  final List<String> forbidden;
  var counter = 0;

  WebServer({
    required String path,
    required this.api,
    this.port = 8080,
    this.forbidden = const [],
  }) {
    while (path.endsWith('/')) path = path.substring(0, path.length - 1);
    this.path = path;
  }

  void notFound(HttpRequest request) {
    request.response.statusCode = 404;
    final f = File('$path/404.html');
    request.response.headers.add('Content-Type', 'text/html');
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    f.openRead().pipe(request.response).catchError((e) {});
  }

  Future<void> init() async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    await server.forEach(proccess);
  }

  Future<void> proccess(HttpRequest request) async {
    if (await api.run(request.uri.path, request)) return;
    final pathFile = request.uri.path == '/' ? '/index.html' : request.uri.path;
    if (forbidden.contains(pathFile)) {
      notFound(request);
      return;
    }
    var f = File('$path$pathFile');
    if (!(await f.exists())) {
      notFound(request);
      return;
    }
    String? type;
    final ext = f.path.toLowerCase().split('.').last;
    if (ext == 'png') type = 'image/png';
    if (ext == 'jpg') type = 'image/jpeg';
    if (ext == 'jpeg') type = 'image/jpeg';
    if (ext == 'json') type = 'application/json';
    if (ext == 'html') type = 'text/html';
    if (ext == 'js') type = 'application/javascript';
    if (type != null) request.response.headers.add('Content-Type', type);
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    f.openRead().pipe(request.response).catchError((e) {});
  }
}
