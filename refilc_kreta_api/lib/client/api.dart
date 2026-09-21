import 'package:intl/intl.dart';

class KretaAPI {
  // ============================================================
  // ÚjKréta
  // ============================================================

  static const String baseUrl = "https://ujkreta.onrender.com";

  // ============================================================
  // Authentication
  // ============================================================

  static const String login = "$baseUrl/connect/token";

  static const String clientId =
      "krata-ellenorzo-diak-mobil";

  // Az ÚjKréta dokumentációban jelenleg nincs szükség
  // /nonce hívásra password grant esetén.
  //
  // Meghagyjuk null-ként, hogy a régi kódot ne törje össze,
  // de login közben nem használjuk.
  static const String nonce = "";

  // ============================================================
  // Student API
  // ============================================================

  static const String notes =
      "$baseUrl/ellenorzo/v3/sajat/Feljegyzesek";

  static const String events =
      "$baseUrl/ellenorzo/v3/sajat/FaliujsagElemek";

  static const String student =
      "$baseUrl/ellenorzo/v3/sajat/TanuloAdatlap";

  static const String grades =
      "$baseUrl/ellenorzo/v3/sajat/Ertekelesek";

  static const String absences =
      "$baseUrl/ellenorzo/v3/sajat/Mulasztasok";

  static const String groups =
      "$baseUrl/ellenorzo/v3/sajat/OsztalyCsoportok";

  static const String groupAverages =
      "$baseUrl/ellenorzo/v3/sajat/Ertekelesek/Atlagok/OsztalyAtlagok";

  static const String averages =
      "$baseUrl/ellenorzo/v3/sajat/Ertekelesek/Atlagok/TantargyiAtlagok";

  static String timetable({
    DateTime? start,
    DateTime? end,
  }) {
    String url =
        "$baseUrl/ellenorzo/v3/sajat/OrarendElemek";

    if (start != null && end != null) {
      url +=
          "?datumTol=${Uri.encodeQueryComponent(start.toUtc().toIso8601String())}"
          "&datumIg=${Uri.encodeQueryComponent(end.toUtc().toIso8601String())}";
    }

    return url;
  }

  static const String exams =
      "$baseUrl/ellenorzo/v3/sajat/BejelentettSzamonkeresek";

  static String homework({
    DateTime? start,
    String? id,
  }) {
    String url =
        "$baseUrl/ellenorzo/v3/sajat/HaziFeladatok";

    if (id != null) {
      url += "/$id";
    } else if (start != null) {
      url +=
          "?datumTol=${Uri.encodeQueryComponent(DateFormat('yyyy-MM-dd').format(start))}";
    }

    return url;
  }

  static String downloadHomeworkAttachments(
    String uid,
  ) {
    return "$baseUrl/ellenorzo/v3/sajat/Csatolmany/$uid";
  }

  static String subjects(String uid) {
    return "$baseUrl/ellenorzo/v3/sajat/"
        "Ertekelesek/Atlagok/TantargyiAtlagok"
        "?oktatasiNevelesiFeladatUid="
        "${Uri.encodeQueryComponent(uid)}";
  }

  // ============================================================
  // Régi admin/message API
  // ============================================================
  //
  // Az ÚjKréta docs jelenlegi diák API-jában ezek nincsenek.
  // Az alkalmazás fordíthatósága miatt meghagyjuk őket,
  // de az ÚjKréta szerverhez nem használjuk őket.
  //

  static const String sendMessage = "";
  static String messages(String endpoint) => "";
  static String message(String id) => "";
  static const String recipientCategories = "";
  static const String availableCategories = "";
  static const String recipientTeachers = "";
  static const String recipientDirectorate = "";
  static const String uploadAttachment = "";
  static String downloadAttachment(String id) => "";
  static const String trashMessage = "";
  static const String deleteMessage = "";
}

class BaseKreta {
  /// Az ÚjKréta szerver Base URL-je.
  static const String baseUrl =
      "https://ujkreta.onrender.com";

  /// Kompatibilitás a régi kóddal.
  static const String kretaIdp =
      "https://ujkreta.onrender.com";

  /// Kompatibilitás.
  static const String kretaAdmin =
      "https://ujkreta.onrender.com";

  /// Kompatibilitás.
  static const String kretaFiles =
      "https://ujkreta.onrender.com";

  /// Régi API-ban az ISS alapján generáltuk a KRÉTA URL-t.
  /// Az ÚjKréta esetében már nincs ilyen intézményenkénti host.
  static String kreta(String iss) {
    return baseUrl;
  }
}

class KretaApiEndpoints {
  static const String token =
      "/connect/token";

  static const String notes =
      "/ellenorzo/v3/sajat/Feljegyzesek";

  static const String events =
      "/ellenorzo/v3/sajat/FaliujsagElemek";

  static const String student =
      "/ellenorzo/v3/sajat/TanuloAdatlap";

  static const String grades =
      "/ellenorzo/v3/sajat/Ertekelesek";

  static const String absences =
      "/ellenorzo/v3/sajat/Mulasztasok";

  static const String groups =
      "/ellenorzo/v3/sajat/OsztalyCsoportok";

  static const String groupAverages =
      "/ellenorzo/v3/sajat/Ertekelesek/Atlagok/OsztalyAtlagok";

  static const String averages =
      "/ellenorzo/v3/sajat/Ertekelesek/Atlagok/TantargyiAtlagok";

  static const String timetable =
      "/ellenorzo/v3/sajat/OrarendElemek";

  static const String exams =
      "/ellenorzo/v3/sajat/BejelentettSzamonkeresek";

  static const String homework =
      "/ellenorzo/v3/sajat/HaziFeladatok";

  static const String capabilities =
      "/ellenorzo/v3/sajat/Intezmenyek";

  static String downloadHomeworkAttachments(
    String uid,
    String type,
  ) {
    return "/ellenorzo/v3/sajat/Csatolmany/$uid";
  }

  static const String subjects =
      "/ellenorzo/v3/sajat/Ertekelesek/Atlagok/TantargyiAtlagok";
}

class KretaAdminEndpoints {
  static const String sendMessage = "";
  static String messages(String endpoint) => "";
  static String message(String id) => "";
  static const String recipientCategories = "";
  static const String availableCategories = "";
  static const String recipientTeachers = "";
  static const String recipientDirectorate = "";
  static const String uploadAttachment = "";

  static String downloadAttachment(String id) => "";

  static const String trashMessage = "";
  static const String deleteMessage = "";

  static const String editProfile = "";
}
