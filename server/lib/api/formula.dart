import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:sds_server/dbase/dbase.dart';
import 'package:sds_server/dbase/dental/queue_item.dart';
import 'base.dart';

class Formula extends Base {
  final DBase db;

  int _typeInt(String type) {
    switch (type) {
      case 'exam':
        return 1;
      case 'plan':
        return 2;
      case 'fact':
        return 3;
      default:
        return 0;
    }
  }

  Future<dynamic> tools(HttpRequest request) async {
    if (request.method != 'GET') return notAllowed(request);
    final f = File('${db.path}/formula.json');
    final isExists = await f.exists();
    if (!isExists) return notFound(request);

    final d = jsonDecode(utf8.decode(await f.readAsBytes()));

    final dg = d['buildToolGroup'];
    if (dg is! List) return notFound(request);
    final di = d['buildTool'];
    if (di is! List) return notFound(request);
    if (dg.isEmpty || di.isEmpty) return notFound(request);
    dg.forEach((g) {
      final items = di.where((e) => e['groupId'] == g['id']).toList();
      items.sort((a, b) => a['sort'] - b['sort']);
      g['items'] = items;
    });
    dg.sort((a, b) => a['sort'] - b['sort']);

    final s = d['switch'];
    if (s is! List) return notFound(request);
    final sd = d['switchData'];
    if (sd is! List) return notFound(request);
    if (s.isEmpty || sd.isEmpty) return notFound(request);
    for (final si in s) {
      si['items'] = sd.where((e) => e['switchId'] == si['id']).toList();
    }

    return {'tools': dg, 'switches': s};
  }

  Future<dynamic> change(HttpRequest request) async {
    if (request.method != 'POST') return notAllowed(request);
    final map = jsonDecode(await utf8.decodeStream(request)) as Map;
    final k = [
      'patient_id',
      'type',
      'parent_id',
      'tool_id',
      'btn_id',
      'select',
      'indexes',
    ];
    if (map.keys.where((e) => !k.contains(e)).isNotEmpty) {
      return badRequest(request);
    }
    if (map['patient_id'] is! int) return badRequest(request);
    if (map['type'] is! String) return badRequest(request);
    if (map['parent_id'] is! int) return badRequest(request);
    if (map['tool_id'] is! int) return badRequest(request);
    if (map['btn_id'] is! int) return badRequest(request);
    if (map['select'] is! bool) return badRequest(request);
    if (map['indexes'] is! List) return badRequest(request);
    final patient_id = map['patient_id'] as int;
    final type = map['type'] as String;
    final parent_id = map['parent_id'] as int;
    final tool_id = map['tool_id'] as int;
    final btn_id = map['btn_id'] as int;
    final select = map['select'] as bool;
    final indexes = List<int>.from(map['indexes'] as List);
    final typeInt = _typeInt(type);
    if (typeInt == 0) return badRequest(request);
    if (tool_id != 0) {
      if (indexes.isEmpty) return badRequest(request);
      if (indexes
          .where((e) => e < 0 || e >= db.dental.create.count)
          .isNotEmpty) {
        return badRequest(request);
      }
      await db.change
          .change(typeInt, parent_id, tool_id, btn_id, select, indexes);
    }

    var sql =
        'SELECT * FROM dental_item WHERE "type" = $typeInt AND parent_id = $parent_id';
    if (indexes.isNotEmpty) sql += ' AND index in (${indexes.join(', ')})';
    final result = await db.query(sql);
    if (tool_id != 0) {
      final list = result.map((e) => DBDentalItem.fromJson(e)).toList();
      db.dental.drawDental(list, '$patient_id/$type/$parent_id');
    }
    return result;
  }

  Future<dynamic> tooth(HttpRequest request) async {
    try {
      if (request.method != 'POST') return notAllowed(request);
      final map = jsonDecode(await utf8.decodeStream(request)) as Map;
      final k = ['patient_id', 'type', 'parent_id'];
      if (map.keys.where((e) => !k.contains(e)).isNotEmpty) {
        return badRequest(request);
      }
      if (map['patient_id'] is! int) return badRequest(request);
      if (map['type'] is! String) return badRequest(request);
      if (map['parent_id'] is! int) return badRequest(request);
      final patient_id = map['patient_id'] as int;
      if (patient_id == 0) return badRequest(request);
      final type = map['type'] as String;
      var parent_id = map['parent_id'] as int;
      final typeInt = _typeInt(type);
      if (typeInt == 0) return badRequest(request);

      if (parent_id == 0) {
        final items = await db.query(
            'SELECT id FROM dental_exam WHERE patient_id = $patient_id ORDER BY dt desc LIMIT 1');
        parent_id = items.first['id'] as int;
      }
      final path = '$patient_id/$type/$parent_id';
      while (!db.dental.dentalComplete(path)) {
        await Future.delayed(Duration(microseconds: 100));
      }

      final items = await db.query(
          'SELECT * FROM dental_item WHERE "type" = $typeInt AND parent_id = $parent_id');
      final list = items.map((e) => DBDentalItem.fromJson(e)).toList();
      final d = {
        'dentalCount': db.dental.create.count,
        'ratioSize': db.dental.create.ratioSize,
        'ratioTextSize': db.dental.create.ratioTextSize,
        'numbers':
            db.dental.create.numbers(list).map((e) => e.toJson()).toList(),
      };
      final data = utf8.encode(jsonEncode(d));

      final fn = '${db.dental.create.pathPatients}/$path/';
      final v = <int>[];
      v.addAll(Uint32List.fromList([data.length]).buffer.asUint8List());
      v.addAll(data);
      for (var i = 0; i < db.dental.create.count; i++) {
        final d = await File('$fn$i.png').readAsBytes();
        v.addAll(Uint32List.fromList([d.length]).buffer.asUint8List());
        v.addAll(d);
      }
      request.response.headers.add('Content-Type', 'application/octet-stream');
      return v;
    } catch (_) {
      return badRequest(request);
    }
  }

  Future<dynamic> list(HttpRequest request) async {
    if (request.method != 'POST') return notAllowed(request);
    final map = jsonDecode(await utf8.decodeStream(request)) as Map;
    final k = ['patient_id'];
    if (map.keys.where((e) => !k.contains(e)).isNotEmpty) {
      return badRequest(request);
    }
    if (map['patient_id'] is! int) return badRequest(request);
    final patient_id = map['patient_id'] as int;

    final result = await db.query('''
      SELECT * FROM dental_exam WHERE patient_id = $patient_id ORDER BY dt desc
    ''');
    return result;
  }

  Future<dynamic> add(HttpRequest request) async {
    if (request.method != 'POST') return notAllowed(request);
    final map = jsonDecode(await utf8.decodeStream(request)) as Map;
    final k = ['patient_id', 'id', 'type'];
    if (map.keys.where((e) => !k.contains(e)).isNotEmpty) {
      return badRequest(request);
    }
    if (map['id'] is! int) return badRequest(request);
    if (map['type'] is! String) return badRequest(request);
    if (map['patient_id'] is! int) return badRequest(request);
    final patient_id = map['patient_id'] as int;
    final type = map['type'] as String;
    final id = map['id'] as int;
    final typeInt = _typeInt(type);
    if (typeInt == 0) return badRequest(request);

    await db.exec('INSERT INTO dental_exam (patient_id) VALUES ($patient_id)');
    final newId = await db.lastIdForTable('dental_exam');
    final path1 = '${db.dental.create.pathPatients}/$patient_id/$type/$id';
    final path2 = '${db.dental.create.pathPatients}/$patient_id/$type/$newId';
    await Directory(path2).create();
    for (var i = 0; i < db.dental.create.count; i++) {
      await File('$path1/$i.png').copy('$path2/$i.png');
    }

    await db.exec('''
      INSERT INTO dental_item ("type", parent_id, index, tool_id, btn_id, "select")
      SELECT "type", $newId, index, tool_id, btn_id, "select" FROM dental_item
      WHERE "type" = $typeInt AND parent_id = $id
    ''');

    return {'id': newId};
  }

  Future<dynamic> remove(HttpRequest request) async {
    if (request.method != 'POST') return notAllowed(request);
    final map = jsonDecode(await utf8.decodeStream(request)) as Map;
    final k = ['patient_id', 'id', 'type'];
    if (map.keys.where((e) => !k.contains(e)).isNotEmpty) {
      return badRequest(request);
    }
    if (map['id'] is! int) return badRequest(request);
    if (map['type'] is! String) return badRequest(request);
    if (map['patient_id'] is! int) return badRequest(request);
    final patient_id = map['patient_id'] as int;
    final type = map['type'] as String;
    final id = map['id'] as int;
    final typeInt = _typeInt(type);
    if (typeInt == 0) return badRequest(request);

    await db.exec('DELETE FROM dental_exam WHERE id = $id');
    final path = '${db.dental.create.pathPatients}/$patient_id/$type/$id';
    try {
      await Directory(path).delete(recursive: true);
    } catch (_) {}
    await db.exec('''
      DELETE FROM dental_item WHERE "type" = $typeInt AND parent_id = $id
    ''');
    return {'success': true};
  }

  Formula(this.db) {
    map['tools'] = tools;
    map['change'] = change;
    map['tooth'] = tooth;
    map['list'] = list;
    map['add'] = add;
    map['remove'] = remove;
  }
}
