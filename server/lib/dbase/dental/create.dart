import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:image_v3/image_v3.dart';
import 'package:collection/collection.dart';

import 'number_item.dart';
import 'queue_item.dart';
import 'image_data.dart';
import 'image_item.dart';
import 'image_layer.dart';

class Create {
  final _layers = <int, List<ImageLayer>>{};
  final _numberFromTool = <int, int>{};
  final _numbers = <int, List<NumberItem>>{};
  final _toolSort = <int, int>{};
  late final int _width;
  late final int _height;
  late final int _th;
  late final int _hSide;
  late final int _hMiddle;
  late final String _path;
  late final int count;
  late final num ratioSize;
  late final num ratioTextSize;
  late final List<Set<String>> _cashImages;
  late final int defaultToolId;
  late final String pathPatients;
  var stop = false;

  Future<void> init(String path) async {
    _path = path;
    final d = jsonDecode(await File('$_path/formula.json').readAsString());
    count = d['dentalCount'];
    ratioSize = d['ratioSize'];
    ratioTextSize = d['ratioTextSize'];
    _cashImages = List<Set<String>>.generate(count, (_) => {});
    Directory('$_path/images/formula').listSync().forEach((e) {
      final f = e.path.split('/').last;
      if (f.startsWith('.')) return;
      final a = f.split('_');
      _cashImages[int.parse(a[1])].add(f);
    });
    final lii =
        (d['image'] as List).map((e) => ImageItem.fromJson(e, count)).toList();
    final lid = (d['dataImage'] as List).map((e) => ImageData.fromJson(e));
    final lil = (d['linkImage'] as List).map((e) => ImageLink.fromJson(e));
    lii.forEach((ii) {
      lil.where((il) => il.imageId == ii.id).forEach((il) {
        final ip = ImagePart(
          il.scale.toDouble(),
          Offset(il.offsetX.toDouble(), il.offsetY.toDouble()),
          lid.firstWhere((e) => e.id == il.dataImageId).image,
        );
        switch (il.view) {
          case 1:
            ii.items[il.position - 1].top = ip;
            break;
          case 2:
            ii.items[il.position - 1].middle = ip;
            break;
          case 3:
            ii.items[il.position - 1].bottom = ip;
            break;
          case 4:
            ii.items[il.position - 1].total = ip;
            break;
        }
      });
    });
    final ilt =
        (d['imageLayer'] as List).map((e) => ImageLayer.fromJson(e, lii));
    ilt.forEach((e) {
      if (!_layers.keys.contains(e.buildToolId)) _layers[e.buildToolId] = [];
      _layers[e.buildToolId]!.add(e);
    });
    _layers.keys.forEach((k) => _layers[k]!.sort((a, b) => a.sort - b.sort));

    final ni = d['number'] as List;
    (d['numberPosition'] as List).forEach((e) {
      final n = ni.firstWhere((nn) => nn['id'] == e['numberId']) as Map;
      final nn = NumberItem.fromJson(Map.from(n)..addAll(e));
      if (_numbers.keys.contains(nn.numberId)) {
        _numbers[nn.numberId]!.add(nn);
      } else {
        _numbers[nn.numberId] = [nn];
      }
    });

    final bt = d['buildTool'] as List;
    bt.forEach((e) {
      if (e['defaultOn'] == 1) defaultToolId = e['id'];
      _numberFromTool[e['id']] = e['numberId'];
      _toolSort[e['id']] = e['sortView'];
    });

    final s = 1024 * 2;
    var tth = (0.5 * (s - 1)).floor();
    var ttw = (tth / ratioSize).ceil();
    if (ttw * 16 > s) {
      ttw = (s / 16).floor();
      tth = (ttw * ratioSize).ceil();
    }
    _width = ttw;
    _height = tth;
    _th = (ttw / ratioTextSize).ceil();
    _hSide = ((tth - _th * 2 - ttw) / 2).floor();
    _hMiddle = tth - _th * 2 - _hSide * 2;
    pathPatients = '$path/images/patients';
  }

  int _reversColor(int color) {
    int c1 = (color << 16) & 0xff0000;
    int c2 = (color >> 16) & 0xff;
    return (color & 0xff00ff00) + c1 + c2;
  }

  Image _createBitmapFromColor(int color) {
    color = _reversColor(color);
    Image im = Image(_width, _height, channels: Channels.rgba);
    im.fillBackground(color);
    return im;
  }

  void _bitmapWithColor(Image im, int color) {
    color = _reversColor(color);
    double ca = ((color >> 24) & 255) / 255.0;
    double cr = ((color >> 16) & 255) / 255.0;
    double cg = ((color >> 8) & 255) / 255.0;
    double cb = (color & 255) / 255.0;

    final buf = im.data.buffer.asUint8List();
    int c = im.height * im.width, va, vr, vg, vb;
    var max = 0.0;
    final gray = List<double>.filled(c, 0);
    for (int i = 0, j = 0; j < c; i += 4, j++) {
      gray[j] = sqrt(buf[i] * buf[i] +
          buf[i + 1] * buf[i + 1] +
          buf[i + 2] * buf[i + 2] +
          buf[i + 3] * buf[i + 3]);
      if (max < gray[j]) max = gray[j];
    }

    var k = 0.0;
    for (int i = 3, j = 0; j < c; i += 4, j++) {
      k = max == 0.0 ? 1.0 : gray[j] / max;
      vr = (255.0 * k * cr).round();
      vg = (255.0 * k * cg).round();
      vb = (255.0 * k * cb).round();
      va = (buf[i] * ca).round();
      im[j] = (va << 24) + (vr << 16) + (vg << 8) + vb;
    }
  }

  void _bitmapWithMask(Image bm, Image mask) {
    int c = bm.height * bm.width;
    for (int i = 0; i < c; i++) {
      final bmA = bm[i] >> 24, maskA = mask[i] >> 24;
      bm[i] = ((bmA * maskA / 255.0).round() << 24) + (bm[i] & 0xffffff);
    }
  }

  Future<Image> _createBitmapFromImage(ImagePosition image) async {
    final bm = Image(_width, _height, channels: Channels.rgba);
    final img = [image.top, image.middle, image.bottom, image.total];
    final d = [
      _th,
      _hSide,
      _th + _hSide,
      _hMiddle,
      _th + _hSide + _hMiddle,
      _hSide,
      _th,
      _hSide * 2 + _hMiddle,
    ];
    for (int i = 0; i < 4; i++) {
      if (img[i] == null) continue;
      final f = File('$_path/images/dataImage/${img[i]!.image}');
      final isEx = await f.exists();
      if (!isEx) continue;
      final im = decodeImage(await f.readAsBytes());
      if (im == null) continue;
      final stw = _width, sth = d[i * 2 + 1];
      final k = img[i]!.scale;
      final sw = sth * k * im.width / im.height, sh = sth * k;
      final x =
          0.5 * stw - 0.5 * sw + img[i]!.offset.x * (0.5 * stw + 0.5 * sw);
      final y =
          0.5 * sth - 0.5 * sh + img[i]!.offset.y * (0.5 * sth + 0.5 * sh);
      drawImage(bm, im,
          dstX: x.round(),
          dstY: (y + d[i * 2]).round(),
          dstW: sw.round(),
          dstH: sh.round());
    }
    return bm;
  }

  Future<void> _createBitmapFromLayers(
    String fn,
    Image bm,
    List<ImageLayer> layers,
    int index,
  ) async {
    if (layers.isNotEmpty &&
        layers.where((e) => e.maskOnAll).isEmpty &&
        _cashImages[index].contains(fn)) {
      final f = File('$_path/images/formula/$fn');
      final im = decodeImage(await f.readAsBytes());
      if (im != null) drawImage(bm, im);
      return;
    }
    Image? bmLayer;
    for (final layer in layers) {
      Image? bmItem;
      if (layer.image == null) {
        if (layer.color == 0) {
          Image? mask = layer.mask == null
              ? null
              : await _createBitmapFromImage(layer.mask!.items[index]);
          if (!layer.maskOnAll) {
            if (mask == null) continue;
            if (bmLayer == null) {
              /*delete mask;*/ continue;
            }
            _bitmapWithMask(bmLayer, mask);
          } else {
            if (bmLayer != null) {
              drawImage(bm, bmLayer);
              bmLayer = null;
            }
            if (mask == null)
              mask = Image(_width, _height, channels: Channels.rgba);
            _bitmapWithMask(bm, mask);
          }
          mask = null;
          continue;
        }
        bmItem = _createBitmapFromColor(layer.color);
      } else {
        bmItem = await _createBitmapFromImage(layer.image!.items[index]);
        //if (bmItem == null) continue;
        if (layer.color != 0) _bitmapWithColor(bmItem, layer.color);
      }
      if (layer.mask != null) {
        Image mask = await _createBitmapFromImage(layer.mask!.items[index]);
        //if (mask == NULL) { delete bmItem; continue; }
        _bitmapWithMask(bmItem, mask);
      }
      if (bmLayer != null) {
        drawImage(bmLayer, bmItem);
        bmItem = null;
        continue;
      }
      bmLayer = bmItem;
    }
    if (bmLayer != null) {
      if (layers.where((e) => e.maskOnAll).isEmpty) {
        final f = File('$_path/images/formula/$fn');
        await f.writeAsBytes(encodePng(bmLayer));
        _cashImages[index].add(fn);
      }

      drawImage(bm, bmLayer);
      bmLayer = null;
    }
  }

  Future<void> drawImageTooth(DentalItem di) async {
    stop = false;
    if (di.index < 0 ||
        di.index >= count ||
        di.numberId <= 0 ||
        di.list.isEmpty) {
      return;
    }
    final bm = Image(_width, _height, channels: Channels.rgba);
    final lays = List<List<ImageLayer>>.generate(3, (_) => []);
    for (var i = di.list.length - 1; i >= 0; i--) {
      final it = di.list[i];
      final itLayers = _layers[it.toolId];
      if (it.select == SelectType.none || itLayers == null) continue;
      lays.forEach((e) => e.clear());
      for (var j = itLayers.length - 1; j >= 0; j--) {
        final layer = itLayers[j];
        if (layer.numberId != 0 && di.numberId != layer.numberId) continue;
        if (layer.switchDataId != 0) {
          if (!it.buttins.contains(layer.switchDataId)) continue;
        }
        if (layer.type == ImageLayerType.back) {
          lays[0].add(layer);
        }
        if (layer.type == ImageLayerType.leftBack) {
          if (it.select == SelectType.left || it.select == SelectType.all) {
            lays[1].add(layer);
          }
        }
        if (layer.type == ImageLayerType.rightBack) {
          if (it.select == SelectType.right || it.select == SelectType.all) {
            lays[2].add(layer);
          }
        }
      }
      for (var li = 0; li < lays.length; li++) {
        final l = lays[li].map((e) => e.id).join('-');
        await _createBitmapFromLayers(
            '${it.toolId}_${di.index}_${l}_b.png', bm, lays[li], di.index);
        if (stop) {
          stop = false;
          return;
        }
      }
    }
    for (final it in di.list) {
      final itLayers = _layers[it.toolId];
      if (it.select == SelectType.none || itLayers == null) continue;
      lays.forEach((e) => e.clear());
      for (final layer in itLayers) {
        if (layer.numberId != 0 && di.numberId != layer.numberId) continue;
        if (layer.switchDataId != 0) {
          if (!it.buttins.contains(layer.switchDataId)) continue;
        }
        if (layer.type == ImageLayerType.front) {
          lays[0].add(layer);
        }
        if (layer.type == ImageLayerType.leftFront) {
          if (it.select == SelectType.left || it.select == SelectType.all) {
            lays[1].add(layer);
          }
        }
        if (layer.type == ImageLayerType.rightFront) {
          if (it.select == SelectType.right || it.select == SelectType.all) {
            lays[2].add(layer);
          }
        }
      }
      for (var li = 0; li < lays.length; li++) {
        final l = lays[li].map((e) => e.id).join('-');
        await _createBitmapFromLayers(
            '${it.toolId}_${di.index}_${l}_f.png', bm, lays[li], di.index);
        if (stop) {
          stop = false;
          return;
        }
      }
    }
    //gaussianBlur(bm, 2);
    await File('$pathPatients/${di.path}/${di.index}.png')
        .writeAsBytes(encodePng(bm));
  }

  List<DentalItem> dentalList(
    List<DBDentalItem> list,
    String path,
  ) {
    list.forEach((e) {
      e.sort = _toolSort[e.toolId]!;
      e.numberId = _numberFromTool[e.toolId]!;
    });
    list.sort((a, b) => a.sort - b.sort);
    final tempList = List<DentalItem?>.filled(count, null);
    list.forEach((e) {
      if (e.select == SelectType.none) {
        throw 'ERROR select dental';
      }
      if (tempList[e.index] == null) {
        tempList[e.index] = DentalItem(e.index, 0, path, []);
      }
      final di = tempList[e.index]!;
      if (e.numberId != 0) di.numberId = e.numberId;
      var st = di.list.firstWhereOrNull((ee) => ee.toolId == e.btnId);
      if (st == null) {
        st = SelectTool(e.toolId, e.select, {});
        di.list.add(st);
      }
      st.buttins.add(e.btnId);
    });
    return tempList.where((e) => e != null).map((e) => e!).toList();
  }

  List<NumberItem> numbers(List<DBDentalItem> list) {
    final nums = List.generate(
        count, (i) => _numbers.values.first.firstWhere((e) => e.index == i));
    list.forEach((e) {
      final n = _numberFromTool[e.toolId];
      if (n == 0) return;
      nums[e.index] = _numbers[n]!.firstWhere((ee) => ee.index == e.index);
    });
    return nums;
  }
}
