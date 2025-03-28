import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/anamnes/medical/data.dart';

const __asaBG = [0xff4bd51f, 0xffe4ce2f, 0xffD74949, 0xffb23210, 0xff111111];
const __asaFG = [0xff104d10, 0xff5d5d10, 0xff451010, 0xfffb6625, 0xff666666];

Future<Uint8List> graphMedical(
  Model model,
  int width,
  int height, {
  bool isShort = false,
}) async {
  final post = {'patient_id': model.patient.value.id, 'anamnes_id': 1};
  final d = await model.post('/anamnes/list', post);
  final map = <int, dynamic>{};
  for (final it in data) map[it[0] as int] = it;

  var asaIndex = 1;
  var allergicStr1 = '';
  var allergicStr2 = '';
  var medicinesStr = '';
  final im = List<bool>.generate(sort.length, (_) => false);
  (d as List).forEach((e) {
    if (e['check'] == true) {
      final item_id = e['item_id'] as int;
      im[map[item_id][2]] = true;
      if (asaIndex < map[item_id][3]) asaIndex = map[item_id][3];
      if (item_id == 4) allergicStr1 += e['answer'];
      if (item_id == 5) allergicStr2 += e['answer'];
      if (item_id == 3) medicinesStr += e['answer'];
    }
  });
  im[0] = true;

  final padding = EdgeInsets.zero;
  final heightTop = isShort ? 0.0 : 0.147;
  final heightBottom = isShort ? 0.0 : 0.147;
  final heightSpace = isShort ? 0.0 : 0.0147;
  final widthASA = 0.276;
  final spaceBetween = 0.0345;
  final x = padding.left;
  final y = padding.top;
  final w = (width - padding.left - padding.right);
  final h = (height - padding.top - padding.bottom);
  final r = Radius.circular(h * 0.0588);

  int dInd = asaIndex < 1
      ? 0
      : asaIndex < 5
          ? asaIndex - 1
          : 4;

  final recorder = PictureRecorder();
  var rect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
  final canvas = Canvas(recorder, rect);
  final p = Paint()..style = PaintingStyle.fill;

  // ASA
  if (!isShort) {
    var rrect = RRect.fromLTRBR(x, y, x + w * widthASA, y + h * heightTop, r);
    canvas.drawRRect(rrect, p..color = Color(__asaBG[dInd]));
    var tp = TextPainter(
      text: TextSpan(
        text: 'ASA ${digitsRome[asaIndex]}',
        style: TextStyle(color: Color(__asaFG[dInd]), fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout(minWidth: 0, maxWidth: rrect.width);
    var offset = rrect.center - Offset(tp.width, tp.height) / 2;
    tp.paint(canvas, offset);

    // allergic
    final ww = w * (1.0 - widthASA - spaceBetween);
    rrect = RRect.fromLTRBR(x + w - ww, y, x + w, y + h * heightTop, r);
    rect = Rect.fromLTWH(rrect.left + rrect.height * 0.2, rrect.top,
        rrect.width - rrect.height * 0.4, rrect.height);
    canvas.drawRRect(rrect, p..color = Color(0xffed1837));
    tp = TextPainter(
      text: TextSpan(
        text: '$allergicStr1 $allergicStr2'.trim(),
        style: TextStyle(color: Colors.white, fontSize: rect.height * 0.27),
      ),
      ellipsis: '...',
      maxLines: 3,
      textDirection: TextDirection.ltr,
    );
    tp.layout(minWidth: 0, maxWidth: rect.width);
    offset = rect.centerLeft - Offset(0, tp.height) / 2;
    tp.paint(canvas, offset);

    // medicines
    rrect = RRect.fromLTRBR(x, y + h * (1.0 - heightBottom), x + w, h, r);
    rect = Rect.fromLTWH(rrect.left + rrect.height * 0.2, rrect.top,
        rrect.width - rrect.height * 0.4, rrect.height);
    canvas.drawRRect(rrect, p..color = Color(0xff5b6def));
    tp = TextPainter(
      text: TextSpan(
        text: medicinesStr,
        style: TextStyle(color: Colors.white, fontSize: rect.height * 0.27),
      ),
      ellipsis: '...',
      maxLines: 3,
      textDirection: TextDirection.ltr,
    );
    tp.layout(minWidth: 0, maxWidth: rect.width);
    offset = rect.centerLeft - Offset(0, tp.height) / 2;
    tp.paint(canvas, offset);
  }

  rect = Rect.fromLTWH(x, y + h * (heightTop + heightSpace), w,
      h * (1.0 - heightTop - heightBottom - heightSpace * 2.0));
  for (final id in sort) {
    if (!im[id]) continue;
    final img = model.graphImages[id];
    if (img == null) continue;
    final src =
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    canvas.drawImageRect(img, src, rect, Paint());
  }

  final img = await recorder.endRecording().toImage(width, height);
  final b = await img.toByteData(format: ImageByteFormat.png);
  img.dispose();
  return b!.buffer.asUint8List();
}
