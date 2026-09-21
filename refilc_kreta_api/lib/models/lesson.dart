import 'subject.dart';
import 'category.dart';
import 'teacher.dart';

class Lesson {
  Map? json;
  Category? status;
  DateTime date;
  GradeSubject subject;
  String lessonIndex;
  int? lessonYearIndex;
  Teacher? substituteTeacher;
  Teacher teacher;
  bool homeworkEnabled;
  DateTime start;
  DateTime end;
  bool studentPresence;
  String homeworkId;
  String exam;
  String id;
  Category? type;
  String description;
  String room;
  String groupName;
  String name;
  bool online;
  bool isEmpty;
  bool isSeen;

  Lesson({
    this.status,
    required this.date,
    required this.subject,
    required this.lessonIndex,
    this.lessonYearIndex,
    this.substituteTeacher,
    required this.teacher,
    this.homeworkEnabled = false,
    required this.start,
    required this.end,
    this.studentPresence = true,
    required this.homeworkId,
    this.exam = '',
    required this.id,
    this.type,
    required this.description,
    required this.room,
    required this.groupName,
    required this.name,
    this.online = false,
    this.isEmpty = false,
    this.json,
    this.isSeen = false,
  });

  @override
  bool operator ==(
    Object other,
  ) =>
      identical(this, other) ||
      other is Lesson &&
          runtimeType ==
              other.runtimeType &&
          id == other.id;

  @override
  int get hashCode =>
      id.hashCode;

  factory Lesson.fromJson(
    Map json,
  ) {
    final statusJson =
        _map(json['Allapot']);

    final subjectJson =
        _map(json['Tantargy']);

    final presenceJson =
        _map(json['TanuloJelenlet']);

    final typeJson =
        _map(json['Tipus']);

    final groupJson =
        _map(json['OsztalyCsoport']);

    final substituteName =
        json['HelyettesTanarNeve']
                ?.toString()
                .trim() ??
            '';

    final roomRaw = (
      json['TeremNeve'] ??
      json['Terem'] ??
      ''
    ).toString();

    return Lesson(
      id:
          json['Uid']?.toString() ?? '',
      status:
          statusJson.isNotEmpty
              ? Category.fromJson(
                  statusJson,
                )
              : null,
      date:
          _date(json['Datum']),
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
      lessonIndex:
          json['Oraszam']
                  ?.toString() ??
              '+',
      lessonYearIndex:
          _nullableInt(
        json['OraEvesSorszama'],
      ),
      substituteTeacher:
          substituteName.isNotEmpty
              ? Teacher.fromString(
                  substituteName,
                )
              : null,
      teacher:
          Teacher.fromString(
        (
          json['TanarNeve'] ??
          ''
        ).toString().trim(),
      ),
      homeworkEnabled:
          json['IsTanuloHaziFeladatEnabled'] ==
              true,
      start:
          _date(
        json['KezdetIdopont'],
      ),
      studentPresence:
          presenceJson.isEmpty ||
              !(presenceJson['Nev']
                          ?.toString()
                          .toLowerCase() ??
                      '')
                  .contains('hiany'),
      end:
          _date(
        json['VegIdopont'],
      ),
      homeworkId:
          json['HaziFeladatUid']
                  ?.toString() ??
              '',
      exam:
          json['BejelentettSzamonkeresUid']
                  ?.toString() ??
              '',
      type:
          typeJson.isNotEmpty
              ? Category.fromJson(
                  typeJson,
                )
              : null,
      description:
          (json['Tema'] ?? '')
              .toString(),
      room: roomRaw
          .split('_')
          .join(' ')
          .replaceAll(
            RegExp(
              r' ?terem ?',
              caseSensitive: false,
            ),
            '',
          ),
      groupName:
          groupJson['Nev']
                  ?.toString() ??
              '',
      name:
          json['Nev']?.toString() ??
              '',
      online:
          json['IsDigitalisOra'] ==
              true,
      isEmpty:
          json['isEmpty'] == true,
      json: json,
      isSeen:
          json['isSeen'] == true,
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

  int? getFloor() {
    final match =
        RegExp(r'(\d{3})')
            .firstMatch(room);

    if (match != null) {
      final floorNumber =
          int.tryParse(
        match[0] ?? '',
      );

      if (floorNumber != null) {
        return (floorNumber / 100)
            .floor();
      }
    }

    return null;
  }

  bool get isChanged =>
      status?.name == 'Elmaradt' ||
      substituteTeacher != null;

  bool get swapDesc =>
      room.length > 8;
}