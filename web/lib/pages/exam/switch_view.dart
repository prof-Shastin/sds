import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Switch;
import 'package:sds_web/model/model.dart';
import 'package:collection/collection.dart';
import 'tool_item.dart';

class SwitchView {
  final data = Data();
  final item = ValueNotifier<DataToolItem?>(null);
  final Model model;
  final void Function(int, bool, int) onTap;

  var lastPos = Offset.zero;
  var needHidden = 0;

  SwitchView({required this.model, required this.onTap});

  void dispose() {
    item.dispose();
    data.overId.dispose();
    data.downIdList.dispose();
    data.status.dispose();
  }

  Widget build() {
    return ValueListenableBuilder(
      valueListenable: item,
      builder: (context, itemVal, child) {
        if (itemVal == null) {
          data.hide();
          return const SizedBox();
        }
        needHidden = itemVal.id;
        Future.delayed(const Duration(seconds: 3), () {
          if (needHidden == itemVal.id) item.value = null;
        });
        data.overId.value = 0;
        data.init(model, itemVal);
        return Positioned(
          left: lastPos.dx + 30,
          top: lastPos.dy - data.size.height / 2,
          child: MouseRegion(
            onEnter: (_) => needHidden = 0,
            onExit: (_) => item.value = null,
            onHover: (e) => data.setId(e.localPosition),
            child: InkWell(
              onTap: () {
                final id = data.overId.value;
                final d = data.downIdList.value;
                final sel = !d.contains(id);
                if (sel) {
                  d.add(id);
                } else {
                  d.remove(id);
                }
                data.downIdList.value = d;
                onTap(itemVal.id, sel, id);
              },
              child: Container(
                width: data.size.width,
                height: data.size.height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                ),
                child: ValueListenableBuilder(
                  valueListenable: data.downIdList,
                  builder: (context, downId, child) => ValueListenableBuilder(
                    valueListenable: data.overId,
                    builder: (context, over, child) => ValueListenableBuilder(
                      valueListenable: data.status,
                      builder: (context, status, child) {
                        if (status == DataType.success) {
                          return CustomPaint(
                              key: UniqueKey(), painter: SwitchPainter(data));
                        }
                        if (status == DataType.loading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return const Center(
                          child: Text(
                            'Ошибка загрузки!',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

enum DataType { loading, error, success }

class Data {
  final overId = ValueNotifier<int>(0);
  final downIdList = ValueNotifier<Set<int>>({});
  final status = ValueNotifier(DataType.loading);
  final btnIm = <int, ui.Image>{};
  final btnMask = <int, List<bool>>{};
  final switchList = <SwitchItem>[];
  Size size = Size.zero;
  ui.Image? back;
  ui.Image? front;
  Color color = Colors.white;

  void setId(Offset p) => overId.value = btnMask.keys.firstWhereOrNull((k) =>
          btnMask[k]![p.dy.toInt() * size.width.toInt() + p.dx.toInt()]) ??
      0;

  void hide() {
    status.value = DataType.loading;
    btnIm.values.forEach((e) => e.dispose());
    btnIm.clear();
    btnMask.clear();
    back?.dispose();
    front?.dispose();
    back = null;
    front = null;
  }

  void init(Model model, DataToolItem itemVal) {
    color = itemVal.switchColor;
    final sw = switchList.firstWhere((e) => e.id == itemVal.switchId);
    size = Size(sw.width.toDouble(), sw.height.toDouble());
    final maskCount =
        sw.items.where((e) => e.type == SwitchDataType.mask).length;
    sw.items.forEach((e) => model.loadUiImage('/switch/${e.image}').then((im) {
          if (e.type == SwitchDataType.front) {
            front = im;
          } else if (e.type == SwitchDataType.back) {
            back = im;
          } else {
            btnIm[e.id] = im;
            im.toByteData(format: ui.ImageByteFormat.rawRgba).then((b) {
              final buf = b!.buffer.asInt32List().toList();
              final kx = im.width / sw.width;
              final ky = im.height / sw.height;
              final res = <bool>[];
              for (var y = 0; y < sw.height; y++) {
                for (var x = 0; x < sw.width; x++) {
                  final xx = (x * kx).round();
                  final yy = (y * ky).round();
                  res.add((buf[yy * im.width + xx] & 0xff000000) != 0);
                }
              }
              btnMask[e.id] = res;
            });
          }
          if (back != null && front != null && btnIm.keys.length == maskCount) {
            status.value = DataType.success;
          }
        }).catchError((_) {
          status.value = DataType.error;
        }));
  }
}

class SwitchPainter extends CustomPainter {
  final Data data;
  SwitchPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final srcBack = Rect.fromLTWH(
        0, 0, data.back!.width.toDouble(), data.back!.height.toDouble());
    final dst = Offset.zero & size;
    canvas.drawImageRect(data.back!, srcBack, dst, Paint());

    for (final k in data.btnIm.keys) {
      double o = data.downIdList.value.contains(k)
          ? data.overId.value == k
              ? 1
              : 0.5
          : data.overId.value == k
              ? 0.125
              : -1;
      if (o < 0) continue;
      final im = data.btnIm[k]!;
      Paint paint = Paint();
      canvas.saveLayer(dst, paint);
      final srcIm =
          Rect.fromLTWH(0, 0, im.width.toDouble(), im.height.toDouble());
      canvas.drawImageRect(im, srcIm, dst, paint);
      canvas.drawImageRect(
          data.back!,
          srcBack,
          dst,
          paint
            ..colorFilter = ui.ColorFilter.mode(
                data.color.withOpacity(o), ui.BlendMode.srcIn)
            ..blendMode = BlendMode.srcIn);
      canvas.restore();
    }

    final srcFront = Rect.fromLTWH(
        0, 0, data.front!.width.toDouble(), data.front!.height.toDouble());
    canvas.drawImageRect(data.front!, srcFront, dst, Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

enum SwitchDataType { back, front, mask }

class SwitchData {
  final int id;
  final int switchId;
  final SwitchDataType type;
  final String image;

  const SwitchData(
    this.id,
    this.switchId,
    this.type,
    this.image,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'switchId': switchId,
        'type': type.index + 1,
        'image': image,
      };

  factory SwitchData.fromJson(Map json) {
    final t = (json['type'] as int?) ?? 0;
    return SwitchData(
      (json['id'] as int?) ?? 0,
      (json['switchId'] as int?) ?? 0,
      SwitchDataType
          .values[t >= 1 && t <= SwitchDataType.values.length ? t - 1 : 0],
      (json['image'] as String?) ?? '',
    );
  }
}

class SwitchItem {
  final int id;
  final String name;
  final int width;
  final int height;
  final List<SwitchData> items;

  const SwitchItem(
    this.id,
    this.name,
    this.width,
    this.height,
    this.items,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'width': width,
        'height': height,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory SwitchItem.fromJson(Map json) => SwitchItem(
        (json['id'] as int?) ?? 0,
        (json['name'] as String?) ?? '',
        (json['width'] as int?) ?? 0,
        (json['height'] as int?) ?? 0,
        List<Map>.from((json['items'] as List?) ?? [])
            .map((e) => SwitchData.fromJson(e))
            .toList(),
      );
}
