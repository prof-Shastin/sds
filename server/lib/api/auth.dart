import 'dart:io';
import 'package:sds_server/dbase/dbase.dart';
import 'base.dart';

class Auth extends Base {
  final DBase db;
  Future<dynamic> check(HttpRequest request) async {
    if (request.method != 'POST') return notAllowed(request);
    return await db.query('select * from "user"');
  }

  Auth(this.db) {
    map['check'] = check;
  }
}
