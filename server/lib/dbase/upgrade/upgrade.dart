import 'dart:math';
import 'package:sds_server/dbase/dbase.dart';
import 'package:uuid/uuid.dart';
part 'upgrade_001.dart';
part 'upgrade_002.dart';
part 'upgrade_003.dart';
part 'upgrade_004.dart';
part 'upgrade_005.dart';

class Upgrade {
  final DBase db;
  final upgradeList = {
    1: upgrade1,
    2: upgrade2,
    3: upgrade3,
    4: upgrade4,
    5: upgrade5,
  };

  Upgrade(this.db);

  Future<void> run() async {
    final maxInd = upgradeList.keys.reduce(max);
    for (var i = 1; i <= maxInd; i++) {
      if (!upgradeList.keys.contains(i)) {
        print('ERROR: not found index: $i');
        return;
      }
    }
    late final List<Map<String, dynamic>> rows;
    try {
      rows = await db.query('SELECT * FROM version', false);
    } catch (_) {
      rows = [
        {'value': 0},
      ];
    }
    if (rows.length != 1) {
      print('ERROR: version row must be one');
      return;
    }
    final lastInd = rows.first['value'];
    if (lastInd < 0 || lastInd > maxInd) {
      print('ERROR: bad index upgrade');
      return;
    }
    if (lastInd == maxInd) {
      print('all upgrades already success');
      return;
    }
    print('upgrading indexes ${lastInd + 1} - $maxInd');
    for (var i = lastInd + 1; i <= maxInd; i++) {
      await upgradeList[i]!(db);
      await db.exec('UPDATE version SET value = $i');
      print('upgrade $i success');
    }
  }
}
