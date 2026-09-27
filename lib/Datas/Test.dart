class Test {
  int TestId;

  String Subject;
  String SubjectName;

  String Theme;

  DateTime Date;
  DateTime StartTime;
  DateTime EndTime;

  String Teacher;
  String Type;
  String TypeName;

  String Description;

  Test();

  static Test fromMap(
    Map<String, dynamic> map,
  ) {
    if (map == null) {
      return null;
    }

    final Test test = Test();

    test.TestId = _intValue(
      map["TestId"],
      _intValue(
        map["Id"],
      ),
    );

    test.Subject = _stringValue(
      map["Subject"],
      _subjectName(
        map["Tantargy"],
        map["TantargyNeve"],
      ),
    );

    test.SubjectName = _stringValue(
      map["SubjectName"],
      _subjectName(
        map["Tantargy"],
        map["TantargyNeve"],
      ),
    );

    test.Theme = _stringValue(
      map["Theme"],
      _stringValue(
        map["Tema"],
      ),
    );

    test.Date = _dateTimeValue(
      map["Date"],
      _dateTimeValue(
        map["Datum"],
      ),
    );

    test.StartTime = _dateTimeValue(
      map["StartTime"],
      _dateTimeValue(
        map["KezdetIdopont"],
      ),
    );

    test.EndTime = _dateTimeValue(
      map["EndTime"],
      _dateTimeValue(
        map["VegIdopont"],
      ),
    );

    test.Teacher = _stringValue(
      map["Teacher"],
      _stringValue(
        map["TanarNeve"],
      ),
    );

    test.Type = _stringValue(
      map["Type"],
      _stringValue(
        map["Tipus"],
      ),
    );

    test.TypeName = _stringValue(
      map["TypeName"],
      _stringValue(
        map["TipusNev"],
      ),
    );

    test.Description = _stringValue(
      map["Description"],
      _stringValue(
        map["Leiras"],
      ),
    );

    return test;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "TestId": TestId,
      "Subject": Subject,
      "SubjectName": SubjectName,
      "Theme": Theme,
      "Date": Date?.toIso8601String(),
      "StartTime": StartTime?.toIso8601String(),
      "EndTime": EndTime?.toIso8601String(),
      "Teacher": Teacher,
      "Type": Type,
      "TypeName": TypeName,
      "Description": Description,
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
}