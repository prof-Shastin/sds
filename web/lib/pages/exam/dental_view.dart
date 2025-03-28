import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:sds_web/model/model.dart';
import 'dental_item.dart';

class DentalView {
  final _selColor = [
    Colors.white,
    Color(0x80BDDDFC),
    Color(0xFFCFE3E8),
    Color.lerp(Color(0xFFCFE3E8), Color(0x80BDDDFC), 0.5),
  ];
  final _imageLoaded = ValueNotifier(false);
  final _pointEnd = ValueNotifier<Offset?>(null);
  final _items = <DentalItem>[];
  late final void Function(Set<int>)? _onSelect;
  late final void Function(DentalData)? _onImageLoad;
  late final Model _model;
  var _pointStart = Offset.zero;
  var _parent_id = 0;
  num _ratioSize = 0;
  num _ratioTextSize = 0;
  var _dc2 = 0;
  DentalData get data => DentalData(
      _ratioSize, _ratioTextSize, _items.map((e) => e.data).toList());

  DentalView({
    required Model model,
    void Function(Set<int>)? onSelect,
    void Function(DentalData)? onImageLoad,
  }) {
    _model = model;
    _onSelect = onSelect;
    _onImageLoad = onImageLoad;
  }

  void setImage(int id, [DentalData? dd]) {
    _parent_id = id;
    if (dd == null) return;
    _ratioSize = dd.ratioSize;
    _ratioTextSize = dd.ratioTextSize;
    if (_items.isEmpty) {
      _items.addAll(List.generate(dd.items.length, (i) => DentalItem(i)));
      _dc2 = (_items.length / 2).floor();
    }
    for (var i = 0; i < dd.items.length; i++) {
      _items[i].data.image = dd.items[i].image;
      _items[i].data.numberText = dd.items[i].numberText;
      _items[i].data.numberStyle = dd.items[i].numberStyle;
      if (_parent_id == 0) _items[i].select(false);
    }
    _imageLoaded.value = false;
    _imageLoaded.value = true;
  }

  void _changeSelect(double width, double height, double wItem, double hItem) {
    if (_parent_id == 0) return;
    Offset p(int i) => Offset(
          (i % _dc2) * wItem + (width + wItem * (1 - _dc2)) / 2,
          (i / _dc2).floor() * (hItem + 1) +
              hItem / 2, // + (height - hItem - 1) / 2,
        );
    final ctrl = HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.control) ||
        HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.controlLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.controlRight);
    final r = Rect.fromLTWH(
        min(_pointEnd.value!.dx, _pointStart.dx),
        min(_pointEnd.value!.dy, _pointStart.dy),
        (_pointEnd.value!.dx - _pointStart.dx).abs(),
        (_pointEnd.value!.dy - _pointStart.dy).abs());
    final o = Offset(wItem, hItem) * 0.5;
    final s = Size(wItem, hItem);
    _items.forEach((e) {
      final rItem = p(e.index) - o & s;
      final b = !r.intersect(rItem).isEmpty;
      final bb = b ? !e.isSelectOld : e.isSelectOld;
      e.select(ctrl ? bb : b);
    });
    _onSelect
        ?.call(_items.where((e) => e.isSelect).map((e) => e.index).toSet());
  }

  void dispose() {
    _imageLoaded.dispose();
    _pointEnd.dispose();
    _items.forEach((e) => e.sel.dispose());
  }

  Future<Image> dImg(Uint8List d) async {
    final image = await decodeImageFromList(d);
    final src =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dest = Rect.fromLTWH(0, 0, src.width * 2, src.height * 2);
    final rec = new PictureRecorder();
    final can = new Canvas(rec, dest);
    can.drawImageRect(image, src, dest, new Paint());
    final im = await rec
        .endRecording()
        .toImage(dest.width.toInt(), dest.height.toInt());
    image.dispose();
    return im;
  }

  void load() {
    _imageLoaded.value = false;
    final post = {
      'patient_id': _model.patient.value.id,
      'parent_id': _parent_id,
      'type': 'exam',
    };
    _model.post('/formula/tooth', post).then((d) {
      var l = d as Uint8List;
      if (l.length <= 4) return;
      var len = l.sublist(0, 4).buffer.asUint32List()[0];
      final data = jsonDecode(utf8.decode(l.sublist(4, len + 4))) as Map;
      final dentalCount = data['dentalCount'] as int;
      _ratioTextSize = data['ratioTextSize'] as num;
      _ratioSize = data['ratioSize'] as num;
      _dc2 = (dentalCount / 2).floor();
      if (_items.isEmpty) {
        _items.addAll(List.generate(dentalCount, (i) => DentalItem(i)));
      }
      (data['numbers'] as List).forEach((e) {
        final item = _items[e['index']].data;
        item.numberText = e['title'];
        item.numberStyle = TextStyle(
          fontFamily: e['family'],
          fontSize: double.parse(e['size'].toString()),
          fontWeight: e['bold'] == true ? FontWeight.bold : FontWeight.normal,
          fontStyle: e['italic'] == true ? FontStyle.italic : FontStyle.normal,
          color: Color(e['color']),
          decorationStyle: TextDecorationStyle.solid,
          decorationThickness:
              ((e['borderWidth'] as num?)?.toDouble() ?? 1) * 1,
          decorationColor: Color(e['borderColor']),
        );
      });
      l = l.sublist(len + 4);
      for (var i = 0; i < dentalCount; i++) {
        final len = l.sublist(0, 4).buffer.asUint32List()[0];
        _items[i].data.image = l.sublist(4, len + 4);
        l = l.sublist(len + 4);
      }
      _onImageLoad?.call(DentalData(
          _ratioSize, _ratioTextSize, _items.map((e) => e.data).toList()));
      _imageLoaded.value = true;
    });
  }

  Widget build() {
    return ValueListenableBuilder(
      valueListenable: _imageLoaded,
      builder: (context, isLoaded, child) {
        if (!isLoaded) return const Center(child: CircularProgressIndicator());
        return LayoutBuilder(
          builder: (BuildContext ctx, BoxConstraints con) {
            final width = con.maxWidth, height = con.maxHeight;
            var wItem = width / _dc2, hItem = wItem * _ratioSize;
            if (height < hItem * 2 + 1) {
              hItem = (height - 1) / 2;
              wItem = hItem / _ratioSize;
            }
            return GestureDetector(
              onPanStart: _onSelect == null
                  ? null
                  : (e) {
                      _items.forEach((e) {
                        e.isSelectOld = e.isSelect;
                        e.over(false);
                      });
                      _pointStart = e.localPosition;
                      _pointEnd.value = e.localPosition + Offset(1, 1);
                      _changeSelect(width, height, wItem, hItem);
                    },
              onPanEnd:
                  _onSelect == null ? null : (e) => _pointEnd.value = null,
              onPanUpdate: _onSelect == null
                  ? null
                  : (e) {
                      _pointEnd.value = e.localPosition;
                      _changeSelect(width, height, wItem, hItem);
                    },
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(3, (ii) {
                      if (ii == 1)
                        return Container(
                            width: wItem * _dc2,
                            height: 1,
                            color: Color(0xFFaFc3c8));
                      final i = ii == 0 ? 0 : 1;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_dc2, (j) {
                          final item = _items[i * _dc2 + j];
                          return MouseRegion(
                            onEnter: (e) {
                              if (_parent_id != 0) {
                                item.over(_pointEnd.value == null);
                              }
                            },
                            onExit: (e) => item.over(false),
                            child: ValueListenableBuilder(
                              valueListenable: item.sel,
                              builder: (context, selType, child) => Container(
                                width: wItem,
                                height: hItem,
                                decoration: BoxDecoration(
                                  color: _onSelect == null
                                      ? null
                                      : _selColor[selType.index],
                                  image: DecorationImage(
                                    image: MemoryImage(item.data.image!),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: wItem,
                                      height: wItem / _ratioTextSize,
                                      child: Center(
                                        child: Text(
                                          item.data.numberText,
                                          style: item.data.numberStyle.copyWith(
                                              fontSize: item.data.numberStyle
                                                      .fontSize! *
                                                  wItem /
                                                  75),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: wItem,
                                      height: wItem / _ratioTextSize,
                                      child: Center(
                                        child: Text(
                                          item.data.numberText,
                                          style: item.data.numberStyle.copyWith(
                                              fontSize: item.data.numberStyle
                                                      .fontSize! *
                                                  wItem /
                                                  75),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _pointEnd,
                    builder: (context, p, child) {
                      if (p == null || _parent_id == 0) return const SizedBox();
                      return Positioned(
                        left: min(p.dx, _pointStart.dx),
                        top: min(p.dy, _pointStart.dy),
                        width: (p.dx - _pointStart.dx).abs(),
                        height: (p.dy - _pointStart.dy).abs(),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFaFc3e8)),
                            color: Color(0xFFCFE3ff).withOpacity(0.5),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
