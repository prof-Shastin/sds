import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/patients/patient_item.dart';

class PatientPhoto extends StatefulWidget {
  final double width;
  final PatientItem patient;
  const PatientPhoto({super.key, required this.patient, this.width = 60});
  @override
  State<PatientPhoto> createState() => _PatientPhotoState();
}

class _PatientPhotoState extends State<PatientPhoto> {
  late final Model model;
  final image = ValueNotifier<Uint8List?>(null);

  void load() {
    image.value = null;
    final post = {
      'id': widget.patient.id,
      'age': widget.patient.age,
      'gender': widget.patient.gender,
    };
    model.post('/patient/photo', post).then((d) => image.value = d);
  }

  @override
  void initState() {
    model = context.read<Model>();
    super.initState();
    load();
  }

  @override
  void dispose() {
    image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: image,
      builder: (context, img, child) {
        return Container(
          width: widget.width,
          height: widget.width,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFF8eafb8)),
            borderRadius: BorderRadius.all(Radius.circular(8)),
            image:
                img == null ? null : DecorationImage(image: MemoryImage(img)),
          ),
          child:
              img == null ? Center(child: CircularProgressIndicator()) : null,
        );
      },
    );
  }
}
