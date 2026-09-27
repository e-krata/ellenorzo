import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../Datas/User.dart';
import '../globals.dart' as globals;

class RequestHelper {
  // ============================================================
  // API
  // ============================================================

  static const String BASE_URL = 'https://ujkreta.onrender.com';

  static const String CLIENT_ID = 'ekrata-ellenorzo-mobil';
  static const String GRANT_TYPE = 'password';

  // ============================================================
  // UI SEGÉDEK
  // ============================================================

  void showError(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void showSuccess(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // ============================================================
  // TOKEN
  // ============================================================

  Future<String?> getBearerToken(User user, bool showErrors) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/connect/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': GRANT_TYPE,
          'username': user.username,
          'password': user.password,
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is Map && decoded['access_token'] != null) {
          return decoded['access_token'].toString();
        }

        if (showErrors) {
          showError('A szerver nem adott vissza hozzáférési tokent.');
        }

        return null;
      }

      if (showErrors) {
        String message = 'Hibás felhasználónév vagy jelszó.';

        try {
          final decoded = json.decode(response.body);

          if (decoded is Map) {
            if (decoded['error_description'] != null) {
              message = decoded['error_description'].toString();
            } else if (decoded['message'] != null) {
              message = decoded['message'].toString();
            }
          }
        } catch (_) {}

        showError(message);
      }

      return null;
    } catch (e) {
      print('getBearerToken error: $e');

      if (showErrors) {
        showError('Nem sikerült kapcsolódni a szerverhez.');
      }

      return null;
    }
  }

  // Régi kompatibilitási metódus.
  Future<String?> getBearer(
    String jsonBody,
    String schoolCode,
    bool showErrors,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/connect/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: jsonBody.contains('grant_type')
            ? jsonBody
            : 'grant_type=password&$jsonBody',
      );

      if (response.statusCode == 200) {
        return response.body;
      }

      if (showErrors) {
        showError('Nem sikerült bejelentkezni.');
      }

      return null;
    } catch (e) {
      print('getBearer error: $e');

      if (showErrors) {
        showError('Nem sikerült kapcsolódni a szerverhez.');
      }

      return null;
    }
  }

  // ============================================================
  // ÁLTALÁNOS GET
  // ============================================================

  Future<String?> getStuffFromUrl(
    String path,
    String? accessToken, [
    String? schoolCode,
  ]) async {
    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL$path'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      }

      print(
        'API hiba ${response.statusCode}: '
        '${response.body}',
      );

      return null;
    } catch (e) {
      print('GET error ($path): $e');
      return null;
    }
  }

  // ============================================================
  // JSON SEGÉDEK
  // ============================================================

  dynamic _decodeJson(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      return json.decode(value);
    } catch (e) {
      print('JSON decode error: $e');
      return null;
    }
  }

  List<dynamic> _asList(dynamic value) {
    if (value == null) {
      return <dynamic>[];
    }

    if (value is List) {
      return value;
    }

    if (value is Map) {
      if (value['items'] is List) {
        return value['items'];
      }

      if (value['Items'] is List) {
        return value['Items'];
      }

      if (value['data'] is List) {
        return value['data'];
      }

      if (value['Data'] is List) {
        return value['Data'];
      }

      if (value['result'] is List) {
        return value['result'];
      }

      if (value['Result'] is List) {
        return value['Result'];
      }

      return <dynamic>[value];
    }

    return <dynamic>[];
  }

  String _stringValue(
    dynamic value, [
    String defaultValue = '',
  ]) {
    if (value == null) {
      return defaultValue;
    }

    return value.toString();
  }

  int _intValue(
    dynamic value, [
    int defaultValue = 0,
  ]) {
    if (value == null) {
      return defaultValue;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? defaultValue;
  }

  double _doubleValue(
    dynamic value, [
    double defaultValue = 0.0,
  ]) {
    if (value == null) {
      return defaultValue;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString().replaceAll(',', '.'),
        ) ??
        defaultValue;
  }

  // ============================================================
  // DIÁK ADATLAP
  // ============================================================

  Future<String?> getStudentProfile(String accessToken) async {
    return getStuffFromUrl(
      '/ellenorzo/v3/sajat/TanuloAdatlap',
      accessToken,
    );
  }

  // ============================================================
  // ÉRTÉKELÉSEK / JEGYEK
  // ============================================================

  Future<String?> getEvaluations(
    String accessToken,
    String schoolCode,
  ) async {
    return getStuffFromUrl(
      '/ellenorzo/v3/sajat/Ertekelesek',
      accessToken,
      schoolCode,
    );
  }

  // ============================================================
  // ÓRAREND
  // ============================================================

  Future<String?> getTimeTable(
    String from,
    String to,
    String accessToken,
    String schoolCode,
  ) async {
    return getStuffFromUrl(
      '/ellenorzo/v3/sajat/OrarendElemek',
      accessToken,
      schoolCode,
    );
  }

  // ============================================================
  // BEJELENTETT SZÁMONKÉRÉSEK
  // ============================================================

  Future<String?> getTests(
    String accessToken,
    String schoolCode,
  ) async {
    return getStuffFromUrl(
      '/ellenorzo/v3/sajat/BejelentettSzamonkeresek',
      accessToken,
      schoolCode,
    );
  }

  // ============================================================
  // MULASZTÁSOK
  // ============================================================

  Future<String?> getAbsences(String accessToken) async {
    return getStuffFromUrl(
      '/ellenorzo/v3/sajat/Mulasztasok',
      accessToken,
    );
  }

  // ============================================================
  // HÁZI FELADATOK
  // ============================================================

  Future<String?> getHomeworks(String accessToken) async {
    return getStuffFromUrl(
      '/ellenorzo/v3/sajat/HaziFeladatok',
      accessToken,
    );
  }

  // Régi metódusok kompatibilitás miatt.

  Future<String?> getHomework(
    String accessToken,
    String schoolCode,
    int id,
  ) async {
    return getHomeworks(accessToken);
  }

  Future<String?> getHomeworkByTeacher(
    String accessToken,
    String schoolCode,
    int id,
  ) async {
    return getHomeworks(accessToken);
  }

  // ============================================================
  // FALIÚJSÁG / ESEMÉNYEK
  // ============================================================

  Future<String?> getEvents(
    String accessToken,
    String schoolCode,
  ) async {
    return getStuffFromUrl(
      '/ellenorzo/v3/sajat/FaliujsagElemek',
      accessToken,
      schoolCode,
    );
  }

  // ============================================================
  // FELJEGYZÉSEK
  // ============================================================

  Future<String?> getNotes(String accessToken) async {
    return getStuffFromUrl(
      '/ellenorzo/v3/sajat/Feljegyzesek',
      accessToken,
    );
  }

  // ============================================================
  // OSZTÁLY / CSOPORTOK
  // ============================================================

  Future<String?> getGroups(String accessToken) async {
    return getStuffFromUrl(
      '/ellenorzo/v3/sajat/OsztalyCsoportok',
      accessToken,
    );
  }

  // ============================================================
  // OSZTÁLY ÁTLAGOK
  // ============================================================

  Future<String?> getClassAverages(String accessToken) async {
    return getStuffFromUrl(
      '/ellenorzo/v3/sajat/Ertekelesek/Atlagok/OsztalyAtlagok',
      accessToken,
    );
  }

  // ============================================================
  // ÜZENETEK
  // ============================================================

  Future<String?> getMessages(
    String accessToken,
    String schoolCode,
  ) async {
    // Az ujkreta API jelenlegi V3 dokumentációjában
    // nincs a régi üzenet API-nak megfelelő végpont.
    return null;
  }

  Future<String?> getMessageById(
    int id,
    String accessToken,
    String schoolCode,
  ) async {
    return null;
  }

  // ============================================================
  // RÉGI STUDENT JSON -> ÚJ API ADATOK
  //
  // A UI jelenlegi Student/Evaluation modellje megmarad.
  // Ez a réteg alakítja át az ujkreta API válaszát a régi
  // modell által várt JSON szerkezetre.
  // ============================================================

  Map<String, dynamic> _convertGradeToLegacyEvaluation(
    dynamic rawGrade,
    int index,
  ) {
    final Map<String, dynamic> grade =
        rawGrade is Map
            ? Map<String, dynamic>.from(rawGrade)
            : <String, dynamic>{};

    final dynamic subject = grade['Tantargy'];

    String subjectName = '';

    if (subject is Map) {
      subjectName = _stringValue(
        subject['Nev'],
        _stringValue(subject['Name']),
      );
    } else {
      subjectName = _stringValue(subject);
    }

    final dynamic category =
        subject is Map ? subject['Kategoria'] : null;

    String subjectCategory = '';
    String subjectCategoryName = '';

    if (category is Map) {
      subjectCategory = _stringValue(category['Uid']);
      subjectCategoryName = _stringValue(category['Nev']);
    }

    if (subjectCategory.isEmpty) {
      subjectCategory =
          _stringValue(grade['TantargyKategoria']);
    }

    if (subjectCategoryName.isEmpty) {
      subjectCategoryName =
          _stringValue(grade['TantargyKategoriaNeve']);
    }

    final String date =
        _stringValue(
          grade['RogzitesDatuma'],
          _stringValue(
            grade['KeszitesDatuma'],
            DateTime.now().toIso8601String(),
          ),
        );

    final String teacher =
        _stringValue(
          grade['ErtekeloTanarNeve'],
          _stringValue(grade['TanarNeve']),
        );

    final int numericValue =
        _intValue(
          grade['SzamErtek'],
          0,
        );

    final String textValue =
        _stringValue(
          grade['SzovegesErtek'],
        );

    final int weight =
        _intValue(
          grade['SulySzazalekErteke'],
          100,
        );

    final dynamic type = grade['Tipus'];

    String typeName = '';

    if (type is Map) {
      typeName = _stringValue(type['Nev']);
    } else {
      typeName = _stringValue(type);
    }

    final dynamic valueType = grade['ErtekFajta'];

    String valueTypeName = '';

    if (valueType is Map) {
      valueTypeName = _stringValue(valueType['Nev']);
    } else {
      valueTypeName = _stringValue(valueType);
    }

    String mode = typeName;

    if (mode.isEmpty) {
      mode = 'Osztályzat';
    }

    String form = valueTypeName;

    if (form.isEmpty) {
      form = 'Osztályzat';
    }

    final String jelleg =
        _stringValue(
          grade['Jelleg'],
          'Ertekeles',
        );

    final dynamic uid = grade['Uid'];

    int evaluationId = index + 1;

    if (uid != null) {
      final parsedUid = int.tryParse(uid.toString());

      if (parsedUid != null) {
        evaluationId = parsedUid;
      }
    }

    return <String, dynamic>{
      'EvaluationId': evaluationId,
      'Uid': uid,
      'Form': form,
      'FormName': form,
      'Type': mode,
      'TypeName': typeName,
      'Subject': subjectName,
      'SubjectCategory': subjectCategory,
      'SubjectCategoryName': subjectCategoryName,
      'Theme': _stringValue(
        grade['Tema'],
      ),
      'IsAtlagbaBeleszamit':
          weight > 0,
      'Mode': mode,
      'Weight': weight.toString(),
      'Value': textValue.isNotEmpty
          ? textValue
          : numericValue.toString(),
      'NumberValue': numericValue,
      'SeenByTutelaryUTC':
          grade['MegtekintesDatuma'],
      'Teacher': teacher,
      'Date': date,
      'CreatingTime':
          _stringValue(
            grade['KeszitesDatuma'],
            date,
          ),
      'Jelleg': <String, dynamic>{
        'Uid': jelleg,
        'Nev': jelleg,
        'Leiras': '',
      },
      'JellegNev': jelleg,
      'ErtekFajta': <String, dynamic>{
        'Uid': valueType is Map
            ? _stringValue(valueType['Uid'])
            : '',
        'Nev': valueTypeName,
        'Leiras': '',
      },
    };
  }

  List<Map<String, dynamic>> _convertGrades(
    dynamic grades,
  ) {
    final List<dynamic> source = _asList(grades);

    final List<Map<String, dynamic>> result =
        <Map<String, dynamic>>[];

    for (int i = 0; i < source.length; i++) {
      result.add(
        _convertGradeToLegacyEvaluation(
          source[i],
          i,
        ),
      );
    }

    return result;
  }

  Map<String, dynamic> _convertStudentProfile(
    dynamic rawProfile,
    List<Map<String, dynamic>> evaluations,
  ) {
    Map<String, dynamic> profile =
        <String, dynamic>{};

    if (rawProfile is Map) {
      profile = Map<String, dynamic>.from(
        rawProfile,
      );
    }

    final String uid =
        _stringValue(
          profile['Uid'],
          _stringValue(profile['uid']),
        );

    final String name =
        _stringValue(
          profile['Nev'],
          _stringValue(
            profile['Name'],
            _stringValue(profile['name']),
          ),
        );

    final String schoolCode =
        _stringValue(
          profile['IntezmenyAzonosito'],
          _stringValue(
            profile['InstituteCode'],
          ),
        );

    final String schoolName =
        _stringValue(
          profile['IntezmenyNev'],
          _stringValue(
            profile['InstituteName'],
          ),
        );

    final String schoolYear =
        _stringValue(
          profile['TanevUid'],
          _stringValue(
            profile['SchoolYearId'],
          ),
        );

    int studentId = _intValue(
      profile['StudentId'],
      0,
    );

    if (studentId == 0 && uid.isNotEmpty) {
      studentId = int.tryParse(uid) ?? 0;
    }

    int schoolYearId = _intValue(
      profile['SchoolYearId'],
      0,
    );

    if (schoolYearId == 0 &&
        schoolYear.isNotEmpty) {
      schoolYearId =
          int.tryParse(schoolYear) ?? 0;
    }

    profile['StudentId'] = studentId;
    profile['SchoolYearId'] = schoolYearId;

    profile['Name'] = name;
    profile['NameOfBirth'] =
        _stringValue(
          profile['NameOfBirth'],
          name,
        );

    profile['PlaceOfBirth'] =
        _stringValue(
          profile['PlaceOfBirth'],
        );

    profile['MothersName'] =
        _stringValue(
          profile['MothersName'],
        );

    profile['AddressDataList'] =
        profile['AddressDataList'] is List
            ? profile['AddressDataList']
            : <String>[];

    profile['DateOfBirthUtc'] =
        _stringValue(
          profile['DateOfBirthUtc'],
        );

    profile['InstituteName'] =
        schoolName;

    profile['InstituteCode'] =
        schoolCode;

    profile['Evaluations'] =
        evaluations;

    if (profile['SubjectAverages'] == null) {
      profile['SubjectAverages'] =
          <dynamic>[];
    }

    if (profile['Absences'] == null) {
      profile['Absences'] =
          <dynamic>[];
    }

    if (profile['Notes'] == null) {
      profile['Notes'] =
          <dynamic>[];
    }

    if (profile['Lessons'] == null) {
      profile['Lessons'] =
          <dynamic>[];
    }

    if (profile['Events'] == null) {
      profile['Events'] =
          <dynamic>[];
    }

    if (profile['Tutelaries'] == null) {
      profile['Tutelaries'] =
          <dynamic>[];
    }

    if (profile['FormTeacher'] == null) {
      profile['FormTeacher'] =
          <String, dynamic>{};
    }

    return profile;
  }

  // ============================================================
  // TELJES DIÁKADAT
  // ============================================================

  Future<String?> getStudentString(
    User user,
    bool showErrors,
  ) async {
    final String? token =
        await getBearerToken(
      user,
      showErrors,
    );

    if (token == null) {
      return null;
    }

    try {
      final Future<String?> profileFuture =
          getStudentProfile(token);

      final Future<String?> gradesFuture =
          getEvaluations(
        token,
        user.schoolCode,
      );

      final List<String?> responses =
          await Future.wait(
        <Future<String?>>[
          profileFuture,
          gradesFuture,
        ],
      );

      final String? profileResponse =
          responses[0];

      final String? gradesResponse =
          responses[1];

      final dynamic profile =
          _decodeJson(profileResponse);

      final dynamic grades =
          _decodeJson(gradesResponse);

      final List<Map<String, dynamic>>
          convertedGrades =
          _convertGrades(grades);

      final Map<String, dynamic>
          convertedProfile =
          _convertStudentProfile(
        profile,
        convertedGrades,
      );

      return json.encode(
        convertedProfile,
      );
    } catch (e) {
      print('getStudentString error: $e');

      if (showErrors) {
        showError(
          'Nem sikerült betölteni a diák adatait.',
        );
      }

      return null;
    }
  }

  // ============================================================
  // ESEMÉNYEK TELJES LEKÉRÉSE
  // ============================================================

  Future<String?> getEventsString(
    User user,
    bool showErrors,
  ) async {
    final String? token =
        await getBearerToken(
      user,
      showErrors,
    );

    if (token == null) {
      return null;
    }

    return getEvents(
      token,
      user.schoolCode,
    );
  }

  // ============================================================
  // INTÉZMÉNYEK
  // ============================================================

  Future<String> getInstitutes() async {
    // Az ujkreta API nem használja a régi
    // intézményválasztó endpointot.
    //
    // A bejelentkezés után az intézmény adatai
    // a TanuloAdatlap válaszából származnak.
    //
    // A régi UI kompatibilitása miatt egy tömböt
    // adunk vissza.

    return json.encode(
      <Map<String, dynamic>>[
        <String, dynamic>{
          'InstituteCode': 'ujkreta',
          'Name': 'ujkreta',
          'Url': BASE_URL,
        },
      ],
    );
  }

  // ============================================================
  // EGYÉB RÉGI METÓDUSOK
  // ============================================================

  void refreshSzivacsSettigns() async {
    // A régi Szivacs beállítás API már nem része
    // az ujkreta API-nak.
  }

  Future<String> getFAQ() async {
    return '';
  }

  Future<String> getTOS() async {
    return '';
  }

  // Az ujkreta jelenlegi API-ja nem kompatibilis a
  // régi multipart homework-feltöltéssel.
  void uploadHomework(
    String homework,
    dynamic lesson,
    User user,
  ) async {
    showError(
      'A házi feladat feltöltése jelenleg nem támogatott.',
    );
  }

  void seeMessage(
    int id,
    User user,
  ) async {
    // Nincs megfelelő végpont az új API-ban.
  }
}