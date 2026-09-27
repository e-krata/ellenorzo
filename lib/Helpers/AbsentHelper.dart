import 'dart:async';

import '../Datas/Student.dart';

class AbsentHelper {
  Future<Map<String, List<Absence>>> getAbsentsFrom(
    List<Absence> absenceList,
  ) async {
    final Map<String, List<Absence>> absents =
        <String, List<Absence>>{};

    if (absenceList == null || absenceList.isEmpty) {
      return absents;
    }

    final List<Absence> sortedAbsences =
        List<Absence>.from(absenceList);

    sortedAbsences.sort(
      (Absence a, Absence b) {
        if (a?.LessonStartTime == null &&
            b?.LessonStartTime == null) {
          return 0;
        }

        if (a?.LessonStartTime == null) {
          return 1;
        }

        if (b?.LessonStartTime == null) {
          return -1;
        }

        return b.LessonStartTime.compareTo(
          a.LessonStartTime,
        );
      },
    );

    // A régi API néha ugyanazt a hiányzást többször adta vissza.
    // Az új API esetén is érdemes megtartani ezt a védelmet.
    final Set<dynamic> ids = <dynamic>{};
    final List<Absence> uniqueById = <Absence>[];

    for (final Absence absence in sortedAbsences) {
      if (absence == null) {
        continue;
      }

      final dynamic id = absence.AbsenceId;

      if (id == null || !ids.contains(id)) {
        if (id != null) {
          ids.add(id);
        }

        uniqueById.add(absence);
      }
    }

    final Set<String> uniqueAbsence =
        <String>{};

    for (final Absence absence in uniqueById) {
      if (absence.LessonStartTime == null) {
        continue;
      }

      final String ownerId =
          absence.owner?.id?.toString() ?? "";

      uniqueAbsence.add(
        absence.LessonStartTime.toIso8601String() +
            ownerId,
      );
    }

    for (final String key in uniqueAbsence) {
      final List<Absence> theseAbsences =
          <Absence>[];

      for (final Absence absence in uniqueById) {
        if (absence.LessonStartTime == null) {
          continue;
        }

        final String ownerId =
            absence.owner?.id?.toString() ?? "";

        final String absenceKey =
            absence.LessonStartTime.toIso8601String() +
                ownerId;

        if (absenceKey == key) {
          theseAbsences.add(absence);
        }
      }

      absents[key] = theseAbsences;
    }

    return absents;
  }
}