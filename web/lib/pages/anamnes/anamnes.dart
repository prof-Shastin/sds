import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/anamnes/dental/dental.dart';
import 'package:sds_web/pages/anamnes/dental/graph.dart';
import 'package:sds_web/pages/anamnes/diagnostic/diagnostic.dart';
import 'package:sds_web/pages/anamnes/diagnostic/graph.dart';
import 'package:sds_web/pages/anamnes/medical/graph.dart';
import 'package:sds_web/pages/anamnes/medical/medical.dart';
import 'package:sds_web/pages/anamnes/psycho/graph.dart';
import 'package:sds_web/pages/anamnes/psycho/psycho.dart';

class Anamnes extends StatefulWidget {
  const Anamnes({super.key});
  @override
  State<Anamnes> createState() => _AnamnesState();
}

class _AnamnesState extends State<Anamnes> {
  late final Model model;
  final index = ValueNotifier(0);
  final graphIndex = ValueNotifier(0);
  final graph = [graphMedical, graphDental, graphDiagnostic, graphPsycho];
  final size = [Size(300, 350), Size(300, 350), Size(300, 350), Size(380, 200)];
  final list = [
    'Медицинский анамнез',
    'Стоматологический анамнез',
    'Диагностическое заключение',
    'Психотип',
  ];

  @override
  void initState() {
    model = context.read<Model>();
    super.initState();
  }

  @override
  void dispose() {
    index.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: model.leftWitch,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Color(0xFFCFE3E8))),
          ),
          child: ValueListenableBuilder(
            valueListenable: index,
            builder: (context, ind, child) => Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(
                      list.length,
                      (i) => RadioListTile(
                        value: i,
                        groupValue: ind,
                        onChanged: (_) => index.value = i,
                        title: Text(
                          list[i],
                          style: TextStyle(color: Color(0xff002C52)),
                        ),
                        fillColor: WidgetStateProperty.all(Color(0xff002C52)),
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: ValueListenableBuilder(
                      valueListenable: graphIndex,
                      builder: (context, _, child) => SizedBox(
                        width: size[ind].width,
                        height: size[ind].height,
                        child: FutureBuilder(
                          future: graph[ind](model, size[ind].width.toInt(),
                              size[ind].height.toInt()),
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {
                              return Center(child: CircularProgressIndicator());
                            }
                            return Image.memory(snapshot.data!);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: index,
            builder: (context, ind, child) {
              if (ind == 0) return Medical(graphIndex: graphIndex);
              if (ind == 1) return Dental(graphIndex: graphIndex);
              if (ind == 2) return Diagnostic(graphIndex: graphIndex);
              if (ind == 3) return Psycho(graphIndex: graphIndex);
              return SizedBox();
            },
          ),
        ),
      ],
    );
  }
}
