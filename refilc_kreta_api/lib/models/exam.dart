import 'package:refilc_kreta_api/models/subject.dart';

import 'category.dart';
import 'teacher.dart';

class Exam {
  Map? json;
  DateTime date;
  DateTime writeDate;
  Category? mode;
  GradeSubject subject;
  Teacher teacher;
  String description;
  String group;
  String id;

  Exam({
    required this.id,
    required this.date,
    required this.writeDate,
    this.mode,
    required this.subject,
    required this.teacher,
    required this.description,
    required this.group,
    this.json,
  });

  factory Exam.fromJson(
    Map json,
  ) {
    final mode =
        _map(json['Modja']);

    final subject =
        _map(json['Tantargy']);

    final group =
        _map(json['OsztalyCsoport']);

    return Exam(
      id:
          json['Uid']?.toString() ?? '',
      date:
          _date(
        json['BejelentesDatuma'] ??
            json['Datum'],
      ),
      writeDate:
          _date(
        json['Datum'],
      ),
      mode:
          mode.isNotEmpty
              ? Category.fromJson(
                  mode,
                )
              : null,
      subject:
          subject.isNotEmpty
              ? GradeSubject.fromJson(
                  subject,
                )
              : GradeSubject(
                  id: json['TantargyUid']
                          ?.toString() ??
                      '',
                  category:
                      Category.fromJson(
                    {},
                  ),
                  name: (
                    json['TantargyNeve'] ??
                    json['TantargyNev'] ??
                    ''
                  ).toString(),
                ),
      teacher:
          Teacher.fromString(
        (
          json['RogzitoTanarNeve'] ??
          ''
        ).toString().trim(),
      ),
      description: (
        json['Temaja'] ??
        json['Tema'] ??
        ''
      ).toString().trim(),
      group: (
        group['Uid'] ??
        json['OsztalyCsoportUid'] ??
        ''
      ).toString(),
      json: json,
    );
  }

  static Map _map(
    dynamic value,
  ) =>
      value is Map
          ? value
          : <String, dynamic>{};

  static DateTime _date(
    dynamic value,
  ) {
    if (value == null ||
        value.toString().isEmpty) {
      return DateTime(0);
    }

    return DateTime.tryParse(
          value.toString(),
        )?.toLocal() ??
        DateTime(0);
  }
}