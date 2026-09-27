import 'User.dart';

class Absence {
  int AbsenceId;

  String Type;
  String TypeName;

  String Mode;
  String ModeName;

  String Subject;

  dynamic SubjectCategory;
  String SubjectCategoryName;

  int DelayTimeMinutes;

  String Teacher;

  DateTime LessonStartTime;

  int NumberOfLessons;

  DateTime CreatingTime;

  String JustificationState;
  String JustificationStateName;

  String JustificationType;
  String JustificationTypeName;

  dynamic SeenByTutelaryUTC;

  User owner;

  static const String PARENTAL = "Parental";

  static const String JUSTIFIED = "Justified";
  static const String BE_JUSTIFIED = "BeJustified";
  static const String UNJUSTIFIED = "UnJustified";

  bool isParental() =>
      JustificationType == PARENTAL;

  bool isJustified() =>
      JustificationState == JUSTIFIED;

  bool isBeJustified() =>
      JustificationState == BE_JUSTIFIED;

  bool isUnjustified() =>
      JustificationState == UNJUSTIFIED;

  static Absence fromMap(
    Map<String, dynamic> map,
    User owner,
  ) {
    if (map == null) {
      return null;
    }

    final Absence absence = Absence();

    // ------------------------------------------------------------
    // Régi API
    // ------------------------------------------------------------

    absence.AbsenceId = _intValue(
      map['AbsenceId'],
      _intValue(
        map['Id'],
      ),
    );

    absence.Type = _stringValue(
      map['Type'],
      _stringValue(
        map['Tipus'],
      ),
    );

    absence.TypeName = _stringValue(
      map['TypeName'],
      _stringValue(
        map['TipusNev'],
      ),
    );

    absence.Mode = _stringValue(
      map['Mode'],
      "",
    );

    absence.ModeName = _stringValue(
      map['ModeName'],
      "",
    );

    absence.Subject = _stringValue(
      map['Subject'],
      _subjectName(
        map['Tantargy'],
        map['TantargyNeve'],
      ),
    );

    absence.SubjectCategory =
        map['SubjectCategory'] ??
            _subjectCategory(
              map['Tantargy'],
            );

    absence.SubjectCategoryName =
        _stringValue(
      map['SubjectCategoryName'],
      _subjectCategoryName(
        map['Tantargy'],
      ),
    );

    absence.DelayTimeMinutes =
        _intValue(
      map['DelayTimeMinutes'],
      _intValue(
        map['KesesiIdoPercben'],
      ),
    );

    absence.Teacher = _stringValue(
      map['Teacher'],
      _stringValue(
        map['TanarNeve'],
      ),
    );

    absence.LessonStartTime =
        _dateTimeValue(
      map['LessonStartTime'],
      _dateTimeValue(
        map['OraKezdete'],
        _dateTimeValue(
          map['Datum'],
        ),
      ),
    );

    absence.NumberOfLessons =
        _intValue(
      map['NumberOfLessons'],
      _intValue(
        map['OrakSzama'],
        1,
      ),
    );

    absence.CreatingTime =
        _dateTimeValue(
      map['CreatingTime'],
      _dateTimeValue(
        map['RogzitesIdopontja'],
        _dateTimeValue(
          map['KeszitesDatuma'],
        ),
      ),
    );

    absence.JustificationState =
        _stringValue(
      map['JustificationState'],
      _stringValue(
        map['IgazolasAllapota'],
      ),
    );

    absence.JustificationStateName =
        _stringValue(
      map['JustificationStateName'],
      _stringValue(
        map['IgazolasAllapotaNeve'],
      ),
    );

    absence.JustificationType =
        _stringValue(
      map['JustificationType'],
      _stringValue(
        map['IgazolasTipusa'],
      ),
    );

    absence.JustificationTypeName =
        _stringValue(
      map['JustificationTypeName'],
      _stringValue(
        map['IgazolasTipusaNeve'],
      ),
    );

    absence.SeenByTutelaryUTC =
        map['SeenByTutelaryUTC'];

    // ------------------------------------------------------------
    // Új API kompatibilitás
    // ------------------------------------------------------------

    if (absence.AbsenceId == null) {
      final dynamic uid =
          map['Uid'];

      if (uid != null) {
        absence.AbsenceId =
            _stableIntFromString(
          uid.toString(),
        );
      } else {
        absence.AbsenceId = 0;
      }
    }

    if (absence.Subject == null) {
      absence.Subject = "";
    }

    if (absence.SubjectCategoryName ==
        null) {
      absence.SubjectCategoryName = "";
    }

    if (absence.Teacher == null) {
      absence.Teacher = "";
    }

    if (absence.Type == null) {
      absence.Type = "";
    }

    if (absence.TypeName == null) {
      absence.TypeName = "";
    }

    if (absence.Mode == null) {
      absence.Mode = "";
    }

    if (absence.ModeName == null) {
      absence.ModeName = "";
    }

    if (absence.JustificationState ==
        null) {
      absence.JustificationState = "";
    }

    if (absence.JustificationStateName ==
        null) {
      absence.JustificationStateName = "";
    }

    if (absence.JustificationType ==
        null) {
      absence.JustificationType = "";
    }

    if (absence.JustificationTypeName ==
        null) {
      absence.JustificationTypeName = "";
    }

    if (absence.DelayTimeMinutes ==
        null) {
      absence.DelayTimeMinutes = 0;
    }

    if (absence.NumberOfLessons ==
        null) {
      absence.NumberOfLessons = 1;
    }

    // ------------------------------------------------------------
    // Owner
    // ------------------------------------------------------------

    if (map.containsKey("owner") &&
        map["owner"] is Map) {
      absence.owner =
          User.fromJson(
        Map<String, dynamic>.from(
          map["owner"],
        ),
      );
    } else {
      absence.owner = owner;
    }

    return absence;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "AbsenceId": AbsenceId,
      "Type": Type,
      "TypeName": TypeName,
      "Mode": Mode,
      "ModeName": ModeName,
      "Subject": Subject,
      "SubjectCategory": SubjectCategory,
      "SubjectCategoryName":
          SubjectCategoryName,
      "DelayTimeMinutes":
          DelayTimeMinutes,
      "Teacher": Teacher,
      "LessonStartTime":
          LessonStartTime?.toIso8601String(),
      "NumberOfLessons":
          NumberOfLessons,
      "CreatingTime":
          CreatingTime?.toIso8601String(),
      "JustificationState":
          JustificationState,
      "JustificationStateName":
          JustificationStateName,
      "JustificationType":
          JustificationType,
      "JustificationTypeName":
          JustificationTypeName,
      "SeenByTutelaryUTC":
          SeenByTutelaryUTC,
      "owner": owner?.toMap(),
    };
  }

  static String _stringValue(
    dynamic value, [
    String defaultValue = "",
  ]) {
    if (value == null) {
      return defaultValue;
    }

    return value.toString();
  }

  static int _intValue(
    dynamic value, [
    int defaultValue = 0,
  ]) {
    if (value == null) {
      return defaultValue;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        defaultValue;
  }

  static DateTime _dateTimeValue(
    dynamic value, [
    DateTime defaultValue,
  ]) {
    if (value == null) {
      return defaultValue;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        value,
      );
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  static String _subjectName(
    dynamic subject,
    dynamic subjectName,
  ) {
    if (subjectName != null) {
      return subjectName.toString();
    }

    if (subject == null) {
      return "";
    }

    if (subject is Map) {
      return _stringValue(
        subject["Nev"],
        _stringValue(
          subject["Name"],
        ),
      );
    }

    return subject.toString();
  }

  static dynamic _subjectCategory(
    dynamic subject,
  ) {
    if (subject is Map) {
      return subject["Kategoria"];
    }

    return null;
  }

  static String _subjectCategoryName(
    dynamic subject,
  ) {
    if (subject is Map) {
      final dynamic category =
          subject["Kategoria"];

      if (category is Map) {
        return _stringValue(
          category["Nev"],
          _stringValue(
            category["Name"],
          ),
        );
      }

      if (category != null) {
        return category.toString();
      }
    }

    return "";
  }

  static int _stableIntFromString(
    String value,
  ) {
    int hash = 0;

    for (int i = 0; i < value.length; i++) {
      hash = ((hash * 31) +
              value.codeUnitAt(i)) &
          0x7fffffff;
    }

    return hash;
  }
}