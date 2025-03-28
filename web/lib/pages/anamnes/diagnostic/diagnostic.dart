import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/anamnes/anamnes_item.dart';
import 'package:sds_web/pages/anamnes/diagnostic/data.dart';

class Diagnostic extends StatefulWidget {
  final ValueNotifier<int> graphIndex;
  const Diagnostic({super.key, required this.graphIndex});
  @override
  State<Diagnostic> createState() => _DiagnosticState();
}

class _DiagnosticState extends State<Diagnostic> {
  late final Model model;
  final loaded = ValueNotifier(false);
  final list = <AnamnesItem>[];
  final map = <int, AnamnesItem>{};

  void load() {
    loaded.value = false;
    final post = {
      'patient_id': model.patient.value.id,
      'anamnes_id': 3,
    };
    model.post('/anamnes/list', post).then((d) {
      final l = d as List;
      l.forEach((e) {
        final item = map[e['item_id']]!;
        item.check.value = e['check'];
        item.answer.text = e['answer'];
        if (item.check.value) {
          final child = list.where((e) => e.parent_id == item.item_id).toList();
          child.forEach((e) => e.hidden.value = !item.check.value);
        }
      });
      setBG();
      loaded.value = true;
    });
  }

  Future<void> _change(int item_id, bool check, String answer) async {
    final post = {
      'patient_id': model.patient.value.id,
      'anamnes_id': 3,
      'item_id': item_id,
      'check': check,
      'answer': answer,
    };
    await model.post('/anamnes/change', post);
  }

  Future<void> change(AnamnesItem? item1, AnamnesItem? item2) async {
    if (item1 != null) {
      await _change(item1.item_id, item1.check.value, item1.answer.text);
    }
    if (item2 != null) {
      await _change(item2.item_id, item2.check.value, item2.answer.text);
    }
    widget.graphIndex.value++;
  }

  void setBG() {
    var bg = true;
    list.forEach((e) {
      if (e.parent_id == 0) bg = true;
      if (!e.hidden.value) bg = !bg;
      e.bg.value = bg;
    });
  }

  @override
  void initState() {
    model = context.read<Model>();
    final imgCheckUrl = model.getApiImgUri('/check.png');
    list.addAll(data.map((e) {
      final item_id = e[0] as int;
      final parent_id = e[1] as int;
      final main = parent_id == 0;
      final tab = e[5] == 1;
      final input = e[4] as bool;
      late final AnamnesItem item;
      item = AnamnesItem(
        item_id: item_id,
        parent_id: parent_id,
        data: e,
        padding: EdgeInsets.fromLTRB(tab ? 78 : 8, main ? 48 : 8, 8, 8),
        title: e[6].toString(),
        titleStyle: TextStyle(
          fontSize: mainItem.contains(item_id) ? 28 : 18,
          fontWeight: main ? FontWeight.bold : FontWeight.normal,
        ),
        info: e[7].toString(),
        imgCheckUrl: imgCheckUrl,
        onTap: () {
          if (item.check.value && e[3] == false) return;
          item.check.value = !item.check.value;
          if (item.check.value && input) {
            item.input.value = true;
            list.forEach((e) => e.enabled = false);
            return;
          }
          final item1 = item;
          AnamnesItem? item2;
          if (item.check.value) {
            if (parent_id != 0) {
              final count = map[parent_id]!.data[2] as int;
              if (count > 0) {
                final checked = list
                    .where((e) => e.check.value && e.parent_id == parent_id)
                    .toList();
                if (count < checked.length) {
                  item2 = checked.firstWhere((e) => e.item_id != item_id);
                  item2.check.value = false;
                }
              }
            }
          }
          change(item1, item2);
          if (parent_id != 0) {
            final child = list.where((e) => e.parent_id == item_id).toList();
            child.forEach((e) => e.hidden.value = !item.check.value);
            setBG();
          }
        },
        onInputEnd: input
            ? (isOk) {
                if (isOk) {
                  item.input.value = false;
                } else {
                  item.check.value = false;
                }
                change(item, null);
                list.forEach((e) => e.enabled = e.parent_id != 0);
              }
            : null,
      );
      return item;
    }));
    list.forEach((e) {
      e.hidden.value = e.parent_id != 0 && map[e.parent_id]!.parent_id != 0;
      e.enabled = e.parent_id != 0;
      map[e.item_id] = e;
    });
    load();
    super.initState();
  }

  @override
  void dispose() {
    loaded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: loaded,
      builder: (context, isLoaded, child) {
        if (!isLoaded) return Center(child: CircularProgressIndicator());
        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: list.map((e) => e.build()).toList(),
          ),
        );
      },
    );
  }
}
