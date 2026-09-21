import 'package:refilc_kreta_api/client/api.dart';

import 'subject.dart';
import 'teacher.dart';
import 'category.dart';

class Homework {
  Map? json;
  DateTime date;
  DateTime lessonDate;
  DateTime deadline;
  bool byTeacher;
  bool homeworkEnabled;
  Teacher teacher;
  String content;
  GradeSubject subject;
  String group;
  List<HomeworkAttachment> attachments;
  String id;

  Homework({
    required this.date,
    required this.lessonDate,
    required this.deadline,
    required this.byTeacher,
    required this.homeworkEnabled,
    required this.teacher,
    required this.content,
    required this.subject,
    required this.group,
    required this.attachments,
    required this.id,
    this.json,
  });

  factory Homework.fromJson(
    Map json,
  ) {
    final subjectJson =
        _map(json['Tantargy']);

    final groupJson =
        _map(json['OsztalyCsoport']);

    final attachmentValues =
        json['Csatolmanyok'];

    final attachments =
        <HomeworkAttachment>[];

    if (attachmentValues is List) {
      for (final value
          in attachmentValues) {
        if (value is Map) {
          attachments.add(
            HomeworkAttachment.fromJson(
              value,
            ),
          );
        }
      }
    }

    return Homework(
      id:
          json['Uid']?.toString() ?? '',
      date:
          _date(
        json['RogzitesIdopontja'] ??
            json['RogzitesDatuma'],
      ),
      lessonDate:
          _date(
        json['FeladasDatuma'] ??
            json['Datum'],
      ),
      deadline:
          _date(
        json['HataridoDatuma'] ??
            json['Hatarido'],
      ),
      byTeacher:
          json['IsTanarRogzitette'] !=
              false,
      homeworkEnabled:
          json['IsTanuloHaziFeladatEnabled'] ==
              true,
      teacher:
          Teacher.fromString(
        (
          json['RogzitoTanarNeve'] ??
          ''
        ).toString().trim(),
      ),
      content: (
        json['Szoveg'] ??
        json['FeladatSzovege'] ??
        ''
      ).toString().trim(),
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
      group: (
        groupJson['Uid'] ??
        json['OsztalyCsoportUid'] ??
        ''
      ).toString(),
      attachments:
          attachments,
      json: json,
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
}

class HomeworkAttachment {
  Map? json;
  String id;
  String name;
  String type;

  HomeworkAttachment({
    required this.id,
    this.name = '',
    this.type = '',
    this.json,
  });

  factory HomeworkAttachment.fromJson(
    Map json,
  ) {
    return HomeworkAttachment(
      id:
          json['Uid']?.toString() ?? '',
      name: (
        json['Nev'] ??
        json['FajlNev'] ??
        ''
      ).toString(),
      type: (
        json['Tipus'] ??
        json['MimeType'] ??
        ''
      ).toString(),
      json: json,
    );
  }

  String downloadUrl(
    String iss,
  ) =>
      KretaAPI
          .downloadHomeworkAttachments(
        iss,
        id,
        type,
      );

  bool get isImage {
    final lower =
        name.toLowerCase();

    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }
}