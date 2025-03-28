import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/anamnes/anamnes.dart';
import 'package:sds_web/pages/exam/exam.dart';
import 'package:sds_web/pages/patients/patients.dart';

class Panel extends StatefulWidget {
  const Panel({super.key});
  @override
  State<Panel> createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  late final Model model;
  final select = ValueNotifier<int>(0);
  final over = ValueNotifier<int>(-1);
  final scroll = ScrollController();
  final items = [
    "Пациенты",
    "Анамнез",
    "Осмотр",
    "План лечения",
    "Лечение",
    "Финансы",
  ];
  final bodyItems = [
    Patients(),
    Anamnes(),
    Exam(),
    SizedBox(),
    SizedBox(),
    SizedBox(),
  ];

  @override
  void initState() {
    super.initState();
    model = context.read<Model>();
    model.load();
  }

  @override
  void dispose() {
    select.dispose();
    over.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widthMax = 1500.0;
    final size = MediaQuery.of(context).size;
    return ValueListenableBuilder(
      valueListenable: model.loaded,
      builder: (context, isLoaded, child) {
        if (!isLoaded) return Center(child: CircularProgressIndicator());
        return SizedBox(
          width: size.width,
          height: size.height,
          child: Scrollbar(
            //scrollbarOrientation: ScrollbarOrientation.bottom,
            controller: scroll,
            child: ListView(
              controller: scroll,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  width: size.width < widthMax ? widthMax : size.width,
                  height: size.height,
                  child: ValueListenableBuilder(
                    valueListenable: select,
                    builder: (context, sInd, child) {
                      return Column(
                        children: [
                          ValueListenableBuilder(
                            valueListenable: over,
                            builder: (context, oInd, child) => Row(
                              children: [
                                Container(
                                  width: 74,
                                  height: 74,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right:
                                          BorderSide(color: Color(0xffCFE3E8)),
                                      bottom: BorderSide(
                                          color: Color(0xffCFE3E8), width: 2),
                                    ),
                                    color: Color(0xffEBEFF3),
                                  ),
                                  child: Center(
                                    child: Image.network(
                                      model.getApiImgUri('/tooth.png'),
                                      width: 45,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 30,
                                  height: 74,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: Color(0xffCFE3E8), width: 2),
                                    ),
                                    color: Color(0xffEBEFF3),
                                  ),
                                ),
                                ...List.generate(items.length, (i) {
                                  return InkWell(
                                    onTap: () {
                                      if (model.patient.value.id != 0)
                                        select.value = i;
                                    },
                                    child: MouseRegion(
                                      onEnter: (_) => over.value = i,
                                      onExit: (_) => over.value = -1,
                                      child: Container(
                                        height: 74,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Color(
                                                i == sInd
                                                    ? 0xff002C52
                                                    : i == oInd
                                                        ? 0x80647483
                                                        : 0xffCFE3E8,
                                              ),
                                              width: 2,
                                            ),
                                          ),
                                          color: Color(0xffEBEFF3),
                                        ),
                                        child: Center(
                                          child: Text(
                                            items[i],
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(
                                                i == sInd
                                                    ? 0xff002C52
                                                    : 0xff647483,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                Expanded(
                                  child: Container(
                                    height: 74,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Color(0xffCFE3E8), width: 2),
                                      ),
                                      color: Color(0xffEBEFF3),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: ValueListenableBuilder(
                                          valueListenable: model.patient,
                                          builder: (context, patient, child) =>
                                              patient.infoBuild(
                                                  alignRight: true),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 74,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right:
                                          BorderSide(color: Color(0xffCFE3E8)),
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 74,
                                        height: 74,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(22),
                                            bottomRight: Radius.circular(22),
                                          ),
                                          color: Color(0xff002C52),
                                        ),
                                        child: Icon(
                                          Icons.people,
                                          size: 45,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(child: bodyItems[sInd]),
                              ],
                            ),
                          ),
                          Container(
                            height: 30,
                            color: Color(0xFFCFE3E8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: ValueListenableBuilder(
                                      valueListenable: model.countPatients,
                                      builder: (context, count, child) =>
                                          Text(count == null
                                              ? ''
                                              : getValue(
                                                  count,
                                                  'пациент',
                                                  'пациента',
                                                  ' пациентов',
                                                ))),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Text(
                                      'Главный врач: Шастин Евгений Николаевич'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
