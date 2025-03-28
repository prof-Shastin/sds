import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:sds_server/dbase/dental/dental_change.dart';
import 'package:sds_server/dbase/dental/queue_item.dart';
import 'dental/dental.dart';

class DBase {
  final String path;
  final dental = Dental();
  late final DentalChange change;
  late final Connection conn;
  var lastError = '';

  DBase(this.path);

  Future<void> connect(
    String host,
    String database,
    String username,
    String password,
  ) async {
    conn = await Connection.open(
      Endpoint(
        host: host,
        database: database,
        username: username,
        password: password,
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
    await dental.init(path);
    change = DentalChange(this);
    await change.init(path);
  }

  Future<void> exec(String sql, [bool showSql = true]) async {
    try {
      await conn.execute(sql);
    } catch (e) {
      if (showSql) print('ERROR IN SQL: $sql');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> query(
    String sql, [
    bool showSql = true,
  ]) async {
    try {
      final result = await conn.execute(sql);
      return result.map((e) => e.toColumnMap()).toList();
    } catch (e) {
      if (showSql) print('ERROR IN SQL: $sql');
      throw e;
    }
  }

  Future<int> lastIdForTable(String table) async {
    var rows =
        await query("SELECT currval(pg_get_serial_sequence('$table','id'));");
    return rows.first['currval'] as int;
  }

  Future<void> close() async {
    await conn.close();
    dental.close();
  }

  Future<int> createPatient(Map<String, dynamic> data) async {
    try {
      final fieldList = [
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
      final unknownFields =
          data.keys.where((e) => !fieldList.contains(e)).toList();
      if (unknownFields.isNotEmpty) {
        lastError = 'Unknown fields: ${unknownFields.join(', ')}';
        return 0;
      }

      await exec('BEGIN');
      final fList = data.keys.join(', ');
      final vList = data.values
          .map((e) => e is String ? "'${e.replaceAll("'", "''")}'" : '$e')
          .join(', ');
      await exec('INSERT INTO "patient" ($fList) VALUES ($vList)');
      final pid = await lastIdForTable('patient');
      await exec('INSERT INTO "dental_exam" (patient_id) VALUES ($pid)');
      final id = await lastIdForTable('dental_exam');
      final items = List.generate(
          dental.create.count,
          (i) => DBDentalItem(
              0, i, dental.create.defaultToolId, 0, SelectType.one));
      final fields = '"type", parent_id, index, tool_id, btn_id, "select"';
      final values =
          items.map((e) => '(1, $id, ${e.index}, ${e.toolId}, 0, 1)').toList();
      await exec(
          'INSERT INTO "dental_item" ($fields) VALUES ${values.join(', ')}');
      await exec('COMMIT');
      final p = '${path}/images/patients/$pid/exam/$id';
      await Directory(p).create(recursive: true);
      await dental.drawDental(items, '$pid/exam/$id');
      return pid;
    } catch (e) {
      lastError = e.toString();
      try {
        await exec('ROLLBACK');
      } catch (_) {}
    }
    return 0;
  }
}
