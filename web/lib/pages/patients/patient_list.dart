import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sds_web/model/model.dart';
import 'patient_edit.dart';
import 'patient_item.dart';

class PatientList extends StatefulWidget {
  final ValueNotifier<int> reloadIndex;
  final void Function(PatientItem, Uint8List) onCreatePatient;
  const PatientList({
    super.key,
    required this.reloadIndex,
    required this.onCreatePatient,
  });
  @override
  State<PatientList> createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  late final Model model;
  final loaded = ValueNotifier(false);
  final over = ValueNotifier(0);
  final list = <PatientItem>[];

  void load() {
    loaded.value = false;
    model.get('/patient/list').then((d) {
      list.clear();
      list.addAll((d as List).map((e) => PatientItem.fromJson(e)).toList());
      if (model.patient.value.id == 0) model.patient.value = list.first;
      model.countPatients.value = list.length;
      loaded.value = true;
    });
  }

  @override
  void initState() {
    model = context.read<Model>();
    widget.reloadIndex.addListener(load);
    super.initState();
    load();
  }

  @override
  void dispose() {
    widget.reloadIndex.removeListener(load);
    over.dispose();
    loaded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: model.leftWitch,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFCFE3E8))),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: RawMaterialButton(
              onPressed: () =>
                  PatientEdit.show(context, null, widget.onCreatePatient),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xff002C52)),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Center(
                  child: Text(
                    'Создать пациента',
                    style: TextStyle(fontSize: 16, color: Color(0xff002C52)),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 25,
                  color: Color(0xff002c52),
                ),
                hintText: 'Поиск',
                hintStyle: TextStyle(fontSize: 16, color: Color(0x80002c52)),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: loaded,
              builder: (context, isLoaded, child) {
                if (!isLoaded) {
                  return Center(child: CircularProgressIndicator());
                }
                if (list.isEmpty) {
                  return Center(child: Text('Пациенты не найдены'));
                }
                return ValueListenableBuilder(
                  valueListenable: over,
                  builder: (context, ov, child) => ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final p = list[index];
                      return InkWell(
                        onTap: model.patient.value.id == p.id
                            ? null
                            : () {
                                model.patient.value = p;
                                loaded.value = false;
                                loaded.value = true;
                              },
                        child: MouseRegion(
                          onEnter: (e) => over.value = p.id,
                          onExit: (e) => over.value = 0,
                          child: Container(
                            height: 80,
                            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                            color: Color(model.patient.value.id == p.id
                                ? 0xffcfe3e8
                                : ov == p.id
                                    ? 0x80BDDDFC
                                    : 0xffffffff),
                            child: p.infoBuild(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
