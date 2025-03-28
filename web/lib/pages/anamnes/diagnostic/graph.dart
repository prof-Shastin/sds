import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/anamnes/diagnostic/data.dart';

Future<Uint8List> graphDiagnostic(Model model, int width, int height) async {
  final post = {'patient_id': model.patient.value.id, 'anamnes_id': 3};
  final d = await model.post('/anamnes/list', post);
  final map = <int, bool>{};
  for (final it in d) map[it['item_id'] as int] = it['check'] as bool;
  final v = graphData.map((e) {
    final list = data.where((l) => l[1] == e).toList();
    for (var i = 0; i < list.length; i++) {
      if (map[list[i][0]] == true) return (i + 1) / list.length;
    }
    return 0;
  }).toList();

  final recorder = PictureRecorder();
  var rect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
  final canvas = Canvas(recorder, rect);
  final pf = Paint()..style = PaintingStyle.fill;
  final ps = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = Color(0xff808080);
  final c = Offset(width / 2, height / 2);
  final count = 5;
  final r = 0.8 * 0.45 * min(width, height);
  final du = pi * 2 / count;

  Offset o(int i) => Offset(cos(du * i - 0.5 * pi), sin(du * i - 0.5 * pi));

  final rr = [0.3, 0.7, 1.0];
  final col = [0xff00ee00, 0xffeeee00, 0xffff0000];

  for (int i = 2; i >= 0; i--) {
    final path = Path();
    for (int j = 0; j < count; j++) {
      final t = c + o(j) * r * rr[i];
      if (j == 0) {
        path.moveTo(t.dx, t.dy);
      } else {
        path.lineTo(t.dx, t.dy);
      }
    }
    canvas.drawPath(path, pf..color = Color(col[i]));
  }

  final vv = v.map((e) => r * (1 + 5 * e) / 6).toList();
  final path = Path();
  var tt = Offset.zero;
  for (int i = 0; i < count; i++) {
    final t = c + o(i) * vv[i];
    if (i == 0) {
      tt = t;
      path.moveTo(t.dx, t.dy);
    } else {
      path.lineTo(t.dx, t.dy);
    }
  }
  path.lineTo(tt.dx, tt.dy);
  path.lineTo(-10, -10);
  path.lineTo(-10, height + 10);
  path.lineTo(width + 10, height + 10);
  path.lineTo(width + 10, -10);
  path.lineTo(-10, -10);
  canvas.drawPath(path, pf..color = Color(0xffffffff));

  for (var i = 0; i < count; i++) {
    canvas.drawLine(c, c + o(i) * r, ps);
  }
  for (var i = 2; i < 6; i++) {
    final pl = <Offset>[];
    for (var j = 0; j < count; j++) {
      pl.add(c + o(j) * (r * i / 6));
      if (j > 0) pl.add(pl.last);
    }
    pl.add(pl.first);
    canvas.drawPoints(PointMode.lines, pl, ps);
  }
  for (var i = 0; i < count; i++) {
    final t = c + o(i) * vv[i];
    canvas.drawCircle(t, r * 0.03, pf..color = Color(0xff202020));
  }

  final ind = [25, 23, 27, 28, 22];
  for (var i = 0; i < 5; i++) {
    final k = ind[i] == 23 ? 1.2 : 1.0;
    final s = k * r * 1.25 / 8;
    final d = k * r * 1.25 / 4;
    final t = c + o(i) * r * 1.25 - Offset(s, s);
    final rect = Rect.fromLTWH(t.dx, t.dy, d, d);
    final im = model.graphImages[ind[i]]!;
    final src = Rect.fromLTWH(0, 0, im.width.toDouble(), im.height.toDouble());
    canvas.drawImageRect(im, src, rect, Paint());
  }

  final img = await recorder.endRecording().toImage(width, height);
  final b = await img.toByteData(format: ImageByteFormat.png);
  img.dispose();
  return b!.buffer.asUint8List();
}
