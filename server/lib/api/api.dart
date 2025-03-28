import 'dart:io';
import 'package:sds_server/dbase/dbase.dart';
import 'anamnes.dart';
import 'auth.dart';
import 'base.dart';
import 'formula.dart';
import 'patient.dart';

class Api extends Base {
  @override
  Future<bool> run(String path, HttpRequest request) async {
    final e = path.split('/');
    if (e.length != 3 || e.first.isNotEmpty || !map.keys.contains(e[1])) {
      return false;
    }
    return await map[e[1]]!.run(e[2], request);
  }

  Api(DBase db) {
    map['auth'] = Auth(db);
    map['formula'] = Formula(db);
    map['patient'] = Patient(db);
    map['anamnes'] = Anamnes(db);
  }
}
