import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

abstract class Base {
  final map = <String, dynamic>{};

  Future<bool> run(String path, HttpRequest request) async {
    if (!map.keys.contains(path)) return false;
    request.response.headers.removeAll('Content-Type');
    var v = await map[path]!(request);
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    if (request.response.headers.value('Content-Type') == null) {
      request.response.headers.add('Content-Type', 'application/json');
      v = toJson(v);
    }
    if (v is List<int>) {
      request.response.add(v);
    } else if (v is Uint8List) {
      request.response.add(v);
    } else {
      request.response.write(v);
    }
    request.response.close();
    return true;
  }

  String toJson(dynamic s) {
    final v = jsonEncode(
      s,
      toEncodable: (value) {
        if (value is DateTime) {
          return {'__EXT_TYPE__': 'DateTime', 'value': value.toIso8601String()};
        }
        return value;
      },
    );
    return String.fromCharCodes(utf8.encode(v));
  }

  Map<String, dynamic> notAllowed(HttpRequest request) {
    request.response.statusCode = 405;
    return {'message': 'Method Not Allowed'};
  }

  Map<String, dynamic> notAuth(HttpRequest request) {
    request.response.statusCode = 401;
    return {'message': 'Not Authorization'};
  }

  Map<String, dynamic> badRequest(HttpRequest request) {
    request.response.statusCode = 400;
    return {'message': 'Bad request'};
  }

  Map<String, dynamic> notFound(HttpRequest request) {
    request.response.statusCode = 404;
    return {'message': 'Not Found'};
  }
}
