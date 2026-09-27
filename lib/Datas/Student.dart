import 'User.dart';
import 'Absence.dart';

class Student {
  String Name;
  String Email;
  String Institute;
  String InstituteCode;

  String Class;
  String ClassName;

  String SchoolYear;
  String SchoolYearId;

  User owner;

  List<Evaluation> Evaluations = [];
  List<Absence> Absences = [];
  List<SubjectAveragesBean> SubjectAverages = [];

  Student();

  static Student fromJson(
    Map<String, dynamic> json, [
    User owner,
  ]) {
    if (json == null) {
      return null;
    }

    final Student student = Student();

    student.owner = owner;

    student.Name = _stringValue(
      json["Name"],
      _stringValue(
        json["Nev"],
      ),
    );

    student.Email = _stringValue(
      json["Email"],
      _stringValue(
        json["EmailCim"],
      ),
    );

    student.Institute = _stringValue(
      json["Institute"],
      _stringValue(
        json["IntezmenyNev"],
      ),
    );

    student.InstituteCode = _stringValue(
      json["InstituteCode"],
      _stringValue(
        json["IntezmenyAzonosito"],
      ),
    );

    student.Class = _stringValue(
      json["Class"],
      _stringValue(
        json["Osztaly"],
      ),
    );

    student.ClassName = _stringValue(
      json["ClassName"],
      _stringValue(
        json["OsztalyNev"],
      ),
    );

    student.SchoolYear = _stringValue(
      json["SchoolYear"],
      _stringValue(
        json["TanevNev"],
      ),
    );

    student.SchoolYearId = _stringValue(
      json["SchoolYearId"],
      _stringValue(
        json["TanevUid"],
      ),
    );

    final dynamic evaluations =
        json["Evaluations"] ?? json["Ertekelesek"];

    if (evaluations is List) {
      student.Evaluations = evaluations
          .whereType<Map>()
          .map(
            (item) => Evaluation.fromMap(
              Map<String, dynamic>.from(item),
              owner,
            ),
          )
          .toList();
    }

    final dynamic absences =
        json["Absences"] ?? json["Mulasztasok"];

    if (absences is List) {
      student.Absences = absences
          .whereType<Map>()
          .map(
            (item) => Absence.fromMap(
              Map<String, dynamic>.from(item),
              owner,
            ),
          )
          .toList();
    }

    final dynamic averages =
        json["SubjectAverages"] ?? json["Atlagok"];

    if (averages is List) {
      student.SubjectAverages = averages
          .whereType<Map>()
          .map(
            (item) => SubjectAveragesBean.fromMap(
              Map<String, dynamic>.from(item),
              owner,
            ),
          )
          .toList();
    }

    return student;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "Name": Name,
      "Email": Email,
      "Institute": Institute,
      "InstituteCode": InstituteCode,
      "Class": Class,
      "ClassName": ClassName,
      "SchoolYear": SchoolYear,
      "SchoolYearId": SchoolYearId,
      "Evaluations": Evaluations
          .map(
            (e) => e.toJson(),
          )
          .toList(),
      "Absences": Absences
          .map(
            (e) => e.toJson(),
          )
          .toList(),
      "SubjectAverages": SubjectAverages
          .map(
            (e) => e.toJson(),
          )
          .toList(),
    };
  }
}

class Evaluation {
  dynamic EvaluationId;

  String Subject;
  String SubjectCategory;
  String SubjectCategoryName;

  String Theme;

  double NumberValue;
  String TextValue;

  String Mode;
  String ModeName;

  double Weight;

  String Teacher;
  DateTime Date;
  DateTime CreatingTime;

  User owner;

  Evaluation();

  static Evaluation fromMap(
    Map<String, dynamic> map, [
    User owner,
  ]) {
    if (map == null) {
      return null;
    }

    final Evaluation evaluation = Evaluation();

    evaluation.owner = owner;

    evaluation.EvaluationId =
        map["EvaluationId"] ??
        map["Uid"] ??
        map["Id"];

    evaluation.Subject = _stringValue(
      map["Subject"],
      _subjectName(
        map["Tantargy"],
        map["TantargyNeve"],
      ),
    );

    evaluation.SubjectCategory = _stringValue(
      map["SubjectCategory"],
      _subjectCategory(
        map["Tantargy"],
      ),
    );

    evaluation.SubjectCategoryName = _stringValue(
      map["SubjectCategoryName"],
      _subjectCategoryName(
        map["Tantargy"],
      ),
    );

    evaluation.Theme = _stringValue(
      map["Theme"],
      _stringValue(
        map["Tema"],
      ),
    );

    evaluation.NumberValue = _doubleValue(
      map["NumberValue"],
      map["SzamErtek"],
    );

    evaluation.TextValue = _stringValue(
      map["TextValue"],
      _stringValue(
        map["SzovegesErtek"],
      ),
    );

    evaluation.Mode = _stringValue(
      map["Mode"],
      _stringValue(
        map["Tipus"],
        _stringValue(
          map["Jelleg"],
        ),
      ),
    );

    evaluation.ModeName = _stringValue(
      map["ModeName"],
      _nestedName(
        map["Tipus"],
      ),
    );

    evaluation.Weight = _doubleValue(
      map["Weight"],
      map["SulySzazalekErteke"],
    );

    evaluation.Teacher = _stringValue(
      map["Teacher"],
      _stringValue(
        map["ErtekeloTanarNeve"],
      ),
    );

    evaluation.Date = _dateTimeValue(
      map["Date"],
      _dateTimeValue(
        map["RogzitesDatuma"],
      ),
    );

    evaluation.CreatingTime = _dateTimeValue(
      map["CreatingTime"],
      _dateTimeValue(
        map["KeszitesDatuma"],
      ),
    );

    return evaluation;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "EvaluationId": EvaluationId,
      "Subject": Subject,
      "SubjectCategory": SubjectCategory,
      "SubjectCategoryName": SubjectCategoryName,
      "Theme": Theme,
      "NumberValue": NumberValue,
      "TextValue": TextValue,
      "Mode": Mode,
      "ModeName": ModeName,
      "Weight": Weight,
      "Teacher": Teacher,
      "Date": Date?.toIso8601String(),
      "CreatingTime": CreatingTime?.toIso8601String(),
    };
  }
}

class SubjectAveragesBean {
  String Subject;
  String SubjectCategory;
  String SubjectCategoryName;

  double Value;
  double ClassValue;
  double Difference;

  User owner;

  SubjectAveragesBean();

  static SubjectAveragesBean fromMap(
    Map<String, dynamic> map, [
    User owner,
  ]) {
    if (map == null) {
      return null;
    }

    final SubjectAveragesBean average = SubjectAveragesBean();

    average.owner = owner;

    average.Subject = _stringValue(
      map["Subject"],
      _subjectName(
        map["Tantargy"],
        map["TantargyNeve"],
      ),
    );

    average.SubjectCategory = _stringValue(
      map["SubjectCategory"],
      _subjectCategory(
        map["Tantargy"],
      ),
    );

    average.SubjectCategoryName = _stringValue(
      map["SubjectCategoryName"],
      _subjectCategoryName(
        map["Tantargy"],
      ),
    );

    average.Value = _doubleValue(
      map["Value"],
      map["Atlag"],
    );

    average.ClassValue = _doubleValue(
      map["ClassValue"],
      map["OsztalyAtlag"],
    );

    average.Difference = _doubleValue(
      map["Difference"],
      map["Kulonbseg"],
    );

    return average;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "Subject": Subject,
      "SubjectCategory": SubjectCategory,
      "SubjectCategoryName": SubjectCategoryName,
      "Value": Value,
      "ClassValue": ClassValue,
      "Difference": Difference,
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

double _doubleValue(
  dynamic first, [
  dynamic second,
]) {
  dynamic value = first ?? second;

  if (value == null) {
    return 0.0;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
        value.toString().replaceAll(",", "."),
      ) ??
      0.0;
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

String _nestedName(dynamic value) {
  if (value is Map) {
    return _stringValue(
      value["Nev"],
      _stringValue(
        value["Name"],
      ),
    );
  }

  return _stringValue(value);
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

String _subjectCategory(
  dynamic subject,
) {
  if (subject is Map) {
    final dynamic category = subject["Kategoria"];

    if (category is Map) {
      return _stringValue(
        category["Uid"],
        _stringValue(
          category["Name"],
        ),
      );
    }
  }

  return "";
}

String _subjectCategoryName(
  dynamic subject,
) {
  if (subject is Map) {
    final dynamic category = subject["Kategoria"];

    if (category is Map) {
      return _stringValue(
        category["Nev"],
        _stringValue(
          category["Name"],
        ),
      );
    }
  }

  return "";
}