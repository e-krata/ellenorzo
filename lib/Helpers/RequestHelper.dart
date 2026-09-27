import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../Datas/User.dart';
import '../globals.dart' as globals;

class RequestHelper {
  // ========== KRÁTA MOCK BEÁLLÍTÁSOK ==========
  // Cseréld ki, ha más a te instance-od
  static const String BASE_URL = 'https://ujkreta.onrender.com';

  // Régi konstansok (kompatibilitás miatt meghagyva)
  static const String CLIENT_ID = 'ekrata-ellenorzo-mobil';
  static const String GRANT_TYPE = 'password';

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

  // ========== TOKEN ==========
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
        final map = json.decode(response.body);
        return map['access_token'] as String?;
      } else {
        final err = json.decode(response.body);
        if (showErrors) {
          showError(err['error_description'] ?? 'Hibás felhasználónév vagy jelszó');
        }
        return null;
      }
    } catch (e) {
      if (showErrors) showError('Hálózati hiba');
      print(e);
      return null;
    }
  }

  // Régi getBearer metódus (kompatibilitás)
  Future<String?> getBearer(String jsonBody, String schoolCode, bool showErrors) async {
    // A mocknál a schoolCode nem számít, a body-ból kinyerjük a usert
    try {
      final uri = Uri.parse('$BASE_URL/connect/token');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: jsonBody.contains('grant_type') ? jsonBody : 'grant_type=password&$jsonBody',
      );
      return response.body;
    } catch (e) {
      if (showErrors) showError('Hálózati hiba');
      return null;
    }
  }

  // ========== ÁLTALÁNOS GET ==========
  Future<String?> getStuffFromUrl(String path, String? accessToken, [String? schoolCode]) async {
    if (accessToken == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL$path'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print('API hiba ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  // ========== DIÁK VÉGPONTOK (KRÁTA mock V3) ==========

  Future<String?> getEvaluations(String accessToken, String schoolCode) async {
    // Régi: /mapi/api/v1/Student
    // Új:   /ellenorzo/v3/sajat/Ertekelesek  + profil
    return getStuffFromUrl('/ellenorzo/v3/sajat/Ertekelesek', accessToken);
  }

  Future<String?> getStudentProfile(String accessToken) async {
    return getStuffFromUrl('/ellenorzo/v3/sajat/TanuloAdatlap', accessToken);
  }

  Future<String?> getTimeTable(String from, String to, String accessToken, String schoolCode) async {
    // A mock jelenleg nem szűr dátumra a docs szerint, de a path megvan
    return getStuffFromUrl('/ellenorzo/v3/sajat/OrarendElemek', accessToken);
  }

  Future<String?> getTests(String accessToken, String schoolCode) async {
    return getStuffFromUrl('/ellenorzo/v3/sajat/BejelentettSzamonkeresek', accessToken);
  }

  Future<String?> getAbsences(String accessToken) async {
    return getStuffFromUrl('/ellenorzo/v3/sajat/Mulasztasok', accessToken);
  }

  Future<String?> getHomeworks(String accessToken) async {
    return getStuffFromUrl('/ellenorzo/v3/sajat/HaziFeladatok', accessToken);
  }

  Future<String?> getEvents(String accessToken, String schoolCode) async {
    // Faliújság
    return getStuffFromUrl('/ellenorzo/v3/sajat/FaliujsagElemek', accessToken);
  }

  Future<String?> getNotes(String accessToken) async {
    return getStuffFromUrl('/ellenorzo/v3/sajat/Feljegyzesek', accessToken);
  }

  Future<String?> getGroups(String accessToken) async {
    return getStuffFromUrl('/ellenorzo/v3/sajat/OsztalyCsoportok', accessToken);
  }

  Future<String?> getClassAverages(String accessToken) async {
    return getStuffFromUrl('/ellenorzo/v3/sajat/Ertekelesek/Atlagok/OsztalyAtlagok', accessToken);
  }

  // Régi homework metódusok (kompatibilitás)
  Future<String?> getHomework(String accessToken, String schoolCode, int id) async {
    return getHomeworks(accessToken);
  }

  Future<String?> getHomeworkByTeacher(String accessToken, String schoolCode, int id) async {
    return getHomeworks(accessToken);
  }

  // Üzenetek (a mockban jelenleg nincs teljes eügyintézés, de meghagyjuk)
  Future<String?> getMessages(String accessToken, String schoolCode) async {
    return null; // A mock docsban nincs
  }

  Future<String?> getMessageById(int id, String accessToken, String schoolCode) async {
    return null;
  }

  // ========== SEGÉD ==========
  Future<String?> getStudentString(User user, bool showErrors) async {
    final token = await getBearerToken(user, showErrors);
    if (token == null) return null;

    // A régi kód a Student endpointot várta, ami tartalmazta a jegyeket is.
    // Most külön lekérjük a profilt + jegyeket, és összefűzzük ha kell.
    final profile = await getStudentProfile(token);
    final grades = await getEvaluations(token, user.schoolCode ?? 'mockschool');

    // Egyszerű kompatibilitási válasz
    if (profile != null && grades != null) {
      try {
        final p = json.decode(profile);
        final g = json.decode(grades);
        p['Evaluations'] = g; // hogy a régi parser találjon valamit
        return json.encode(p);
      } catch (_) {}
    }
    return grades ?? profile;
  }

  Future<String?> getEventsString(User user, bool showErrors) async {
    final token = await getBearerToken(user, showErrors);
    if (token == null) return null;
    return getEvents(token, user.schoolCode ?? 'mockschool');
  }

  // Dummy / nem használt a mockban
  Future<String> getInstitutes() async {
    // A mocknak nincs iskolalistája, fix mockschool
    return json.encode([
      {
        'InstituteCode': 'mockschool',
        'Name': 'Mock Gimnázium',
        'Url': BASE_URL,
      }
    ]);
  }

  void refreshSzivacsSettigns() async {
    // nem kell a mockhoz
  }

  Future<String> getFAQ() async => '';
  Future<String> getTOS() async => '';

  void uploadHomework(String homework, dynamic lesson, User user) async {
    showError('A mock API jelenleg nem támogatja a házi feltöltést ezzel a régi formátummal');
  }

  void seeMessage(int id, User user) async {}
}