import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/patients/patient_item.dart';
import 'package:file_picker/file_picker.dart';

const width = 256.0;

class PatientPhotoEdit extends StatefulWidget {
  final ValueNotifier<PatientItem> patient;
  final void Function(Uint8List?) onChange;
  const PatientPhotoEdit({
    super.key,
    required this.patient,
    required this.onChange,
  });
  @override
  State<PatientPhotoEdit> createState() => _PatientPhotoEditState();
}

class _PatientPhotoEditState extends State<PatientPhotoEdit> {
  late final Model model;
  final loaded = ValueNotifier(false);
  final images = List<Uint8List?>.filled(5, null);
  final urlImages = [
    '',
    'no-M-1.png',
    'no-F-1.png',
    'no-M-0.png',
    'no-F-0.png',
  ];
  var size = Size.zero;
  var scale = 0.0;
  var offset = Offset.zero;

  Future<void> getPhoto() async {
    final d = await FilePicker.platform.pickFiles(type: FileType.image);
    if (d?.files.first.bytes == null) return;
    final codec = await instantiateImageCodec(d!.files.first.bytes!);
    final frame = await codec.getNextFrame();
    size = Size(frame.image.width.toDouble(), frame.image.height.toDouble());
    images[0] = d.files.first.bytes;
    final p = widget.patient.value.toJson();
    scale = width / min(size.width, size.height);
    p['scale'] = scale;
    p['offset_x'] = (width - p['scale'] * size.width) / 2;
    p['offset_y'] = (width - p['scale'] * size.height) / 2;
    widget.patient.value = PatientItem.fromJson(p);
    widget.onChange(images[0]);
  }

  void change(PatientItem patient, {double? s, Offset? o}) {
    if (images[0] == null) return;
    final p = patient.toJson();
    if (s != null) {
      p['scale'] = s;
      if (p['scale'] < scale) p['scale'] = scale;
      if (p['scale'] > scale * 5) p['scale'] = scale * 5;
      p['offset_x'] = width * 0.5 -
          (width * 0.5 - p['offset_x']) * p['scale'] / patient.scale;
      p['offset_y'] = width * 0.5 -
          (width * 0.5 - p['offset_y']) * p['scale'] / patient.scale;
    }
    if (o != null) {
      p['offset_x'] = o.dx;
      p['offset_y'] = o.dy;
    }
    if (p['offset_x'] > 0.0) p['offset_x'] = 0.0;
    if (p['offset_x'] < width - size.width * p['scale']) {
      p['offset_x'] = width - size.width * p['scale'];
    }
    if (p['offset_y'] > 0.0) p['offset_y'] = 0.0;
    if (p['offset_y'] < width - size.height * p['scale']) {
      p['offset_y'] = width - size.height * p['scale'];
    }
    widget.patient.value = PatientItem.fromJson(p);
  }

  void load() {
    loaded.value = false;
    var countLoaded = 0;
    for (var i = 0; i < urlImages.length; i++) {
      if (urlImages[i].isEmpty) {
        countLoaded++;
        continue;
      }
      model
          .get('/images/patients/${urlImages[i]}', isRaw: true)
          .then((d) async {
        if (d.statusCode == 200) images[i] = d.bodyBytes;
        countLoaded++;
        if (countLoaded == urlImages.length) {
          if (images[0] != null) {
            final codec = await instantiateImageCodec(images[0]!);
            final frame = await codec.getNextFrame();
            size = Size(
                frame.image.width.toDouble(), frame.image.height.toDouble());
            scale = width / min(size.width, size.height);
            widget.onChange(images[0]);
          }
          loaded.value = true;
        }
      });
    }
  }

  @override
  void initState() {
    model = context.read<Model>();
    size = Size(width, width);
    if (widget.patient.value.id != 0) {
      urlImages[0] = '${widget.patient.value.id}/source.jpeg';
    }
    super.initState();
    load();
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
      builder: (context, isLoaded, child) => ValueListenableBuilder(
        valueListenable: widget.patient,
        builder: (context, patient, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onPanUpdate: (e) => change(patient,
                    o: Offset(e.localPosition.dx - offset.dx,
                        e.localPosition.dy - offset.dy)),
                onPanDown: (e) => offset = Offset(
                    e.localPosition.dx - patient.offset_x,
                    e.localPosition.dy - patient.offset_y),
                onTap: () {
                  if (images[0] == null) getPhoto();
                },
                child: Container(
                  width: width,
                  height: width,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF8eafb8)),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: isLoaded
                      ? ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          child: Stack(
                            children: [
                              Positioned(
                                left: patient.offset_x,
                                top: patient.offset_y,
                                width: size.width * patient.scale,
                                height: size.height * patient.scale,
                                child: Image.memory(
                                  images[images[0] != null
                                      ? 0
                                      : patient.age < 18
                                          ? patient.gender
                                              ? 3
                                              : 4
                                          : patient.gender
                                              ? 1
                                              : 2]!,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(child: CircularProgressIndicator()),
                ),
              ),
              SizedBox(width: 5),
              Column(
                children: [
                  IconButton(
                    onPressed: () => change(patient, s: patient.scale + 0.1),
                    icon: Icon(
                      Icons.zoom_in,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () => change(patient, s: patient.scale - 0.1),
                    icon: Icon(
                      Icons.zoom_out,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (images[0] == null) return;
                      size = Size(width, width);
                      images[0] = null;
                      final p = patient.toJson();
                      p['scale'] = 1.0;
                      p['offset_x'] = 0.0;
                      p['offset_y'] = 0.0;
                      widget.patient.value = PatientItem.fromJson(p);
                      widget.onChange(images[0]);
                    },
                    icon: Icon(
                      Icons.close,
                      size: 30,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
