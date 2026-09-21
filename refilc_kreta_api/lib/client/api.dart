import 'package:intl/intl.dart';

class KretaAPI {
  static const String baseUrl = 'https://ujkreta.onrender.com';

  // OAuth2
  static const String login = '$baseUrl/connect/token';
  static const String clientId = 'ekrata-ellenorzo-diak-mobil';

  // Compatibility only. ÚjKréta password grant does not require /nonce.
  static const String nonce = '';
  static const String logout = '';

  // Student API.
  //
  // Az `iss` paramétert direkt megtartjuk, hogy a régi providereket
  // ne kelljen átírni, viszont már nem használjuk URL-generálásra.

  static String notes(String iss) =>
      '$baseUrl/ellenorzo/v3/sajat/Feljegyzesek';

  static String events(String iss) =>
      '$baseUrl/ellenorzo/v3/sajat/FaliujsagElemek';

  static String student(String iss) =>
      '$baseUrl/ellenorzo/v3/sajat/TanuloAdatlap';

  static String grades(String iss) =>
      '$baseUrl/ellenorzo/v3/sajat/Ertekelesek';

  static String absences(String iss) =>
      '$baseUrl/ellenorzo/v3/sajat/Mulasztasok';

  static String groups(String iss) =>
      '$baseUrl/ellenorzo/v3/sajat/OsztalyCsoportok';

  static String groupAverages(
    String iss,
    String uid,
  ) =>
      '$baseUrl/ellenorzo/v3/sajat/'
      'Ertekelesek/Atlagok/OsztalyAtlagok'
      '?oktatasiNevelesiFeladatUid=${Uri.encodeQueryComponent(uid)}';

  static String averages(
    String iss,
    String uid,
  ) =>
      '$baseUrl/ellenorzo/v3/sajat/'
      'Ertekelesek/Atlagok/TantargyiAtlagok'
      '?oktatasiNevelesiFeladatUid=${Uri.encodeQueryComponent(uid)}';

  static String timetable(
    String iss, {
    DateTime? start,
    DateTime? end,
  }) {
    var url =
        '$baseUrl/ellenorzo/v3/sajat/OrarendElemek';

    if (start != null && end != null) {
      url +=
          '?datumTol=${Uri.encodeQueryComponent(start.toUtc().toIso8601String())}'
          '&datumIg=${Uri.encodeQueryComponent(end.toUtc().toIso8601String())}';
    }

    return url;
  }

  static String exams(String iss) =>
      '$baseUrl/ellenorzo/v3/sajat/'
      'BejelentettSzamonkeresek';

  static String homework(
    String iss, {
    DateTime? start,
    String? id,
  }) {
    var url =
        '$baseUrl/ellenorzo/v3/sajat/HaziFeladatok';

    if (id != null && id.isNotEmpty) {
      url += '/${Uri.encodeComponent(id)}';
    } else if (start != null) {
      url +=
          '?datumTol=${Uri.encodeQueryComponent(
        DateFormat('yyyy-MM-dd').format(start),
      )}';
    }

    return url;
  }

  static String downloadHomeworkAttachments(
    String iss,
    String uid,
    String type,
  ) =>
      '$baseUrl/ellenorzo/v3/sajat/'
      'Csatolmany/${Uri.encodeComponent(uid)}';

  static String subjects(
    String iss,
    String uid,
  ) =>
      '$baseUrl/ellenorzo/v3/sajat/'
      'Ertekelesek/Atlagok/TantargyiAtlagok'
      '?oktatasiNevelesiFeladatUid=${Uri.encodeQueryComponent(uid)}';

  static String capabilities(String iss) =>
      '$baseUrl/ellenorzo/v3/sajat/Intezmenyek';

  // ------------------------------------------------------------
  // A jelenlegi ÚjKréta diák dokumentációban ezek nincsenek.
  // Kompatibilitás miatt maradnak bent.
  // ------------------------------------------------------------

  static const String sendMessage = '';

  static String messages(String endpoint) => '';

  static String message(String id) => '';

  static const String recipientCategories = '';

  static const String availableCategories = '';

  static const String recipientTeachers = '';

  static const String recipientDirectorate = '';

  static const String uploadAttachment = '';

  static String downloadAttachment(String id) => '';

  static const String trashMessage = '';

  static const String deleteMessage = '';
}

class BaseKreta {
  static const String baseUrl =
      KretaAPI.baseUrl;

  static const String kretaIdp =
      KretaAPI.baseUrl;

  static const String kretaAdmin =
      KretaAPI.baseUrl;

  static const String kretaFiles =
      KretaAPI.baseUrl;

  static String kreta(String iss) {
    return baseUrl;
  }
}

class KretaApiEndpoints {
  static const String token =
      '/connect/token';

  static const String revoke = '';

  static const String nonce = '';

  static const String notes =
      '/ellenorzo/v3/sajat/Feljegyzesek';

  static const String events =
      '/ellenorzo/v3/sajat/FaliujsagElemek';

  static const String student =
      '/ellenorzo/v3/sajat/TanuloAdatlap';

  static const String grades =
      '/ellenorzo/v3/sajat/Ertekelesek';

  static const String absences =
      '/ellenorzo/v3/sajat/Mulasztasok';

  static const String groups =
      '/ellenorzo/v3/sajat/OsztalyCsoportok';

  static const String groupAverages =
      '/ellenorzo/v3/sajat/'
      'Ertekelesek/Atlagok/OsztalyAtlagok';

  static const String averages =
      '/ellenorzo/v3/sajat/'
      'Ertekelesek/Atlagok/TantargyiAtlagok';

  static const String timetable =
      '/ellenorzo/v3/sajat/OrarendElemek';

  static const String exams =
      '/ellenorzo/v3/sajat/'
      'BejelentettSzamonkeresek';

  static const String homework =
      '/ellenorzo/v3/sajat/HaziFeladatok';

  static const String capabilities =
      '/ellenorzo/v3/sajat/Intezmenyek';

  static const String subjects =
      '/ellenorzo/v3/sajat/'
      'Ertekelesek/Atlagok/TantargyiAtlagok';

  static String downloadHomeworkAttachments(
    String uid,
    String type,
  ) =>
      '/ellenorzo/v3/sajat/Csatolmany/$uid';
}

class KretaAdminEndpoints {
  static const String sendMessage = '';

  static String messages(String endpoint) => '';

  static String message(String id) => '';

  static const String recipientCategories = '';

  static const String availableCategories = '';

  static const String recipientTeachers = '';

  static const String recipientDirectorate = '';

  static const String uploadAttachment = '';

  static String downloadAttachment(String id) => '';

  static const String trashMessage = '';

  static const String deleteMessage = '';

  static const String editProfile = '';
}