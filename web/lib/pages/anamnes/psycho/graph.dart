import 'dart:typed_data';
import 'dart:ui';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/anamnes/psycho/data.dart';

Future<Uint8List> graphPsycho(Model model, int width, int height) async {
  final post = {'patient_id': model.patient.value.id, 'anamnes_id': 4};
  final d = await model.post('/anamnes/list', post);
  final map = <int, bool>{};
  for (final it in d) map[it['item_id'] as int] = it['check'] as bool;
  final mat = <List<bool>>[];
  for (final item in data) {
    if (item[1] == 0) {
      mat.add([]);
      continue;
    }
    mat.last.add(map[item[0] as int] == true);
  }

  final im = model.graphImages[29]!;
  final x = [0.0, 0.19322 * im.width, 0.2983 * im.width, 0.5 * im.width];
  final h1 = im.height / 4,
      h2 = h1 / 7,
      sex = model.patient.value.gender ? 0 : x[3];
  final kr = width / x[3];
  final ys = (height - kr * h1) / 2;

  final recorder = PictureRecorder();
  var rect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
  final canvas = Canvas(recorder, rect);

  for (var i = 0; i < 3; i++) {
    for (var j = 0; j < 7; j++) {
      final k = mat[i + 1][j]
          ? mat[i][j]
              ? 0
              : i == 1
                  ? 1
                  : 2
          : mat[i][j]
              ? i == 1
                  ? 2
                  : 1
              : 3;
      final dst = Rect.fromLTWH(kr * x[i], ys + kr * j * h2 - 0.5,
          kr * (x[i + 1] - x[i]), kr * h2 + 1);
      final src =
          Rect.fromLTWH(x[i] + sex, k * h1 + j * h2, x[i + 1] - x[i], h2);
      canvas.drawImageRect(im, src, dst, Paint());
    }
  }

  final img = await recorder.endRecording().toImage(width, height);
  final b = await img.toByteData(format: ImageByteFormat.png);
  img.dispose();
  return b!.buffer.asUint8List();
}
