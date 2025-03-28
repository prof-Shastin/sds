import 'package:flutter/material.dart' hide Switch;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/exam/exam_list.dart';
import 'dental_view.dart';
import 'tools.dart';

class Exam extends StatefulWidget {
  const Exam({super.key});
  @override
  State<Exam> createState() => _ExamState();
}

class _ExamState extends State<Exam> {
  late final Model model;
  late final Tools tools;
  late final ExamList list;
  late final DentalView dental;

  @override
  void initState() {
    model = context.read<Model>();
    tools = Tools(onChanged: () => dental.load(), model: model);
    dental = DentalView(
      model: model,
      onSelect: tools.select,
      onImageLoad: (im) => list.change(im),
    );
    list = ExamList(
      model: model,
      onSelect: (id, isLast, dd) {
        dental.setImage(isLast ? id : 0, dd);
        tools.setParent(isLast ? id : 0);
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    dental.dispose();
    tools.dispose();
    list.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) => tools.changePosition(e.localPosition),
      child: Container(
        color: Color(0x01ffffff),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                tools.build(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: dental.build(),
                  ),
                ),
                list.build(),
              ],
            ),
            tools.buildHint(),
            tools.buildSwitch(),
          ],
        ),
      ),
    );
  }
}
