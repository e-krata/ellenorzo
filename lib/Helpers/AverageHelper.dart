import 'dart:async';
import 'dart:convert' show json;

import '../Datas/Average.dart';
import '../Datas/User.dart';

class AverageHelper {
  Future<List<Average>> getAveragesFrom(
    String studentString,
    User user,
  ) async {
    final List<Average> averageList =
        <Average>[];

    if (studentString == null ||
        studentString.isEmpty) {
      return averageList;
    }

    final dynamic decoded =
        json.decode(studentString);

    if (decoded is! Map) {
      return averageList;
    }

    final Map<String, dynamic> studentMap =
        Map<String, dynamic>.from(decoded);

    dynamic jsonAverageList =
        studentMap["SubjectAverages"];

    // Az új API esetén az átlagok külön endpointból
    // is érkezhetnek, de ha a Student JSON már
    // tartalmazza őket, ugyanúgy feldolgozzuk.
    jsonAverageList ??=
        studentMap["subjectAverages"];

    if (jsonAverageList is! List) {
      return averageList;
    }

    for (final dynamic jsonAverage
        in jsonAverageList) {
      if (jsonAverage is Map) {
        averageList.add(
          Average.fromJson(
            Map<String, dynamic>.from(
              jsonAverage,
            ),
            user,
          ),
        );
      }
    }

    return averageList;
  }
}