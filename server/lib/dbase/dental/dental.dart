import 'dart:async';

import 'create.dart';
import 'dental_isolate.dart';
import 'queue_item.dart';
import 'package:collection/collection.dart';

class Dental {
  late final List<DentalIsolate> _isolates;
  final create = Create();
  final _queueDental = <QueueDental>[];
  final _queueItem = <QueueItem>[];

  Future<void> init(String path) async {
    await create.init(path);
    final completer = Completer<void>();
    _isolates = List.generate(
      4,
      (i) => DentalIsolate(create, () {
        if (!completer.isCompleted) {
          if (_isolates.where((e) => !e.ready).isEmpty) {
            completer.complete();
          }
        }
        if (_queueItem.isEmpty) return;
        _isolates[i].drawImageTooth(_queueItem.first);
        _queueItem.removeAt(0);
      }),
    );
    return completer.future;
  }

  void close() => _isolates.forEach((e) => e.close());

  Future<void> _drawImageTooth(DentalItem di) {
    _queueItem.forEach((e) {
      if (e.data.index != di.index) return;
      if (e.data.path != di.path) return;
      if (e.completer.isCompleted) return;
      e.completer.complete();
    });
    _queueItem.removeWhere((e) => e.completer.isCompleted);
    final item = QueueItem(di);
    _isolates.forEach((e) => e.stop(item));
    final isolateFree = _isolates.firstWhereOrNull((e) => !e.isBusy);
    if (isolateFree != null) {
      isolateFree.drawImageTooth(item);
      return item.completer.future;
    }
    _queueItem.add(item);
    return item.completer.future;
  }

  Future<bool> drawDental(
    List<DBDentalItem> list,
    String path,
  ) async {
    final completer = Completer<bool>();
    final dt = DateTime.now();
    _queueDental
        .removeWhere((e) => e.isCompleted && e.expired.compareTo(dt) >= 0);
    final qd = QueueDental(path, create.dentalList(list, path));
    _queueDental.add(qd);
    final result = List<bool>.generate(qd.items.length, (_) => false);
    for (var i = 0; i < result.length; i++) {
      _drawImageTooth(qd.items[i]).then((_) async {
        result[i] = true;
        if (result.where((e) => !e).isEmpty) {
          qd.expired = DateTime.now().add(Duration(minutes: 5));
          qd.isCompleted = true;
          completer.complete(_queueDental
              .where((e) => e.path == path && !e.isCompleted)
              .isEmpty);
        }
      });
    }
    return completer.future;
  }

  bool dentalComplete(String path) =>
      _queueDental.where((e) => e.path == path && !e.isCompleted).isEmpty;
}
