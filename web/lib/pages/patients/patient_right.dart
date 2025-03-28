import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/anamnes/dental/graph.dart';
import 'package:sds_web/pages/anamnes/diagnostic/graph.dart';

class PatientRight extends StatelessWidget {
  const PatientRight({super.key});
  @override
  Widget build(BuildContext context) {
    final width = 350.0;
    final model = context.read<Model>();
    return SizedBox(
      width: width,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 10, 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border.all(color: Color(0xffD0E3E9)),
            ),
            child: Column(
              children: [
                SizedBox(height: 5),
                Text(
                  'Диаграмма риска',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 300,
                  height: 350,
                  child: FutureBuilder(
                    future: graphDental(model, 300, 350),
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
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border.all(color: Color(0xffD0E3E9)),
            ),
            child: Column(
              children: [
                SizedBox(height: 5),
                Text(
                  'Диагностическое заключение',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 300,
                  height: 350,
                  child: FutureBuilder(
                    future: graphDiagnostic(model, 300, 350),
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
