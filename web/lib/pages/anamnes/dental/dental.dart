import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/anamnes/anamnes_item.dart';
import 'package:sds_web/pages/anamnes/dental/data.dart';

class Dental extends StatefulWidget {
  final ValueNotifier<int> graphIndex;
  const Dental({super.key, required this.graphIndex});
  @override
  State<Dental> createState() => _DentalState();
}

class _DentalState extends State<Dental> {
  late final Model model;
  final loaded = ValueNotifier(false);
  final list = <AnamnesItem>[];
  final map = <int, AnamnesItem>{};

  void load() {
    loaded.value = false;
    final post = {
      'patient_id': model.patient.value.id,
      'anamnes_id': 2,
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

  void change(int item_id, bool check, String answer) {
    final post = {
      'patient_id': model.patient.value.id,
      'anamnes_id': 2,
      'item_id': item_id,
      'check': check,
      'answer': answer,
    };
    model.post('/anamnes/change', post).then((_) {
      widget.graphIndex.value++;
    });
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
      late final AnamnesItem item;
      item = AnamnesItem(
        item_id: item_id,
        parent_id: parent_id,
        padding: EdgeInsets.fromLTRB(8, main ? 48 : 8, 8, 8),
        title: e[3].toString(),
        titleStyle: TextStyle(
          fontWeight: main ? FontWeight.bold : FontWeight.normal,
        ),
        info: e[4].toString(),
        imgCheckUrl: imgCheckUrl,
        onTap: () {
          item.check.value = !item.check.value;
          change(item.item_id, item.check.value, item.answer.text);
        },
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
