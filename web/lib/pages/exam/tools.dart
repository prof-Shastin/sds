import 'package:flutter/material.dart';
import 'package:sds_web/model/model.dart';
import 'package:collection/collection.dart';
import 'switch_view.dart';
import 'tool_group.dart';
import 'tool_item.dart';

class Tools {
  late final SwitchView _sw;
  final _indexes = <int>{};
  final _items = <_DentalItem>[];
  final _loaded = ValueNotifier(false);
  final _pos = ValueNotifier<Offset?>(null);
  final _selected = ValueNotifier<Map<int, Set<int>>>({});
  final _scroll = ScrollController();
  final _toolList = <DataToolGroup>[];
  late final void Function() _onChanged;
  late final Model _model;
  var _parent_id = 0;

  DataToolItem? _current;

  Tools({required Model model, required void Function() onChanged}) {
    _model = model;
    _onChanged = onChanged;
    _sw = SwitchView(model: _model, onTap: _onTap);
    _scroll.addListener(() => _sw.item.value = null);
    _load();
  }

  void setParent(int parent_id) {
    _parent_id = parent_id;
    _onTap(0, false, 0);
    if (parent_id == 0) {
      _indexes.clear();
      _selected.value = {};
    }
  }

  void select(Set<int> indexes) {
    _indexes.clear();
    _indexes.addAll(indexes);
    _changeSelect();
  }

  void _load() {
    _loaded.value = false;
    _model.get('/formula/tools').then((d) {
      _toolList.addAll(
          (d['tools'] as List).map((e) => DataToolGroup.fromJson(e)).toList());
      _sw.data.switchList.addAll(
          (d['switches'] as List).map((e) => SwitchItem.fromJson(e)).toList());
      _loaded.value = true;
    });
  }

  void _changeSelect() {
    final map = <int, Set<int>>{};
    _items.forEach((e) {
      if (!_indexes.contains(e.index)) return;
      if (map.containsKey(e.toolId)) {
        map[e.toolId]!.add(e.btnId);
      } else {
        map[e.toolId] = {e.btnId};
      }
    });
    _selected.value = map;
  }

  void _onTap(int toolId, bool select, int btnId) {
    if (_parent_id == 0) return;
    if (_indexes.isEmpty && toolId != 0) return;
    final post = {
      'patient_id': _model.patient.value.id,
      'parent_id': _parent_id,
      'type': 'exam',
      'tool_id': toolId,
      'select': select,
      'btn_id': btnId,
      'indexes': _indexes.toList(),
    };
    _model.post('/formula/change', post).then((d) {
      final items = (d as List).map((e) => _DentalItem.fromJson(e)).toList();
      final eq = const DeepCollectionEquality.unordered().equals;
      final b = eq(items.map((e) => e.toStr()), _items.map((e) => e.toStr()));
      _items.clear();
      _items.addAll(items);
      _changeSelect();
      if (!b && toolId != 0) _onChanged();
    });
  }

  void dispose() {
    _sw.dispose();
    _pos.dispose();
    _selected.dispose();
    _scroll.dispose();
    _loaded.dispose();
  }

  Widget buildSwitch() => _sw.build();

  Widget build() {
    return Container(
      width: _model.leftWitch,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFCFE3E8))),
      ),
      child: ValueListenableBuilder(
        valueListenable: _loaded,
        builder: (context, isLoaded, child) {
          if (!isLoaded) return Center(child: CircularProgressIndicator());
          return ValueListenableBuilder(
            valueListenable: _selected,
            builder: (context, selected, child) => ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.only(bottom: 50),
              itemCount: _toolList.length,
              itemBuilder: (ctx, index) => ToolGroup(
                group: _toolList[index],
                selected: selected.keys.toSet(),
                onTap: (item, sel) {
                  if (_sw.item.value != null) return;
                  if (item.switchId == 0) {
                    _onTap(item.id, sel, 0);
                    return;
                  }
                  _sw.data.downIdList.value = selected[item.id] ?? {};
                  _sw.item.value = item;
                  _pos.value = null;
                },
                onOver: (item) => _current = item,
                canOpen: () => _sw.item.value == null,
              ),
            ),
          );
        },
      ),
    );
  }

  void changePosition(Offset p) {
    _pos.value = _current == null || _sw.item.value != null ? null : p;
    _sw.lastPos = p;
  }

  Widget buildHint() {
    return ValueListenableBuilder(
      key: UniqueKey(),
      valueListenable: _pos,
      builder: (context, p, child) {
        if (p == null) return const SizedBox();
        return Positioned(
          left: p.dx + 10,
          top: p.dy + 10,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xfff5f5cc),
              border: Border.all(color: Color(0xff888844)),
            ),
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Text(
              _current!.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DentalItem {
  final int index;
  final int toolId;
  final int btnId;
  _DentalItem(this.index, this.toolId, this.btnId);
  factory _DentalItem.fromJson(Map json) => _DentalItem(
        json['index'] as int,
        json['tool_id'] as int,
        json['btn_id'] as int,
      );
  String toStr() => '${index}_${toolId}_$btnId';
}
