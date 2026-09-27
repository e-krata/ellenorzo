class Lesson {
  int id;
  int count;
  DateTime date;
  DateTime start;
  DateTime end;
  String subject;
  String subjectName;
  String room;
  String group;
  String teacher;
  String depTeacher;
  String state;
  String stateName;
  String presence;
  String presenceName;
  String theme;
  int homework;
  String calendarOraType;
  bool homeworkEnabled;

  static const String MISSED = "Missed";

  Lesson(
      this.id,
      this.count,
      this.date,
      this.start,
      this.end,
      this.subject,
      this.subjectName,
      this.room,
      this.group,
      this.teacher,
      this.depTeacher,
      this.state,
      this.stateName,
      this.presence,
      this.presenceName,
      this.theme,
      this.homework,
      this.calendarOraType,
      this.homeworkEnabled);

  bool get isMissed => state == MISSED;

  bool get isSubstitution => depTeacher != "";

  Lesson.fromJson(Map json) {
    // Régi API
    id = _intValue(
      json["LessonId"],
      _intValue(json["Id"]),
    );

    count = _intValue(
      json["Count"],
      0,
    );

    date = _dateTimeValue(
      json["Date"],
      json["Datum"],
    );

    start = _dateTimeValue(
      json["StartTime"],
      json["KezdetIdopont"],
    );

    end = _dateTimeValue(
      json["EndTime"],
      json["VegIdopont"],
    );

    subject = _stringValue(
      json["Subject"],
      _subjectName(json["Tantargy"]),
    );

    subjectName = _stringValue(
      json["SubjectCategoryName"],
      _subjectCategoryName(json["Tantargy"]),
    );

    room = _stringValue(
      json["ClassRoom"],
      json["TeremNeve"],
    );

    group = _stringValue(
      json["ClassGroup"],
      _classGroupName(json["OsztalyCsoport"]),
    );

    teacher = _stringValue(
      json["Teacher"],
      json["TanarNeve"],
    );

    depTeacher = _stringValue(
      json["DeputyTeacher"],
      "",
    );

    state = _stringValue(
      json["State"],
      "",
    );

    stateName = _stringValue(
      json["StateName"],
      "",
    );

    presence = _stringValue(
      json["PresenceType"],
      "",
    );

    presenceName = _stringValue(
      json["PresenceTypeName"],
      "",
    );

    theme = _stringValue(
      json["Theme"],
      "",
    );

    homework = _intValue(
      json["TeacherHomeworkId"],
      0,
    );

    calendarOraType = _stringValue(
      json["CalendarOraType"],
      "",
    );

    homeworkEnabled = _boolValue(
      json["IsTanuloHaziFeladatEnabled"],
      true,
    );

    // Az új API nem ad minden régi mezőhöz külön értéket.
    // Ezeknél a régi modell kompatibilitása érdekében üres/default
    // értéket használunk.

    if (date == null) {
      date = DateTime.now();
    }

    if (start == null) {
      start = date;
    }

    if (end == null) {
      end = start;
    }

    if (subject == null) {
      subject = "";
    }

    if (subjectName == null) {
      subjectName = "";
    }

    if (room == null) {
      room = "";
    }

    if (group == null) {
      group = "";
    }

    if (teacher == null) {
      teacher = "";
    }

    if (depTeacher == null) {
      depTeacher = "";
    }

    if (state == null) {
      state = "";
    }

    if (stateName == null) {
      stateName = "";
    }

    if (presence == null) {
      presence = "";
    }

    if (presenceName == null) {
      presenceName = "";
    }

    if (theme == null) {
      theme = "";
    }

    if (calendarOraType == null) {
      calendarOraType = "";
    }

    if (homeworkEnabled == null) {
      homeworkEnabled = true;
    }
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

  static bool _boolValue(
    dynamic value, [
    bool defaultValue = false,
  ]) {
    if (value == null) {
      return defaultValue;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final String text =
        value.toString().toLowerCase().trim();

    if (text == "true" ||
        text == "1" ||
        text == "yes" ||
        text == "igen") {
      return true;
    }

    if (text == "false" ||
        text == "0" ||
        text == "no" ||
        text == "nem") {
      return false;
    }

    return defaultValue;
  }

  static DateTime _dateTimeValue(
    dynamic value, [
    dynamic fallback,
  ]) {
    dynamic source = value;

    if (source == null) {
      source = fallback;
    }

    if (source == null) {
      return null;
    }

    if (source is DateTime) {
      return source;
    }

    if (source is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        source,
      );
    }

    final DateTime parsed =
        DateTime.tryParse(
      source.toString(),
    );

    return parsed;
  }

  static String _subjectName(
    dynamic subject,
  ) {
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

  static String _classGroupName(
    dynamic group,
  ) {
    if (group == null) {
      return "";
    }

    if (group is Map) {
      return _stringValue(
        group["Nev"],
        _stringValue(
          group["Name"],
          _stringValue(
            group["Uid"],
          ),
        ),
      );
    }

    return group.toString();
  }
}