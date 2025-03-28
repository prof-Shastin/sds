import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:sds_server/dbase/dbase.dart';
import 'package:crypto/crypto.dart';
import 'base.dart';

class Patient extends Base {
  final DBase db;

  Future<dynamic> list(HttpRequest request) async {
    if (request.method != 'GET') return notAllowed(request);
    return await db.query('select * from patient');
  }

  Future<dynamic> photo(HttpRequest request) async {
    if (request.method != 'POST') return notAllowed(request);
    final map = jsonDecode(await utf8.decodeStream(request)) as Map;
    final k = ['id', 'age', 'gender'];
    if (map.keys.where((e) => !k.contains(e)).isNotEmpty) {
      return badRequest(request);
    }
    if (map['id'] is! int) return badRequest(request);
    if (map['age'] is! int) return badRequest(request);
    if (map['gender'] is! bool) return badRequest(request);
    final id = map['id'] as int;
    final age = map['age'] as int;
    final gender = map['gender'] as bool;

    final path = '${db.path}/images/patients';
    request.response.headers.add('Content-Type', 'image/jpeg');
    var f = File('$path/$id/image.jpeg');
    final isExists = await f.exists();
    if (!isExists) {
      f = File('$path/no-${gender ? 'M' : 'F'}-${age < 18 ? 0 : 1}.png');
    }
    return await f.readAsBytes();
  }

  Future<dynamic> change(HttpRequest request) async {
    if (request.method != 'POST') return notAllowed(request);
    final dd = <int>[];
    (await request.toList()).forEach((e) => dd.addAll(e));
    var d = Uint8List.fromList(dd);
    var len = d.sublist(0, 4).buffer.asUint32List()[0];
    if (len + 8 > d.length) return badRequest(request);
    final s = utf8.decode(d.sublist(4, len + 4));
    d = d.sublist(len + 4);
    if (md5.convert(d).toString() != s) return badRequest(request);
    len = d.sublist(0, 4).buffer.asUint32List()[0];
    if (len + 8 > d.length) return badRequest(request);
    final map = jsonDecode(utf8.decode(d.sublist(4, len + 4)));
    d = d.sublist(len + 4);
    len = d.sublist(0, 4).buffer.asUint32List()[0];
    if (len + 8 > d.length) return badRequest(request);
    final source = d.sublist(4, len + 4);
    d = d.sublist(len + 4);
    len = d.sublist(0, 4).buffer.asUint32List()[0];
    if (len + 4 > d.length) return badRequest(request);
    final image = d.sublist(4, len + 4);
    final k = [
      'id',
      'last_name',
      'first_name',
      'middle_name',
      'birth',
      'gender',
      'address',
      'phone_home',
      'phone_work',
      'phone',
      'email',
      'begin_observation',
      'notes',
      'scale',
      'offset_x',
      'offset_y',
    ];
    if (map.keys.where((e) => !k.contains(e)).isNotEmpty) {
      return badRequest(request);
    }
    if (map['id'] is! int) return badRequest(request);
    if (map['last_name'] is! String) return badRequest(request);
    if (map['first_name'] is! String) return badRequest(request);
    if (map['middle_name'] is! String) return badRequest(request);
    if (map['birth'] is! String) return badRequest(request);
    if (map['gender'] is! bool) return badRequest(request);
    if (map['address'] is! String) return badRequest(request);
    if (map['phone_home'] is! String) return badRequest(request);
    if (map['phone_work'] is! String) return badRequest(request);
    if (map['phone'] is! String) return badRequest(request);
    if (map['email'] is! String) return badRequest(request);
    if (map['begin_observation'] is! String) return badRequest(request);
    if (map['notes'] is! String) return badRequest(request);
    if (map['scale'] is! num) return badRequest(request);
    if (map['offset_x'] is! num) return badRequest(request);
    if (map['offset_y'] is! num) return badRequest(request);

    var id = map['id'];
    if (id == 0) {
      map.remove('id');
      id = await db.createPatient(map);
    } else {
      map.keys.forEach((k) {
        if (map[k] is String) map[k] = map[k].replaceAll("'", "''");
      });
      try {
        await db.exec('''
          UPDATE patient SET
          last_name = '${map['last_name']}',
          first_name = '${map['first_name']}',
          middle_name = '${map['middle_name']}',
          birth = '${map['birth']}',
          gender = ${map['gender']},
          address = '${map['address']}',
          phone_home = '${map['phone_home']}',
          phone_work = '${map['phone_work']}',
          phone = '${map['phone']}',
          email = '${map['email']}',
          begin_observation = '${map['begin_observation']}',
          notes = '${map['notes']}',
          scale = ${map['scale']},
          offset_x = ${map['offset_x']},
          offset_y = ${map['offset_y']}
          WHERE id = ${map['id']}
        ''');
      } catch (_) {
        id = 0;
      }
    }
    if (id == 0) return badRequest(request);
    final path = '${db.path}/images/patients/$id';
    if (source.length > 0) {
      await File('$path/source.jpeg').writeAsBytes(source);
      await File('$path/image.jpeg').writeAsBytes(image);
    } else {
      await File('$path/source.jpeg').delete();
      await File('$path/image.jpeg').delete();
    }
    return {'id': id};
  }

  Future<dynamic> remove(HttpRequest request) async {
    if (request.method != 'POST') return notAllowed(request);
    final map = jsonDecode(await utf8.decodeStream(request)) as Map;
    final k = ['patient_id'];
    if (map.keys.where((e) => !k.contains(e)).isNotEmpty) {
      return badRequest(request);
    }
    if (map['patient_id'] is! int) return badRequest(request);
    final patient_id = map['patient_id'] as int;

    try {
      await db.exec('BEGIN');
      await db.exec('DELETE FROM "patient" WHERE id = $patient_id');
      await db.exec(
          'DELETE FROM "dental_item" WHERE parent_id in (SELECT id FROM "dental_exam" WHERE patient_id = $patient_id)');
      await db.exec('DELETE FROM "dental_exam" WHERE patient_id = $patient_id');
      await db.exec('DELETE FROM "anamnes" WHERE patient_id = $patient_id');
      await db.exec('COMMIT');
    } catch (e) {
      print('error: $e');
      try {
        await db.exec('ROLLBACK');
      } catch (_) {}
      return badRequest(request);
    }
    final path = '${db.path}/images/patients/$patient_id';
    await Directory(path).delete(recursive: true);
    return {'success': true};
  }

  Patient(this.db) {
    map['list'] = list;
    map['photo'] = photo;
    map['change'] = change;
    map['remove'] = remove;
  }
}
