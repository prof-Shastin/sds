import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/exam/dental_view.dart';
import 'package:sds_web/pages/patients/patient_info.dart';
import 'package:sds_web/pages/patients/patient_list.dart';
import 'package:sds_web/pages/patients/patient_right.dart';
import 'patient_complex.dart';
import 'patient_item.dart';
import 'treatment_progress.dart';

class Patients extends StatefulWidget {
  const Patients({super.key});
  @override
  State<Patients> createState() => _PatientsState();
}

class _PatientsState extends State<Patients> {
  late final Model model;
  late final DentalView dentalView;
  final reloadIndex = ValueNotifier(0);

  @override
  void initState() {
    model = context.read<Model>();
    dentalView = DentalView(model: model);
    super.initState();
  }

  @override
  void dispose() {
    dentalView.dispose();
    reloadIndex.dispose();
    super.dispose();
  }

  void savePatient(PatientItem p, Uint8List d) {
    showProcessed(context);
    model.post('/patient/change', d).then((d) {
      if (d is! Map || (d['id'] ?? 0) == 0) {
        hideProcessed(context);
        message(context, 'Не удалось сохранить пациента, попробуйте еще раз');
        return;
      }
      final pp = p.toJson();
      pp['id'] = d['id'];
      model.patient.value = PatientItem.fromJson(pp);
      reloadIndex.value++;
      hideProcessed(context);
    }).catchError((_) {
      hideProcessed(context);
      message(context, 'Не удалось сохранить пациента, попробуйте еще раз');
    });
  }

  void removePatient() {
    showProcessed(context);
    model.post('/patient/remove', {'patient_id': model.patient.value.id}).then(
        (d) {
      model.patient.value = PatientItem.zero();
      reloadIndex.value++;
      hideProcessed(context);
    }).catchError((_) {
      hideProcessed(context);
      message(context, 'Не удалось удалить пациента, попробуйте еще раз');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PatientList(reloadIndex: reloadIndex, onCreatePatient: savePatient),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: model.patient,
            builder: (context, patient, child) {
              if (patient.id == 0) return SizedBox();
              dentalView.load();
              return Column(
                children: [
                  PatientComplex(patient: patient),
                  TreatmentProgress(patient: patient, values: [
                    TPType.none,
                    TPType.middle,
                    TPType.success,
                    TPType.middle,
                    TPType.none,
                  ]),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFCFE3E8)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PatientInfo(
                          patient: patient,
                          onEditPatient: savePatient,
                          onRemovePatient: removePatient,
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: dentalView.build(),
                          ),
                        ),
                        PatientRight(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
