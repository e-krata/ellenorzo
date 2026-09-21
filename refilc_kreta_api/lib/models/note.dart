import 'category.dart';
import 'teacher.dart';

class Note {
  Map? json;
  String id;
  String title;
  DateTime date;
  DateTime submitDate;
  Teacher teacher;
  DateTime seenDate;
  String groupId;
  String content;
  Category? type;

  Note({
    required this.id,
    required this.title,
    required this.date,
    required this.submitDate,
    required this.teacher,
    required this.seenDate,
    required this.groupId,
    required this.content,
    this.type,
    this.json,
  });

  factory Note.fromJson(
    Map json,
  ) {
    final group =
        json['OsztalyCsoport'];

    final type =
        json['Tipus'];

    return Note(
      id:
          json['Uid']?.toString() ?? '',
      title:
          (json['Cim'] ?? '')
              .toString(),
      date:
          _date(
        json['Datum'],
      ),
      submitDate:
          _date(
        json['KeszitesDatuma'],
      ),
      teacher:
          Teacher.fromString(
        (
          json['KeszitoTanarNeve'] ??
          ''
        ).toString().trim(),
      ),
      seenDate:
          _date(
        json['LattamozasDatuma'],
      ),
      groupId:
          group is Map
              ? group['Uid']
                      ?.toString() ??
                  ''
              : '',
      content:
          (json['Tartalom'] ?? '')
              .toString()
              .replaceAll(
                '\r',
                '',
              ),
      type:
          type is Map
              ? Category.fromJson(
                  type,
                )
              : null,
      json: json,
    );
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