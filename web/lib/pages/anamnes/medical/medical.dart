import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/anamnes/anamnes_item.dart';
import 'package:sds_web/pages/anamnes/medical/data.dart';

class Medical extends StatefulWidget {
  final ValueNotifier<int> graphIndex;
  const Medical({super.key, required this.graphIndex});
  @override
  State<Medical> createState() => _MedicalState();
}

class _MedicalState extends State<Medical> {
  late final Model model;
  final loaded = ValueNotifier(false);
  final list = <AnamnesItem>[];
  final map = <int, AnamnesItem>{};

  void load() {
    loaded.value = false;
    final post = {
      'patient_id': model.patient.value.id,
      'anamnes_id': 1,
    };
    model.post('/anamnes/list', post).then((d) {
      final l = d as List;
      l.forEach((e) {
        final item = map[e['item_id']]!;
        item.check.value = e['check'];
        item.answer.text = e['answer'];
      });
      loaded.value = true;
    });
  }

  void change(int item_id, bool check, String answer) {
    final post = {
      'patient_id': model.patient.value.id,
      'anamnes_id': 1,
      'item_id': item_id,
      'check': check,
      'answer': answer,
    };
    model.post('/anamnes/change', post).then((_) {
      widget.graphIndex.value++;
    });
  }

  @override
  void initState() {
    model = context.read<Model>();
    final imgCheckUrl = model.getApiImgUri('/check.png');
    list.addAll(data.map((e) {
      final input = e[1] as bool;
      final item_id = e[0] as int;
      late final AnamnesItem item;
      item = AnamnesItem(
          item_id: item_id,
          title: e[4].toString(),
          info: e[5].toString(),
          imgCheckUrl: imgCheckUrl,
          onTap: () {
            if (item.check.value || !input) {
              item.check.value = !item.check.value;
              change(item_id, item.check.value, item.answer.text);
              return;
            }
            item.check.value = true;
            item.input.value = true;
            list.forEach((e) => e.enabled = false);
          },
          onInputEnd: input
              ? (isOk) {
                  if (isOk) {
                    item.input.value = false;
                  } else {
                    item.check.value = false;
                  }
                  change(item_id, item.check.value, item.answer.text);
                  list.forEach((e) => e.enabled = true);
                }
              : null);
      return item;
    }));
    for (var i = 0; i < list.length; i++) {
      list[i].bg.value = (i & 1) == 0;
      map[list[i].item_id] = list[i];
    }
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
