import 'dart:convert';
import 'dart:io';

import 'package:sds_server/dbase/dbase.dart';
import 'package:sds_server/dbase/dental/image_data.dart';
import 'package:sds_server/dbase/dental/image_item.dart';
import 'package:sds_server/dbase/dental/image_layer.dart';
import 'package:sds_server/dbase/dental/queue_item.dart';

enum _ToolRule { forbidden, disable, enable }

class _BuildToolRuleItem {
  final int id;
  final int tool_id;
  final _ToolRule rule;
  final _BuildToolItem item;
  _BuildToolRuleItem(this.id, this.tool_id, this.rule, this.item);
}

class _SwitchItem {
  final int id;
  final buttons = <int>{};
  _SwitchItem(this.id);
}

class _NumberItem {
  final int id;
  final nums = <String>[];
  _NumberItem(this.id);
}

class _BuildToolItem {
  final int id;
  final layers = <ImageLayer>[];
  _NumberItem? numbers;
  _SwitchItem? _switch;
  int sortView;
  final rules = <_BuildToolRuleItem>[];
  _BuildToolItem(this.id, this.numbers, this._switch, this.sortView);
  @override
  String toString() =>
      '_BuildToolItem {\n  id: $id,\n  layers: ${layers.length},\n  number: ${numbers?.id},\n  switch: ${_switch?.id}\n}';
}

class _BuilderElementItem {
  final _BuildToolItem item;
  final buttonId = <int>[];
  var selectType = SelectType.none;
  _BuilderElementItem(this.item);
  @override
  String toString() =>
      '_BuilderElementItem {\n  selectType: $selectType,\n  buttonId: $buttonId,\n  item: ${item.toString().replaceAll('\n', '\n  ')},\n}';
}

class _BuilderElement {
  final int index;
  final list = <_BuilderElementItem>[];
  _NumberItem? numbers;
  _BuilderElement(this.index);
  @override
  String toString() =>
      '_BuilderElement {\n  index: $index,\n  list: ${list.toString().replaceAll('\n', '\n  ')},\n}';
}

class DentalChange {
  final DBase db;
  late final int count;
  late final List<_BuilderElement> item;
  late final List<bool> isChangeSelect;
  final select = <int>[];

  DentalChange(this.db);

  Future<void> init(String path) async {
    final d = jsonDecode(await File('$path/formula.json').readAsString());
    count = d['dentalCount'];

    /// _SwitchItem
    final switchList =
        (d['switch'] as List).map((e) => _SwitchItem(e['id'])).toList();
    final sd = d['switchData'] as List;
    for (final s in switchList) {
      s.buttons.addAll(sd
          .where((e) => e['switchId'] == s.id && e['type'] == 3)
          .map((e) => e['id'] as int)
          .toList());
    }

    /// _NumberItem
    final numberList = (d['number'] as List).map((e) {
      final n = _NumberItem(e['id']);
      n.nums.addAll(List.generate(count, (_) => ''));
      return n;
    }).toList();
    (d['numberPosition'] as List).forEach((e) {
      final n = numberList.firstWhere((nn) => nn.id == e['numberId']);
      n.nums[e['position'] - 1] = e['name'];
    });

    /// _BuildToolItem
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
    final toolList = (d['buildTool'] as List).map((e) {
      final t = _BuildToolItem(
          e['id'],
          e['numberId'] == 0
              ? null
              : numberList.firstWhere((n) => n.id == e['numberId']),
          e['switchId'] == 0
              ? null
              : switchList.firstWhere((s) => s.id == e['switchId']),
          e['sortView'] - 1);
      t.layers.addAll(ilt.where((l) => l.buildToolId == t.id));
      return t;
    }).toList();
    toolList.sort((a, b) => a.sortView - b.sortView);

    /// _BuildToolRuleItem
    final rules = (d['buildToolRule'] as List)
        .map((e) => _BuildToolRuleItem(
            e['id'],
            e['buildToolId'],
            _ToolRule.values[e['rule'] - 1],
            toolList.firstWhere((t) => t.id == e['linkBuildToolId'])))
        .toList();
    toolList
        .forEach((e) => e.rules.addAll(rules.where((r) => r.tool_id == e.id)));

    item = List.generate(count, (i) {
      final e = _BuilderElement(i);
      e.list.addAll(toolList.map((e) => _BuilderElementItem(e)));
      return e;
    });
    isChangeSelect = List.generate(count, (_) => false);
  }

  Future<void> change(int typeInt, int parent_id, int tool_id, int btn_id,
      bool sel, List<int> indexes) async {
    final result = await db.query(
        'SELECT * FROM dental_item WHERE "type" = $typeInt AND parent_id = $parent_id');
    item.forEach((e) {
      e.numbers = null;
      e.list.forEach((l) {
        l.selectType = SelectType.none;
        l.buttonId.clear();
      });
    });
    final src = <DBDentalItem>[];
    result.forEach((e) {
      final di = DBDentalItem.fromJson(e);
      src.add(di);
      final it =
          item[di.index].list.firstWhere((ee) => ee.item.id == di.toolId);
      it.selectType = di.select;
      if (di.btnId != 0) it.buttonId.add(di.btnId);
      if (it.item.numbers != null) item[di.index].numbers = it.item.numbers;
    });
    select.clear();
    select.addAll(indexes);
    select.sort();

    final it = item.first.list.firstWhere((ee) => ee.item.id == tool_id).item;
    if (!_changeItem(it, sel, btn_id)) return;

    final dest = <DBDentalItem>[];
    item.forEach((e) {
      e.list.where((e) => e.selectType != SelectType.none).forEach((l) {
        if (l.buttonId.isEmpty) {
          dest.add(DBDentalItem(0, e.index, l.item.id, 0, l.selectType));
        } else {
          dest.addAll(l.buttonId.map(
              (btn) => DBDentalItem(0, e.index, l.item.id, btn, l.selectType)));
        }
      });
    });

    final idList = <int>[];
    dest.forEach((d) {
      final s = src
          .where((s) =>
              s.index == d.index &&
              s.toolId == d.toolId &&
              s.btnId == d.btnId &&
              s.select == d.select)
          .map((e) => e.id)
          .toList();
      idList.addAll(s);
      if (s.isNotEmpty) d.del = true;
    });
    // print('dest: ${dest.where((e) => e.index == 0).toList()}');
    final rem =
        src.map((e) => e.id).where((e) => !idList.contains(e)).join(', ');
    final s = dest
        .where((e) => !e.del)
        .map((e) =>
            '($typeInt, $parent_id, ${e.index}, ${e.toolId}, ${e.btnId}, ${e.select.index})')
        .join(', ');

    if (rem.isNotEmpty) {
      await db.exec('DELETE FROM dental_item WHERE id in ($rem)');
    }
    if (s.isNotEmpty) {
      await db.exec(
          'INSERT INTO dental_item ("type", parent_id, index, tool_id, btn_id, "select") VALUES $s');
    }
    // print('remove: $rem');
    // print('add: $s');
    indexes.clear();
    indexes.addAll(select);
  }

  void _setSelect(int itemIndex, int toolIndex, bool isSelect) {
    var i = select.indexOf(itemIndex);
    bool isLeft = itemIndex != 0 &&
        itemIndex != 16 &&
        i > 0 &&
        select[i] - select[i - 1] == 1;
    bool isRight = itemIndex != 15 &&
        itemIndex != 31 &&
        i + 1 < select.length &&
        select[i + 1] - select[i] == 1;
    isChangeSelect[itemIndex] = true;
    item[itemIndex].list[toolIndex].selectType = !isSelect
        ? SelectType.none
        : isLeft
            ? isRight
                ? SelectType.all
                : SelectType.left
            : isRight
                ? SelectType.right
                : SelectType.one;
    if (!isLeft && itemIndex != 0 && itemIndex != 16) {
      _BuilderElementItem it = item[itemIndex - 1].list[toolIndex];
      if (it.selectType == SelectType.right) {
        it.selectType = SelectType.one;
        isChangeSelect[itemIndex - 1] = true;
      }
      if (it.selectType == SelectType.all) {
        it.selectType = SelectType.left;
        isChangeSelect[itemIndex - 1] = true;
      }
    }
    if (!isRight && itemIndex != 15 && itemIndex != 31) {
      _BuilderElementItem it = item[itemIndex + 1].list[toolIndex];
      if (it.selectType == SelectType.left) {
        it.selectType = SelectType.one;
        isChangeSelect[itemIndex + 1] = true;
      }
      if (it.selectType == SelectType.all) {
        it.selectType = SelectType.right;
        isChangeSelect[itemIndex + 1] = true;
      }
    }
  }

  bool _checkImageItem(ImageItem? image, int index) {
    return image == null ||
        (image.items[index].top == null &&
            image.items[index].middle == null &&
            image.items[index].bottom == null &&
            image.items[index].total == null);
  }

  bool _canSetSelect(int itemIndex, int toolIndex, int buttonId) {
    final itItem = item[itemIndex];
    final itTool = itItem.list[toolIndex];
    if (itTool.item.numbers != null) return true;
    final layers = List.generate(6, (_) => <ImageLayer>[]);
    for (int j = 0; j < itTool.item.layers.length; j++) {
      final layer = itTool.item.layers[j];
      if (itItem.numbers!.id != layer.numberId) continue;
      if (itTool.item._switch != null) {
        if (layer.switchDataId == 0) continue;
        if (layer.switchDataId != buttonId) continue;
      }
      if (layer.type == ImageLayerType.back) layers[0].add(layer);
      if (layer.type == ImageLayerType.leftBack) layers[1].add(layer);
      if (layer.type == ImageLayerType.rightBack) layers[2].add(layer);
      if (layer.type == ImageLayerType.front) layers[3].add(layer);
      if (layer.type == ImageLayerType.leftFront) layers[4].add(layer);
      if (layer.type == ImageLayerType.rightFront) layers[5].add(layer);
    }
    for (int i = 0; i < 6; i++) {
      for (final layer in layers[i]) {
        if (layer.image == null) {
          if (layer.color == 0) {
            if (!layer.maskOnAll) continue;
            return true;
          }
        } else {
          if (_checkImageItem(layer.image, itemIndex)) continue;
        }
        if (layer.mask != null) {
          if (_checkImageItem(layer.mask, itemIndex)) continue;
        }
        return true;
      }
    }
    return false;
  }

  bool _checkForbiden(int itemIndex, int toolIndex) {
    for (final rule in item[itemIndex].list[toolIndex].item.rules) {
      if (rule.rule != _ToolRule.forbidden) continue;
      if (item[itemIndex].list[rule.item.sortView].selectType !=
          SelectType.none) {
        return true;
      }
    }
    return false;
  }

  void _changeItemIndex(int itemIndex, int toolIndex, bool sel) {
    if (!sel) {
      _setSelect(itemIndex, toolIndex, false);
      return;
    }
    if (item[itemIndex].list[toolIndex].item.numbers != null) {
      if (item[itemIndex].list[toolIndex].item.numbers!.nums[itemIndex].isEmpty)
        return;
    }
    if (_checkForbiden(itemIndex, toolIndex)) return;
    if (!_canSetSelect(itemIndex, toolIndex, 0)) return;
    for (final rule in item[itemIndex].list[toolIndex].item.rules) {
      if (rule.rule == _ToolRule.disable) {
        _setSelect(itemIndex, rule.item.sortView, false);
      }
      if (rule.rule == _ToolRule.enable) {
        if (item[itemIndex].list[rule.item.sortView].selectType ==
            SelectType.none) {
          _changeItemIndex(itemIndex, rule.item.sortView, true);
        }
      }
    }
    if (item[itemIndex].list[toolIndex].item.numbers != null) {
      for (int i = 0; i < item[itemIndex].list.length; i++) {
        if (item[itemIndex].list[i].item.numbers == null) continue;
        _setSelect(itemIndex, i, false);
      }
      item[itemIndex].numbers = item[itemIndex].list[toolIndex].item.numbers;
    }
    _setSelect(itemIndex, toolIndex, true);
  }

  bool _changeItem(_BuildToolItem it, bool sel, int buttonId) {
    if (select.isEmpty) return false;
    if (it._switch != null) {
      bool forbidden = false;
      for (int i = 0; i < select.length; i++) {
        forbidden = forbidden || _checkForbiden(select[i], it.sortView);
      }
      if (forbidden) return false;
      _changeItemBtn(it, buttonId, sel);
      return true;
    }
    for (var i = 0; i < count; i++) isChangeSelect[i] = false;
    if (it.numbers != null) sel = true;
    for (int i = 0; i < select.length; i++) {
      _changeItemIndex(select[i], it.sortView, sel);
    }
    select.clear();
    for (int i = 0; i < isChangeSelect.length; i++) {
      if (isChangeSelect[i]) select.add(i);
    }
    return select.isNotEmpty;
  }

  void _changeItemBtn(_BuildToolItem sw_it, int buttonId, bool isSelect) {
    final isChangeSelect = List.generate(32, (_) => false);
    for (int i = 0; i < select.length; i++) {
      final it = item[select[i]].list[sw_it.sortView];
      if (isSelect) {
        if (it.buttonId.isEmpty || it.selectType == SelectType.none) {
          if (!_canSetSelect(select[i], sw_it.sortView, buttonId)) continue;
          _setSelect(select[i], sw_it.sortView, true);
          it.buttonId.clear();
        }
        for (final rule in it.item.rules) {
          if (rule.rule == _ToolRule.disable) {
            final beItem = item[select[i]].list[rule.item.sortView];
            if (beItem.item._switch == null ||
                beItem.item._switch!.id != sw_it._switch!.id) {
              _setSelect(select[i], beItem.item.sortView, false);
            } else {
              if (beItem.buttonId.contains(buttonId)) {
                beItem.buttonId.remove(buttonId);
                if (beItem.buttonId.isEmpty) {
                  _setSelect(select[i], beItem.item.sortView, false);
                }
              }
            }
          }
          if (rule.rule == _ToolRule.enable) {
            if (item[select[i]].list[rule.item.sortView].selectType ==
                SelectType.none) {
              _changeItemIndex(select[i], rule.item.sortView, true);
            }
          }
        }
        it.buttonId.add(buttonId);
        isChangeSelect[select[i]] = true;
      } else {
        if (it.buttonId.contains(buttonId)) {
          it.buttonId.remove(buttonId);
          isChangeSelect[select[i]] = true;
        }
        if (it.buttonId.isEmpty) _setSelect(select[i], it.item.sortView, false);
      }
    }
    select.clear();
    for (int i = 0; i < isChangeSelect.length; i++)
      if (isChangeSelect[i]) select.add(i);
  }
}
