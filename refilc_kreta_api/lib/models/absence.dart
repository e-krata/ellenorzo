import 'package:flutter/material.dart';

import 'category.dart';
import 'subject.dart';
import 'teacher.dart';

class Absence {
  Map? json;
  String id;
  DateTime date;
  int delay;
  DateTime submitDate;
  Teacher teacher;
  Justification state;
  Category? justification;
  Category? type;
  Category? mode;
  GradeSubject subject;
  DateTime lessonStart;
  DateTime lessonEnd;
  int? lessonIndex;
  String group;
  bool isSeen;

  @override
  bool operator ==(
    Object other,
  ) =>
      identical(this, other) ||
      other is Absence &&
          runtimeType ==
              other.runtimeType &&
          id == other.id;

  @override
  int get hashCode =>
      id.hashCode;

  Absence({
    required this.id,
    required this.date,
    required this.delay,
    required this.submitDate,
    required this.teacher,
    required this.state,
    this.justification,
    this.type,
    this.mode,
    required this.subject,
    required this.lessonStart,
    required this.lessonEnd,
    this.lessonIndex,
    required this.group,
    this.json,
    this.isSeen = false,
  });

  factory Absence.fromJson(
    Map json,
  ) {
    final lesson =
        _map(json['Ora']);

    final justification =
        _map(json['IgazolasTipusa']);

    final type =
        _map(json['Tipus']);

    final mode =
        _map(json['Mod']);

    final subject =
        _map(json['Tantargy']);

    final group =
        _map(json['OsztalyCsoport']);

    final stateText =
        json['IgazolasAllapota']
                ?.toString()
                .toLowerCase() ??
            '';

    return Absence(
      id:
          json['Uid']?.toString() ?? '',
      date:
          _date(json['Datum']),
      delay:
          _int(
        json['KesesPercben'],
      ),
      submitDate:
          _date(
        json['KeszitesDatuma'],
      ),
      teacher:
          Teacher.fromString(
        (
          json['RogzitoTanarNeve'] ??
          ''
        ).toString().trim(),
      ),
      state:
          stateText == 'igazolt'
              ? Justification.excused
              : stateText ==
                      'igazolando'
                  ? Justification.pending
                  : Justification
                      .unexcused,
      justification:
          justification.isNotEmpty
              ? Category.fromJson(
                  justification,
                )
              : null,
      type:
          type.isNotEmpty
              ? Category.fromJson(
                  type,
                )
              : null,
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
                  name:
                      json['TantargyNev']
                              ?.toString() ??
                          '',
                ),
      lessonStart:
          _date(
        lesson['KezdoDatum'],
      ),
      lessonEnd:
          _date(
        lesson['VegDatum'],
      ),
      lessonIndex:
          _nullableInt(
        lesson['Oraszam'],
      ),
      group: (
        group['Uid'] ??
        json['OsztalyCsoportUid'] ??
        ''
      ).toString(),
      isSeen:
          json['isSeen'] == true,
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

  static int _int(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static int? _nullableInt(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }
}

enum Justification {
  excused,
  unexcused,
  pending,
}

class AbsenceChartData {
  double start;
  double end;
  Color color;

  AbsenceChartData({
    required this.start,
    required this.end,
    this.color = Colors.transparent,
  });
}