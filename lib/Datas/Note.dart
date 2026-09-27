import 'User.dart';

class Note {
  int id;
  String type;
  String title;
  String content;
  String teacher;
  DateTime date;
  String creationDate;
  bool isEvent = false;
  User owner;

  Note(
    this.id,
    this.type,
    this.title,
    this.content,
    this.teacher,
    this.date,
    this.creationDate,
  );

  Note.fromJson(Map json) {
    if (json == null) {
      return;
    }

    if (json["EventId"] != null) {
      id = _intValue(json["EventId"]);
      isEvent = true;
    } else {
      id = _intValue(
        json["NoteId"] ??
            json["id"] ??
            json["Id"] ??
            json["Uid"],
      );
    }

    date = _dateValue(
      json["Date"] ??
          json["date"] ??
          json["Datum"],
    );

    content = _stringValue(
      json["Content"] ??
          json["content"] ??
          json["Leiras"] ??
          json["Szoveg"],
    );

    title = _stringValue(
      json["Title"] ??
          json["title"] ??
          json["Nev"] ??
          json["Name"],
    );

    teacher = _stringValue(
      json["Teacher"] ??
          json["teacher"] ??
          json["Tanar"] ??
          json["TanarNeve"] ??
          json["RogzitoTanarNeve"],
    );

    type = _stringValue(
      json["Type"] ??
          json["type"] ??
          json["Tipus"] ??
          json["Jelleg"],
    );

    creationDate = _stringValue(
      json["CreationDate"] ??
          json["creationDate"] ??
          json["KeszitesDatuma"] ??
          json["RogzitesIdopontja"],
    );
  }

  static int _intValue(dynamic value) {
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

  static String _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }

    return value.toString();
  }

  static DateTime _dateValue(dynamic value) {
    if (value == null) {
      return null;
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
}