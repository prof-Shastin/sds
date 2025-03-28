import 'package:flutter/material.dart';
import 'package:sds_web/model/model.dart';
import 'package:sds_web/pages/patients/patient_photo.dart';

class PatientItem {
  final int id;
  final String last_name;
  final String first_name;
  final String middle_name;
  final DateTime birth;
  final bool gender;
  final String address;
  final String phone_home;
  final String phone_work;
  final String phone;
  final String email;
  final DateTime begin_observation;
  final String notes;
  final double scale;
  final double offset_x;
  final double offset_y;

  const PatientItem(
    this.id,
    this.last_name,
    this.first_name,
    this.middle_name,
    this.birth,
    this.gender,
    this.address,
    this.phone_home,
    this.phone_work,
    this.phone,
    this.email,
    this.begin_observation,
    this.notes,
    this.scale,
    this.offset_x,
    this.offset_y,
  );

  String get fio =>
      '$last_name $first_name $middle_name'.trim().replaceAll('  ', ' ');

  int get age {
    final d1 = birth;
    final d2 = DateTime.now();
    return d2.year -
        d1.year -
        (d2.month * 31 + d2.day < d1.month * 31 + d1.day ? 1 : 0);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'last_name': last_name,
        'first_name': first_name,
        'middle_name': middle_name,
        'birth': birth,
        'gender': gender,
        'address': address,
        'phone_home': phone_home,
        'phone_work': phone_work,
        'phone': phone,
        'email': email,
        'begin_observation': begin_observation,
        'notes': notes,
        'scale': scale,
        'offset_x': offset_x,
        'offset_y': offset_y,
      };

  factory PatientItem.zero() => PatientItem(0, '', '', '', DateTime.now(), true,
      '', '', '', '', '', DateTime.now(), '', 1, 0, 0);

  factory PatientItem.fromJson(Map json) => PatientItem(
        json['id'] as int,
        json['last_name'] as String,
        json['first_name'] as String,
        json['middle_name'] as String,
        json['birth'] as DateTime,
        json['gender'] as bool,
        json['address'] as String,
        json['phone_home'] as String,
        json['phone_work'] as String,
        json['phone'] as String,
        json['email'] as String,
        json['begin_observation'] as DateTime,
        json['notes'] as String,
        (json['scale'] as num).toDouble(),
        (json['offset_x'] as num).toDouble(),
        (json['offset_y'] as num).toDouble(),
      );

  Widget infoBuild({bool alignRight = false}) {
    return Row(
      children: [
        if (!alignRight) PatientPhoto(patient: this, key: Key('$id')),
        if (!alignRight) SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                fio,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff002c52),
                  height: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: alignRight ? TextAlign.right : TextAlign.left,
              ),
              Text(
                '${getValue(age, 'год', 'года', 'лет')}, на балансе ${getMoney(0)}',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff8eafb8),
                  height: 1.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (alignRight) SizedBox(width: 12),
        if (alignRight) PatientPhoto(patient: this, key: UniqueKey()),
      ],
    );
  }
}
