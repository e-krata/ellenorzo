import 'package:refilc_kreta_api/models/subject.dart';

import 'category.dart';

class GroupAverage {
  String uid;
  double average;
  GradeSubject subject;
  Map json;

  GroupAverage({
    required this.uid,
    required this.average,
    required this.subject,
    this.json = const {},
  });

  factory GroupAverage.fromJson(
    Map json,
  ) {
    final subjectJson =
        json['Tantargy'];

    return GroupAverage(
      uid:
          json['Uid']?.toString() ?? '',
      average: _double(
        json['OsztalyCsoportAtlag'] ??
            json['Atlag'],
      ),
      subject:
          subjectJson is Map
              ? GradeSubject.fromJson(
                  subjectJson,
                )
              : GradeSubject(
                  id: json['TantargyUid']
                          ?.toString() ??
                      '',
                  category:
                      Category.fromJson(
                    {},
                  ),
                  name:
                      json['TantargyNev']
                              ?.toString() ??
                          '',
                ),
      json: json,
    );
  }

  static double _double(
    dynamic value,
  ) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}