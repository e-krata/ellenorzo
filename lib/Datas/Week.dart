import 'package:flutter/material.dart';
import '../Datas/Lesson.dart';
import 'package:e_szivacs/generated/i18n.dart';

class Week {
  List<Lesson> monday;
  List<Lesson> tuesday;
  List<Lesson> wednesday;
  List<Lesson> thursday;
  List<Lesson> friday;
  List<Lesson> saturday;
  List<Lesson> sunday;

  DateTime startDay;

  Week(
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
    this.startDay,
  );

  List<List<Lesson>> dayList() {
    final List<List<Lesson>> days = <List<Lesson>>[];

    if (monday != null && monday.isNotEmpty) {
      days.add(monday);
    }

    if (tuesday != null && tuesday.isNotEmpty) {
      days.add(tuesday);
    }

    if (wednesday != null && wednesday.isNotEmpty) {
      days.add(wednesday);
    }

    if (thursday != null && thursday.isNotEmpty) {
      days.add(thursday);
    }

    if (friday != null && friday.isNotEmpty) {
      days.add(friday);
    }

    if (saturday != null && saturday.isNotEmpty) {
      days.add(saturday);
    }

    if (sunday != null && sunday.isNotEmpty) {
      days.add(sunday);
    }

    return days;
  }

  List<String> dayStrings(BuildContext context) {
    final List<String> days = <String>[];

    if (monday != null && monday.isNotEmpty) {
      days.add(
        S.of(context).short_monday,
      );
    }

    if (tuesday != null && tuesday.isNotEmpty) {
      days.add(
        S.of(context).short_tuesday,
      );
    }

    if (wednesday != null && wednesday.isNotEmpty) {
      days.add(
        S.of(context).short_wednesday,
      );
    }

    if (thursday != null && thursday.isNotEmpty) {
      days.add(
        S.of(context).short_thursday,
      );
    }

    if (friday != null && friday.isNotEmpty) {
      days.add(
        S.of(context).short_friday,
      );
    }

    if (saturday != null && saturday.isNotEmpty) {
      days.add(
        S.of(context).short_saturday,
      );
    }

    if (sunday != null && sunday.isNotEmpty) {
      days.add(
        S.of(context).short_sunday,
      );
    }

    return days;
  }
}