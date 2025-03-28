import 'dart:convert';
import 'dart:io';
import 'package:sds_server/dbase/dbase.dart';
import 'base.dart';

class Anamnes extends Base {
  final DBase db;

  Future<dynamic> list(HttpRequest request) async {
    if (request.method != 'POST') return notAllowed(request);
    final map = jsonDecode(await utf8.decodeStream(request)) as Map;
    final k = ['patient_id', 'anamnes_id'];
    if (map.keys.where((e) => !k.contains(e)).isNotEmpty) {
      return badRequest(request);
    }
    if (map['patient_id'] is! int) return badRequest(request);
    if (map['anamnes_id'] is! int) return badRequest(request);
    final patient_id = map['patient_id'] as int;
    final anamnes_id = map['anamnes_id'] as int;
    return await db.query(
        'select * from anamnes where patient_id = $patient_id AND anamnes_id = $anamnes_id');
  }

  Future<dynamic> change(HttpRequest request) async {
    if (request.method != 'POST') return notAllowed(request);
    final map = jsonDecode(await utf8.decodeStream(request)) as Map;
    final k = ['patient_id', 'anamnes_id', 'item_id', 'check', 'answer'];
    if (map.keys.where((e) => !k.contains(e)).isNotEmpty) {
      return badRequest(request);
    }
    if (map['patient_id'] is! int) return badRequest(request);
    if (map['anamnes_id'] is! int) return badRequest(request);
    if (map['item_id'] is! int) return badRequest(request);
    if (map['check'] is! bool) return badRequest(request);
    if (map['answer'] is! String) return badRequest(request);
    final patient_id = map['patient_id'] as int;
    final anamnes_id = map['anamnes_id'] as int;
    final item_id = map['item_id'] as int;
    final check = map['check'] as bool;
    final answer = (map['answer'] as String).replaceAll("'", "''");

    var id = 0;
    try {
      await db.exec('BEGIN');
      final d = await db.query(
          'SELECT * FROM anamnes WHERE patient_id = $patient_id AND anamnes_id = $anamnes_id AND item_id = $item_id');
      if (d.isEmpty) {
        await db.exec('''
          INSERT INTO anamnes (patient_id, anamnes_id, item_id, "check", answer) VALUES ($patient_id, $anamnes_id, $item_id, $check, '$answer')
        ''');
        id = await db.lastIdForTable('anamnes');
      } else {
        id = d.first['id'];
        await db.exec('''
          UPDATE anamnes SET "check" = $check, answer = '$answer' WHERE id = $id
        ''');
      }
      await db.exec('COMMIT');
      return {'id': id};
    } catch (e) {
      db.lastError = e.toString();
      try {
        await db.exec('ROLLBACK');
      } catch (_) {}
      return badRequest(request);
    }
  }

  Anamnes(this.db) {
    map['list'] = list;
    map['change'] = change;
  }
}
