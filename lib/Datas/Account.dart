import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Helpers/AbsentHelper.dart';
import '../Helpers/AverageHelper.dart';
import '../Helpers/DBHelper.dart';
import '../Helpers/MessageHelper.dart';
import '../Helpers/NotesHelper.dart';
import '../Helpers/RequestHelper.dart';
import '../Helpers/TestHelper.dart';
import '../Utils/Saver.dart';
import 'Average.dart';
import 'Message.dart';
import 'Note.dart';
import 'Student.dart';
import 'Test.dart';
import 'User.dart';

class Account {
  Student student;
  User user;

  String _eventsString;
  String testString;

  Map _studentJson;
  Map<String, List<Absence>> absents;

  List<Test> tests;
  List testJson;
  List<Note> notes;
  List<Average> averages;
  List<Message> messages;

  Account(User user) {
    this.user = user;
  }

  String getStudentString() => json.encode(_studentJson);

  Map getStudentJson() => _studentJson;

  Future<void> refreshStudentString(
    bool isOffline,
    bool showErrors,
  ) async {
    if (!user.getRecentlyRefreshed("refreshStudentString")) {
      if (isOffline && _studentJson == null) {
        try {
          _studentJson = await DBHelper().getStudentJson(user);
        } catch (e) {
          Fluttertoast.showToast(
            msg: "Hiba a felhasználó olvasása közben",
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }

        messages = await MessageHelper().getMessagesOffline(user);
      } else if (!isOffline) {
        final String studentString =
            await RequestHelper().getStudentString(
          user,
          showErrors,
        );

        if (studentString != null) {
          _studentJson = json.decode(studentString);

          await DBHelper().addStudentJson(
            _studentJson,
            user,
          );
        }

        messages = await MessageHelper().getMessages(
          user,
          showErrors,
        );
      }

      if (_studentJson != null) {
        student = Student.fromMap(
          _studentJson,
          user,
        );

        absents = await AbsentHelper().getAbsentsFrom(
          student.Absences,
        );

        await _refreshEventsString(
          isOffline,
          showErrors,
        );

        notes = await NotesHelper().getNotesFrom(
          _eventsString,
          json.encode(_studentJson),
          user,
        );

        averages = await AverageHelper().getAveragesFrom(
          json.encode(_studentJson),
          user,
        );
      }

      user.setRecentlyRefreshed(
        "refreshStudentString",
      );
    }
  }

  Future<void> refreshTests(
    bool isOffline,
    bool showErrors,
  ) async {
    if (!user.getRecentlyRefreshed("refreshTests")) {
      if (isOffline) {
        testJson = await DBHelper().getTestsJson(user);

        if (testJson != null) {
          tests = await TestHelper().getTestsFrom(
            testJson,
            user,
          );
        }
      } else {
        final String token =
            await RequestHelper().getBearerToken(
          user,
          showErrors,
        );

        if (token != null) {
          testString = await RequestHelper().getTests(
            token,
            user.schoolCode,
          );

          if (testString != null) {
            testJson = json.decode(testString);

            tests = await TestHelper().getTestsFrom(
              testJson,
              user,
            );

            await DBHelper().addTestsJson(
              testJson,
              user,
            );
          }
        }
      }

      user.setRecentlyRefreshed(
        "refreshTests",
      );
    }
  }

  Future<void> _refreshEventsString(
    bool isOffline,
    bool showErrors,
  ) async {
    if (!user.getRecentlyRefreshed("_refreshEventsString")) {
      if (isOffline) {
        _eventsString = await readEventsString(
          user,
        );
      } else {
        _eventsString = await RequestHelper().getEventsString(
          user,
          showErrors,
        );
      }

      user.setRecentlyRefreshed(
        "_refreshEventsString",
      );
    }
  }

  List<Evaluation> get midyearEvaluations =>
      student?.Evaluations
          ?.where(
            (Evaluation evaluation) => evaluation.isMidYear(),
          )
          ?.toList() ??
      <Evaluation>[];
}