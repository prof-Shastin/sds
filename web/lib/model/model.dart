import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import 'package:sds_web/pages/patients/patient_item.dart';

class Model {
  final countPatients = ValueNotifier<int?>(null);
  final loaded = ValueNotifier(false);
  final patient = ValueNotifier(PatientItem.zero());
  final graphImages = <ui.Image?>[];
  var leftWitch = 400.0;

  void dispose() {
    graphImages.forEach((e) => e?.dispose());
    countPatients.dispose();
    patient.dispose();
  }

  void load() {
    var count = 0;
    final fn = <String>[];
    for (var i = 0; i <= 20; i++) {
      final ii = '${i < 10 ? '0' : ''}$i';
      fn.add('/images/graph/img$ii.png');
    }
    for (var i = 1; i <= 8; i++) fn.add('/images/graph/icon$i.png');
    fn.add('/images/graph/psycho.jpeg');
    for (var i = 0; i < fn.length; i++) {
      graphImages.add(null);
      if (i == 1) continue;
      get(fn[i]).then((d) async {
        final codec = await ui.instantiateImageCodec(d);
        final frame = await codec.getNextFrame();
        graphImages[i] = frame.image.clone();
        count++;
        if (count >= fn.length - 1) {
          loaded.value = true;
        }
      });
    }
  }

  reviver(var key, var value) {
    if (value is Map) {
      if (value['__EXT_TYPE__'] == 'DateTime') {
        final innerValue = value['value'];
        if (innerValue == null) return innerValue;
        if (innerValue is String) {
          return DateTime.parse(innerValue);
        }
      }
    }
    return value;
  }

  int get port => Uri.base.port > 8100 ? 8180 : 8080;

  String getApiUri(String path) =>
      Uri.http('${Uri.base.host}:$port', path).toString();
  String getApiImgUri(String path) =>
      Uri.http('${Uri.base.host}:$port', '/images$path').toString();

  Future<dynamic> get(String path, {bool isRaw = false}) async {
    final d = await http.get(Uri.parse(getApiUri(path)));
    if (isRaw) return d;
    if (d.statusCode != 200) {
      throw 'error status code: ${d.statusCode}';
    }
    final k = d.headers.keys
        .firstWhereOrNull((e) => e.toLowerCase() == 'content-type');
    if (k != null && d.headers[k]!.toLowerCase() == 'application/json') {
      return jsonDecode(utf8.decode(d.bodyBytes), reviver: reviver);
    }
    return d.bodyBytes;
  }

  Future<dynamic> post(String path, [dynamic body]) async {
    final data = body == null
        ? null
        : body is Uint8List
            ? body
            : jsonEncode(body);
    final d = await http.post(Uri.parse(getApiUri(path)),
        body: data /*, headers: {
      'Authorization': 'Bearer 1111',
    }*/
        );
    if (d.statusCode != 200) {
      throw 'error status code: ${d.statusCode}';
    }
    final k = d.headers.keys
        .firstWhereOrNull((e) => e.toLowerCase() == 'content-type');
    if (k != null && d.headers[k]!.toLowerCase() == 'application/json') {
      return jsonDecode(utf8.decode(d.bodyBytes), reviver: reviver);
    }
    return d.bodyBytes;
  }

  Future<ui.Image> loadUiImage(String path) async {
    final d = await http.get(Uri.parse(getApiImgUri(path)));
    if (d.statusCode != 200) {
      throw 'error status code: ${d.statusCode}';
    }
    final codec = await ui.instantiateImageCodec(d.bodyBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image.clone();
    return image;
  }
}

String getValue(int value, String v1, String v2, String v3) {
  final d = (value / 10).floor(), e = value % 10;
  if (d != 1) {
    if (e == 1) return '$value $v1';
    if (e > 1 && e < 5) return '$value $v2';
  }
  return '$value $v3';
}

String getMoney(int price) {
  bool minus = price < 0;
  if (minus) price = -price;
  var result = price.toString();
  if (price >= 1000) {
    final l = result.length;
    result = result.substring(0, l - 3) + ' ' + result.substring(l - 3);
  }
  if (price >= 1000000) {
    final l = result.length;
    result = result.substring(0, l - 7) + ' ' + result.substring(l - 7);
  }
  if (price >= 1000000000000) {
    final l = result.length;
    result = result.substring(0, l - 11) + ' ' + result.substring(l - 11);
  }
  if (minus) result = '- ' + result;
  return result + ' р';
}

Future<bool> confirm(
  BuildContext context,
  String title,
  String btn1,
  String btn2,
) async {
  return (await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      //content: const Text('AlertDialog description'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(btn1),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(btn2),
        ),
      ],
    ),
  ))!;
}

Future<void> message(
  BuildContext context,
  String title, [
  String btn = 'Ok',
]) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(btn),
        ),
      ],
    ),
  );
}

void showProcessed(BuildContext context, {String text = ''}) {
  final sm = ScaffoldMessenger.of(context);
  sm.showSnackBar(SnackBar(
    dismissDirection: DismissDirection.none,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(days: 1),
    width: 240,
    content: SizedBox(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(text, style: const TextStyle(fontSize: 12)),
              const LinearProgressIndicator(),
              const SizedBox(height: 5),
            ]),
      ),
    ),
  ));
}

void hideProcessed(BuildContext context) {
  final sm = ScaffoldMessenger.of(context);
  sm.hideCurrentSnackBar();
}
