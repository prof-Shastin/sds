import 'package:flutter/material.dart';
import 'package:sds_web/pages/patients/patient_item.dart';
import 'package:collection/collection.dart';

enum TPType { none, middle, success }

class TreatmentProgress extends StatelessWidget {
  static const titles = [
    'Анамнез',
    'Осмотр',
    'Заключение',
    'План лечения',
    'Оплата',
    'Лечение',
  ];
  final PatientItem patient;
  final List<TPType> values;
  const TreatmentProgress({
    super.key,
    required this.patient,
    required this.values,
  });
  @override
  Widget build(BuildContext context) {
    final textWidth = 150.0, checkWidth = 64.0;
    final leftWidth = (textWidth - checkWidth) / 2;
    final list = <Widget>[];
    list.add(SizedBox(width: leftWidth));
    for (var i = 0; i < titles.length; i++) {
      final type = i < values.length ? values[i] : TPType.none;
      if (i > 0) {
        list.add(Expanded(
          child: Container(
            height: 2,
            color: Color(type == TPType.success ? 0xff32B950 : 0xff8EAFB8),
          ),
        ));
      }
      if (i > 0) list.add(SizedBox(width: 8));
      list.add(Container(
        width: checkWidth,
        height: checkWidth,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Color(type == TPType.success ? 0xff32B950 : 0xff8EAFB8),
          ),
          borderRadius: BorderRadius.all(Radius.circular(checkWidth / 2)),
          color: Color(type == TPType.none
              ? 0xffffff
              : type == TPType.middle
                  ? 0xffffff00
                  : 0xff32B950),
        ),
        child: type == TPType.success
            ? Center(
                child: Icon(
                  Icons.check,
                  size: checkWidth * 0.7,
                  color: Colors.white,
                ),
              )
            : null,
      ));
      if (i + 1 < titles.length) list.add(SizedBox(width: 8));
      if (i + 1 < titles.length) {
        list.add(Expanded(
          child: Container(
            height: 2,
            color: Color(type == TPType.success ? 0xff32B950 : 0xff8EAFB8),
          ),
        ));
      }
    }
    list.add(SizedBox(width: leftWidth));
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Column(
        children: [
          Row(children: list),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: titles
                .mapIndexed((i, e) => SizedBox(
                      width: textWidth,
                      child: Center(
                        child: Text(
                          e,
                          style: TextStyle(
                            fontSize: 22,
                            color: Color(0xff8EAFB8),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
