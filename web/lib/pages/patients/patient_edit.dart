import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/patients/patient_item.dart';
import 'package:sds_web/pages/patients/patient_photo_edit.dart';
import 'package:crypto/crypto.dart';

class PatientEdit extends StatefulWidget {
  static void show(
    BuildContext context,
    PatientItem? patient,
    void Function(PatientItem, Uint8List) onDone,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => PatientEdit(patient: patient, onDone: onDone),
    );
  }

  final PatientItem? patient;
  final void Function(PatientItem, Uint8List) onDone;
  const PatientEdit({super.key, this.patient, required this.onDone});
  @override
  State<PatientEdit> createState() => _PatientEditState();
}

class _PatientEditState extends State<PatientEdit> {
  late final Model model;
  final data = <List<dynamic>>[
    ['Фамилия', 'last_name', true],
    ['Домашний телефон', 'phone_home', false],
    ['Имя', 'first_name', true],
    ['Рабочий телефон', 'phone_work', false],
    ['Отчество', 'middle_name', false],
    ['Сотовый телефон', 'phone', false],
    ['Дата рождения', 'birth', true],
    ['Электронная почта', 'email', false],
    ['Пол', 'gender', false],
    ['Адрес', 'address', false],
    ['Начало наблюдения', 'begin_observation', false],
    ['Заметки', 'notes', false],
  ];
  final contList = <TextEditingController>[];
  final gender = ValueNotifier(true);
  final err = ValueNotifier(true);
  final patient = ValueNotifier(PatientItem.zero());
  Uint8List? image;

  @override
  void initState() {
    model = context.read<Model>();
    if (widget.patient != null) patient.value = widget.patient!;
    gender.value = patient.value.gender;
    checkBtn();
    super.initState();
  }

  @override
  void dispose() {
    contList.forEach((e) => e.dispose());
    gender.dispose();
    err.dispose();
    patient.dispose();
    super.dispose();
  }

  void checkBtn() {
    var isErr = false;
    final p = patient.value.toJson();
    data.forEach((e) {
      if (e.last != true) return;
      if (p[e[1]] is String && p[e[1]].isEmpty) isErr = true;
      if (p[e[1]] is DateTime &&
          DateTime.now().difference(p[e[1]]).inDays <= 0) {
        isErr = true;
      }
    });
    err.value = isErr;
  }

  Future<void> save() async {
    final res = <int>[];
    var d = utf8.encode(jsonEncode(patient.value.toJson(), toEncodable: (o) {
      if (o is DateTime) return o.toString();
      return o;
    }));
    res.addAll(Uint32List.fromList([d.length]).buffer.asUint8List());
    res.addAll(d);
    res.addAll(Uint32List.fromList([image?.length ?? 0]).buffer.asUint8List());
    if (image != null) res.addAll(image!);
    if (image == null) {
      res.addAll(Uint32List.fromList([0]).buffer.asUint8List());
    } else {
      final codec = await instantiateImageCodec(image!);
      final frame = await codec.getNextFrame();
      final recorder = PictureRecorder();
      final dst = Rect.fromLTWH(0, 0, width * 2, width * 2);
      final canvas = Canvas(recorder, dst);
      final src = Rect.fromLTWH(
        -patient.value.offset_x / patient.value.scale,
        -patient.value.offset_y / patient.value.scale,
        width / patient.value.scale,
        width / patient.value.scale,
      );
      canvas.drawImageRect(frame.image, src, dst, Paint());
      frame.image.dispose();
      final im = await recorder
          .endRecording()
          .toImage((width * 2).toInt(), (width * 2).toInt());
      d = (await im.toByteData(format: ImageByteFormat.png))
              ?.buffer
              .asUint8List() ??
          Uint8List(0);
      im.dispose();
      res.addAll(Uint32List.fromList([d.length]).buffer.asUint8List());
      res.addAll(d);
    }
    d = utf8.encode(md5.convert(res).toString());
    res.insertAll(0, d);
    res.insertAll(0, Uint32List.fromList([d.length]).buffer.asUint8List());
    Navigator.pop(context);
    widget.onDone(patient.value, Uint8List.fromList(res));
  }

  Widget field(int index) {
    final d = data[index];
    final p = patient.value.toJson();
    final cont = TextEditingController();
    contList.add(cont);
    final isDate = p[d[1]] is DateTime;
    final v = isDate ? DateFormat('dd.MM.yyyy').format(p[d[1]]) : '${p[d[1]]}';
    cont.text = v;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              d.first,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff002c52),
              ),
            ),
            SizedBox(width: 5),
            if (d.last == true)
              Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xffff2e2e),
                ),
              ),
          ],
        ),
        SizedBox(height: 3),
        Container(
          decoration: BoxDecoration(
            color: Color(0xffebeff3),
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: TextField(
            readOnly: isDate,
            controller: cont,
            onChanged: (t) {
              final p = patient.value.toJson();
              p[d[1]] = t;
              patient.value = PatientItem.fromJson(p);
              if (d.last == true) checkBtn();
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              suffixIcon: isDate
                  ? Icon(
                      Icons.calendar_month_rounded,
                      size: 25,
                      color: Color(0xff002c52),
                    )
                  : null,
              hintText: d.first,
              hintStyle: TextStyle(fontSize: 16, color: Color(0xff8eafb8)),
            ),
            style: TextStyle(fontSize: 16, color: Color(0xff002c52)),
            onTap: isDate
                ? () {
                    final p = patient.value.toJson();
                    showDatePicker(
                      context: context,
                      initialDate: p[d[1]],
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      locale: Locale('ru'),
                    ).then((v) {
                      if (v == null) return;
                      p[d[1]] = v;
                      patient.value = PatientItem.fromJson(p);
                      cont.text = DateFormat('dd.MM.yyyy').format(v);
                      if (d.last == true) checkBtn();
                    });
                  }
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 550,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: Color(0xffdddddd), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 70,
              padding: EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xffdddddd)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.patient == null
                          ? 'Создать пациента'
                          : 'Изменить пациента',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff002C52),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      size: 30,
                      color: Color(0xff002C52),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: PatientPhotoEdit(
                patient: patient,
                onChange: (im) => image = im,
              ),
            ),
            ...List.generate(
              (data.length / 2).ceil(),
              (i) => Row(
                children: List.generate(2, (j) {
                  final ind = i * 2 + j;
                  if (ind >= data.length) return SizedBox();
                  if (ind != 8) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            j == 0 ? 20 : 8, 0, j == 0 ? 8 : 20, 15),
                        child: field(ind),
                      ),
                    );
                  }
                  return Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: gender,
                      builder: (context, sex, child) {
                        return Row(
                          children: [
                            Expanded(
                              child: RadioListTile(
                                value: 0,
                                groupValue: sex ? 0 : 1,
                                onChanged: (v) {
                                  gender.value = true;
                                  final p = patient.value.toJson();
                                  p['gender'] = gender.value;
                                  patient.value = PatientItem.fromJson(p);
                                },
                                title: const Text('Муж.'),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile(
                                value: 1,
                                groupValue: sex ? 0 : 1,
                                onChanged: (v) {
                                  gender.value = false;
                                  final p = patient.value.toJson();
                                  p['gender'] = gender.value;
                                  patient.value = PatientItem.fromJson(p);
                                },
                                title: const Text('Жен.'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xffdddddd)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ValueListenableBuilder(
                    valueListenable: err,
                    builder: (context, er, child) => ElevatedButton(
                      onPressed: er ? null : save,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xff002C52),
                        shadowColor: Color(0xffd0e3e9),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(20),
                      ),
                      child: Text(
                        widget.patient == null ? 'Создать' : 'Изменить',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xffE84A4A),
                      shadowColor: Color(0xffd0e3e9),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(20),
                    ),
                    child: Text(
                      'Отмена',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
