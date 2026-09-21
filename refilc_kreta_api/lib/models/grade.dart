// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:refilc/utils/format.dart';
import 'package:uuid/uuid.dart';

import 'category.dart';
import 'subject.dart';
import 'teacher.dart';

class Grade {
  Map? json;
  String id;
  DateTime date;
  GradeValue value;
  Teacher teacher;
  String description;
  GradeType type;
  String groupId;
  GradeSubject subject;
  Category? gradeType;
  Category mode;
  DateTime writeDate;
  DateTime seenDate;
  String form;

  Grade({
    required this.id,
    required this.date,
    required this.value,
    required this.teacher,
    required this.description,
    required this.type,
    required this.groupId,
    required this.subject,
    this.gradeType,
    required this.mode,
    required this.writeDate,
    required this.seenDate,
    required this.form,
    this.json,
  });

  factory Grade.fromJson(
    Map json,
  ) {
    final typeJson =
        _map(json['Tipus']);

    final valueTypeJson =
        _map(json['ErtekFajta']);

    final modeJson =
        _map(json['Mod']);

    final groupJson =
        _map(json['OsztalyCsoport']);

    final subjectJson =
        _map(json['Tantargy']);

    return Grade(
      id:
          json['Uid']?.toString() ?? '',
      date: _date(
        json['KeszitesDatuma'] ??
            json['Datum'],
      ),
      value: GradeValue(
        _int(json['SzamErtek']),
        json['SzovegesErtek']
                ?.toString() ??
            '',
        json['SzovegesErtekelesRovidNev']
                ?.toString() ??
            '',
        _int(
          json['SulySzazalekErteke'],
        ),
        percentage:
            valueTypeJson['Uid']
                    ?.toString() ==
                '3,Szazalekos' ||
            valueTypeJson['Nev']
                    ?.toString()
                    .toLowerCase() ==
                'szazalekos',
      ),
      teacher: Teacher.fromString(
        (
          json['ErtekeloTanarNeve'] ??
          json['RogzitoTanarNeve'] ??
          ''
        ).toString().trim(),
      ),
      description: (
        json['Tema'] ??
        json['Temaja'] ??
        ''
      ).toString(),
      type: Category.getGradeType(
        typeJson['Nev']
                ?.toString() ??
            '',
      ),
      groupId: (
        groupJson['Uid'] ??
        json['OsztalyCsoportUid'] ??
        ''
      ).toString(),
      subject:
          subjectJson.isNotEmpty
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
      gradeType:
          valueTypeJson.isNotEmpty
              ? Category.fromJson(
                  valueTypeJson,
                )
              : null,
      mode:
          Category.fromJson(
        modeJson,
      ),
      writeDate: _date(
        json['RogzitesDatuma'] ??
            json['KeszitesDatuma'],
      ),
      seenDate: _date(
        json['LattamozasDatuma'],
      ),
      form:
          (json['Jelleg'] ?? '')
                      .toString() ==
                  'Na'
              ? ''
              : (json['Jelleg'] ?? '')
                  .toString(),
      json: json,
    );
  }

  factory Grade.fromExportJson(
    Map json,
  ) {
    return Grade(
      id: const Uuid().v4(),
      date: json['date'] != null
          ? DateTime.parse(
              json['date'],
            )
          : DateTime(0),
      value: GradeValue(
        json['value'] ?? 0,
        json['value_name'] ?? '',
        json['value_name'] ?? '',
        json['weight'] ?? 0,
        percentage: false,
      ),
      teacher: Teacher.fromString(
        (json['teacher'] ?? '')
            .trim(),
      ),
      description:
          json['description'] ?? '',
      type: json['type'] != null
          ? Category.getGradeType(
              json['type']
                  .replaceAll(
                    'midYear',
                    'evkozi_jegy_ertekeles',
                  )
                  .replaceAll(
                    'halfYear',
                    'felevi_jegy_ertekeles',
                  )
                  .replaceAll(
                    'endYear',
                    'evvegi_jegy_ertekeles',
                  ),
            )
          : GradeType.unknown,
      groupId:
          const Uuid().v4(),
      subject: GradeSubject(
        id: const Uuid().v4(),
        category:
            Category.fromJson({}),
        name:
            json['subject'] ?? '',
      ),
      mode:
          Category.fromJson({}),
      writeDate:
          json['date'] != null
              ? DateTime.parse(
                  json['date'],
                )
              : DateTime(0),
      seenDate:
          json['date'] != null
              ? DateTime.parse(
                  json['date'],
                )
              : DateTime(0),
      form: '',
      json: json,
    );
  }

  bool compareTo(
    dynamic other,
  ) {
    if (runtimeType !=
        other.runtimeType) {
      return false;
    }

    return id == other.id &&
        seenDate == other.seenDate;
  }

  static Map _map(
    dynamic value,
  ) =>
      value is Map
          ? value
          : <String, dynamic>{};

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

class GradeValue {
  int _value;

  set value(int v) =>
      _value = v;

  int get value {
    String _valueName =
        valueName
            .toLowerCase()
            .specialChars();

    if (_value == 0 &&
        [
          'peldas',
          'jo',
          'valtozo',
          'rossz',
          'hanyag',
        ].contains(_valueName)) {
      switch (_valueName) {
        case 'peldas':
          return 5;

        case 'jo':
          return 4;

        case 'valtozo':
          return 3;

        case 'rossz':
          return 2;

        case 'hanyag':
          return 1;

        case 'jeles':
          return 5;

        case 'kozepes':
          return 3;

        case 'elegseges':
          return 2;

        case 'elegtelen':
          return 1;
      }
    }

    return _value;
  }

  String _valueName;

  set valueName(String v) =>
      _valueName = v;

  String get valueName =>
      _valueName.split('(')[0];

  String shortName;

  int _weight;

  set weight(int v) =>
      _weight = v;

  int get weight {
    String _valueName =
        valueName
            .toLowerCase()
            .specialChars();

    if (_value == 0 &&
        [
          'peldas',
          'jo',
          'valtozo',
          'rossz',
          'hanyag',
        ].contains(_valueName)) {
      return 0;
    }

    return _weight;
  }

  final bool _percentage;

  bool get percentage =>
      _percentage;

  GradeValue(
    int value,
    String valueName,
    this.shortName,
    int weight, {
    bool percentage = false,
  })  : _value = value,
        _valueName = valueName,
        _weight = weight,
        _percentage = percentage;
}

enum GradeType {
  midYear,
  firstQ,
  secondQ,
  halfYear,
  thirdQ,
  fourthQ,
  endYear,
  levelExam,
  ghost,
  unknown,
}