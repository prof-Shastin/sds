import 'package:flutter/material.dart';
import 'package:sds_web/pages/patients/patient_item.dart';

class PatientComplex extends StatelessWidget {
  final PatientItem patient;
  const PatientComplex({super.key, required this.patient});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Container(
            width: 140,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Color(0xffD74949),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Color(0xffD0E3E9),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Color(0xffD0E3E9),
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            width: 140,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Color(0xff4E9D1E),
            ),
          ),
        ],
      ),
    );
  }
}
