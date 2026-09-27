import 'User.dart';

class StudentHomework {
  dynamic HomeworkId;

  String Subject;
  String SubjectName;

  String Teacher;
  String TeacherName;

  String Text;
  String Description;

  DateTime Date;
  DateTime Deadline;
  DateTime CreatingTime;

  bool IsTeacherCreated;
  bool IsSolved;
  bool IsSubmitable;
  bool IsAttachmentAllowed;

  String Group;
  String GroupName;

  User owner;

  StudentHomework();

  static StudentHomework fromMap(
    Map<String, dynamic> map, [
    User owner,
  ]) {
    if (map == null) {
      return null;
    }

    final StudentHomework homework = StudentHomework();

    homework.owner = owner;

    homework.HomeworkId =
        map["HomeworkId"] ??
        map["Uid"] ??
        map["Id"];

    homework.Subject = _stringValue(
      map["Subject"],
      _subjectName(
        map["Tantargy"],
        map["TantargyNeve"],
      ),
    );

    homework.SubjectName = _stringValue(
      map["SubjectName"],
      _subjectName(
        map["Tantargy"],
        map["TantargyNeve"],
      ),
    );

    homework.Teacher = _stringValue(
      map["Teacher"],
      _stringValue(
        map["RogzitoTanarNeve"],
      ),
    );

    homework.TeacherName = _stringValue(
      map["TeacherName"],
      _stringValue(
        map["RogzitoTanarNeve"],
      ),
    );

    homework.Text = _stringValue(
      map["Text"],
      _stringValue(
        map["Szoveg"],
      ),
    );

    homework.Description = _stringValue(
      map["Description"],
      _stringValue(
        map["Leiras"],
        homework.Text,
      ),
    );

    homework.Date = _dateTimeValue(
      map["Date"],
      _dateTimeValue(
        map["FeladasDatuma"],
        _dateTimeValue(
          map["RogzitesIdopontja"],
        ),
      ),
    );

    homework.Deadline = _dateTimeValue(
      map["Deadline"],
      _dateTimeValue(
        map["HataridoDatuma"],
      ),
    );

    homework.CreatingTime = _dateTimeValue(
      map["CreatingTime"],
      _dateTimeValue(
        map["RogzitesIdopontja"],
      ),
    );

    homework.IsTeacherCreated = _boolValue(
      map["IsTeacherCreated"],
      _boolValue(
        map["IsTanarRogzitette"],
      ),
    );

    homework.IsSolved = _boolValue(
      map["IsSolved"],
      _boolValue(
        map["IsMegoldva"],
      ),
    );

    homework.IsSubmitable = _boolValue(
      map["IsSubmitable"],
      _boolValue(
        map["IsBeadhato"],
      ),
    );

    homework.IsAttachmentAllowed = _boolValue(
      map["IsAttachmentAllowed"],
      _boolValue(
        map["IsCsatolasEngedelyezes"],
      ),
    );

    homework.Group = _stringValue(
      map["Group"],
      _groupName(
        map["OsztalyCsoport"],
      ),
    );

    homework.GroupName = _stringValue(
      map["GroupName"],
      _groupName(
        map["OsztalyCsoport"],
      ),
    );

    return homework;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "HomeworkId": HomeworkId,
      "Subject": Subject,
      "SubjectName": SubjectName,
      "Teacher": Teacher,
      "TeacherName": TeacherName,
      "Text": Text,
      "Description": Description,
      "Date": Date?.toIso8601String(),
      "Deadline": Deadline?.toIso8601String(),
      "CreatingTime": CreatingTime?.toIso8601String(),
      "IsTeacherCreated": IsTeacherCreated,
      "IsSolved": IsSolved,
      "IsSubmitable": IsSubmitable,
      "IsAttachmentAllowed": IsAttachmentAllowed,
      "Group": Group,
      "GroupName": GroupName,
    };
  }
}

String _stringValue(
  dynamic value, [
  String defaultValue = "",
]) {
  if (value == null) {
    return defaultValue;
  }

  return value.toString();
}

bool _boolValue(
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

  final String stringValue = value.toString().toLowerCase();

  if (stringValue == "true" ||
      stringValue == "1" ||
      stringValue == "yes") {
    return true;
  }

  if (stringValue == "false" ||
      stringValue == "0" ||
      stringValue == "no") {
    return false;
  }

  return defaultValue;
}

DateTime _dateTimeValue(
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
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  return DateTime.tryParse(
    value.toString(),
  );
}

String _subjectName(
  dynamic subject, [
  dynamic subjectName,
]) {
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

String _groupName(
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
      ),
    );
  }

  return group.toString();
}