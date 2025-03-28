import 'package:sds_server/api/api.dart';
import 'package:sds_server/dbase/dbase.dart';
import 'package:sds_server/dbase/upgrade/upgrade.dart';
import 'package:sds_server/web_server.dart';

void main(List<String> arguments) async {
  final path = 'web';
  final db = DBase(path);
  await db.connect('localhost', 'sds', 'sds', '1');
  if (arguments.length == 1 && arguments.first == 'db_clear') {
    final tbl = [
      'anamnes',
      'dental_exam',
      'dental_item',
      'patient',
      'user',
      'version',
    ];
    for (final t in tbl) {
      try {
        await db.exec('DROP TABLE public."$t" CASCADE');
      } catch (e) {
        print(e);
      }
    }
    await db.close();
    return;
  }
  if (arguments.length == 1 && arguments.first == 'db_upgrade') {
    final upgrade = Upgrade(db);
    await upgrade.run();
    await db.close();
    return;
  }
  if (arguments.isNotEmpty) {
    print('ERROR: unknown arguments');
    return;
  }
  final api = Api(db);
  final server = WebServer(
    path: path,
    api: api,
    forbidden: [
      '/formula.json',
    ],
  );
  await server.init();
  print('end');
}
