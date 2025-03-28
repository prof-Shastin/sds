import 'dart:async';
import 'dart:isolate';
import 'create.dart';
import 'queue_item.dart';

class DentalIsolate {
  late final SendPort _sendPort;
  final _receivePort = ReceivePort();
  late final StreamSubscription ss;
  QueueItem? _queueItem;
  bool get isBusy => _queueItem != null;
  var ready = false;

  DentalIsolate(Create create, void Function() onFree) {
    ss = _receivePort.listen((dynamic message) async {
      if (message is SendPort) {
        _sendPort = message;
        _sendPort.send(create);
        ready = true;
        onFree();
        return;
      }
      if (message is String) {
        if (!isBusy) throw 'ERROR Queue';
        final q = _queueItem!;
        _queueItem = null;
        if (!q.completer.isCompleted) q.completer.complete();
        onFree();
      }
    });
    Isolate.spawn(_isolateProcess, _receivePort.sendPort);
  }

  static void _isolateProcess(SendPort sendPort) async {
    late final Create create;
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    var needClose = false;
    late final StreamSubscription ss;
    ss = receivePort.listen((dynamic message) {
      if (message is Create) {
        create = message;
        return;
      }
      if (message is String && message == 'close') {
        needClose = true;
        ss.cancel();
      }
      if (message is String && message == 'stop') {
        create.stop = true;
      }
      if (message is DentalItem) {
        create.drawImageTooth(message).then((_) {
          sendPort.send('next');
        });
      }
    });

    while (!needClose) await Future.delayed(Duration(seconds: 1));
  }

  void drawImageTooth(QueueItem q) {
    if (isBusy) throw 'ERROR Queue';
    _queueItem = q;
    _sendPort.send(_queueItem!.data);
  }

  void stop(QueueItem q) {
    if (!isBusy) return;
    if (_queueItem!.data.index != q.data.index) return;
    if (_queueItem!.data.path != q.data.path) return;
    _queueItem!.completer.complete();
    _sendPort.send('stop');
  }

  void close() {
    _sendPort.send('close');
    ss.cancel();
  }
}
