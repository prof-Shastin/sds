import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/anamnes/medical/graph.dart';
import 'package:sds_web/pages/patients/patient_edit.dart';
import 'package:sds_web/pages/patients/patient_item.dart';
import 'package:intl/intl.dart';
import 'patient_photo.dart';

class PatientInfo extends StatelessWidget {
  final PatientItem patient;
  final void Function(PatientItem, Uint8List) onEditPatient;
  final void Function() onRemovePatient;
  const PatientInfo({
    super.key,
    required this.patient,
    required this.onEditPatient,
    required this.onRemovePatient,
  });
  @override
  Widget build(BuildContext context) {
    final width = 350.0;
    final list = {
      'Дата рождения': DateFormat('dd.MM.yyyy').format(patient.birth),
      // 'Пол': patient.gender ? 'Мужской' : 'Женский',
      'Телефон': patient.phone,
      'Адрес': patient.address,
      'Начало наблюдения':
          DateFormat('dd.MM.yyyy').format(patient.begin_observation),
      'Заметки': patient.notes,
    };
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFCFE3E8))),
      ),
      child: ListView(
        padding: EdgeInsets.all(10),
        children: [
          SizedBox(height: 30),
          Center(
            child: PatientPhoto(
              patient: patient,
              width: 256,
              key: UniqueKey(),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(30, 15, 30, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          PatientEdit.show(context, patient, onEditPatient),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color(0xff002c52),
                        backgroundColor: Color(0xffd0e3e9),
                        shadowColor: Color(0xffd0e3e9),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        fixedSize: const Size(32, 32),
                        maximumSize: const Size(32, 32),
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        size: 25,
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: width - 165,
                      child: Text(
                        patient.fio,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff002c52),
                        ),
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => confirm(
                              context,
                              'Удалить пациента ${patient.fio}?',
                              'Нет',
                              'Удалить')
                          .then((isRemove) {
                        if (isRemove) onRemovePatient();
                      }),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shadowColor: Color(0xffd0e3e9),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        fixedSize: const Size(32, 32),
                        maximumSize: const Size(32, 32),
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                ...list.keys
                    .map((k) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$k:',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xff8eafb8),
                              ),
                            ),
                            if (list[k].toString().isNotEmpty)
                              Text(
                                list[k].toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xff002c52),
                                ),
                                maxLines: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                            SizedBox(height: 12),
                          ],
                        ))
                    .toList(),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 30, 10, 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border.all(color: Color(0xffD0E3E9)),
            ),
            child: Column(
              children: [
                SizedBox(height: 5),
                Text(
                  'Общее здоровье',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 300,
                  height: 237,
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: FutureBuilder(
                    future: graphMedical(
                      context.read<Model>(),
                      300,
                      237,
                      isShort: true,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return Image.memory(snapshot.data!);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
