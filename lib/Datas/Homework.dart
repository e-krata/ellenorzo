class Homework {
  int id;
  String subject;
  String subjectName;
  String teacher;
  String text;
  DateTime date;
  DateTime deadline;
  DateTime createdAt;
  bool isTeacherCreated;
  bool isSolved;
  bool isSubmittable;
  String group;
  bool attachmentEnabled;

  Homework({
    this.id,
    this.subject = "",
    this.subjectName = "",
    this.teacher = "",
    this.text = "",
    this.date,
    this.deadline,
    this.createdAt,
    this.isTeacherCreated = false,
    this.isSolved = false,
    this.isSubmittable = true,
    this.group = "",
    this.attachmentEnabled = false,
  });

  Homework.fromJson(Map json) {
    id = _intValue(
      json["HomeworkId"],
      _intValue(
        json["Id"],
      ),
    );

    subject = _stringValue(
      json["Subject"],
      _stringValue(
        json["Tantargy"],
      ),
    );

    subjectName = _stringValue(
      json["SubjectName"],
      _stringValue(
        json["TantargyNeve"],
      ),
    );

    teacher = _stringValue(
      json["Teacher"],
      _stringValue(
        json["RogzitoTanarNeve"],
      ),
    );

    text = _stringValue(
      json["Text"],
      _stringValue(
        json["Szoveg"],
      ),
    );

    date = _dateValue(
      json["Date"],
      _dateValue(
        json["FeladasDatuma"],
      ),
    );

    deadline = _dateValue(
      json["Deadline"],
      _dateValue(
        json["HataridoDatuma"],
      ),
    );

    createdAt = _dateValue(
      json["CreatedAt"],
      _dateValue(
        json["RogzitesIdopontja"],
      ),
    );

    isTeacherCreated = _boolValue(
      json["IsTeacherCreated"],
      _boolValue(
        json["IsTanarRogzitette"],
      ),
    );

    isSolved = _boolValue(
      json["IsSolved"],
      _boolValue(
        json["IsMegoldva"],
      ),
    );

    isSubmittable = _boolValue(
      json["IsSubmittable"],
      _boolValue(
        json["IsBeadhato"],
        true,
      ),
    );

    group = _groupName(
      json["ClassGroup"],
      json["OsztalyCsoport"],
    );

    attachmentEnabled = _boolValue(
      json["IsAttachmentEnabled"],
      _boolValue(
        json["IsCsatolasEngedelyezes"],
      ),
    );

    if (subject == null) {
      subject = "";
    }

    if (subjectName == null) {
      subjectName = "";
    }

    if (teacher == null) {
      teacher = "";
    }

    if (text == null) {
      text = "";
    }

    if (group == null) {
      group = "";
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "HomeworkId": id,
      "Subject": subject,
      "SubjectName": subjectName,
      "Teacher": teacher,
      "Text": text,
      "Date": date?.toIso8601String(),
      "Deadline": deadline?.toIso8601String(),
      "CreatedAt": createdAt?.toIso8601String(),
      "IsTeacherCreated": isTeacherCreated,
      "IsSolved": isSolved,
      "IsSubmittable": isSubmittable,
      "ClassGroup": group,
      "IsAttachmentEnabled": attachmentEnabled,
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

  static DateTime _dateValue(
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

  static String _groupName(
    dynamic oldGroup,
    dynamic newGroup,
  ) {
    dynamic group =
        oldGroup ?? newGroup;

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