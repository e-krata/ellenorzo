import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Datas/User.dart';

/// ÚjKréta API – diák ellenőrző
/// Base: https://ujkreta.onrender.com
class RequestHelper {
  static const String BASE_URL = 'https://ujkreta.onrender.com';
  static const String CLIENT_ID = 'ekrata-ellenorzo-mobil';

  static final Map<String, _TokenCache> _tokenCache =
      <String, _TokenCache>{};

  String _cacheKey(User user) {
    return (user.username ?? '') + '|' + (user.schoolCode ?? '');
  }

  Future<String> getBearerToken(
    User user,
    bool showErrors,
  ) async {
    final String key = _cacheKey(user);
    final _TokenCache cached = _tokenCache[key];

    if (cached != null &&
        cached.accessToken != null &&
        cached.accessToken.isNotEmpty &&
        cached.expiresAt != null &&
        cached.expiresAt.isAfter(
          DateTime.now().add(Duration(seconds: 30)),
        )) {
      return cached.accessToken;
    }

    if (cached != null &&
        cached.refreshToken != null &&
        cached.refreshToken.isNotEmpty) {
      final String refreshed =
          await _refreshToken(user, cached.refreshToken, showErrors);
      if (refreshed != null && refreshed.isNotEmpty) {
        return refreshed;
      }
    }

    return await _passwordGrant(user, showErrors);
  }

  Future<String> _passwordGrant(User user, bool showErrors) async {
    try {
      final Map<String, String> body = <String, String>{
        'grant_type': 'password',
        'username': user.username ?? '',
        'password': user.password ?? '',
        'client_id': CLIENT_ID,
      };

      if (user.schoolCode != null && user.schoolCode.isNotEmpty) {
        body['institute_code'] = user.schoolCode;
      }

      final http.Response response = await http.post(
        Uri.parse('$BASE_URL/connect/token'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        if (showErrors) {
          print(
            'Token request failed: ${response.statusCode} ${response.body}',
          );
        }
        return null;
      }

      return _storeTokenResponse(user, response.body, showErrors);
    } catch (e) {
      if (showErrors) {
        print(e);
      }
      return null;
    }
  }

  Future<String> _refreshToken(
    User user,
    String refreshToken,
    bool showErrors,
  ) async {
    try {
      final http.Response response = await http.post(
        Uri.parse('$BASE_URL/connect/token'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: <String, String>{
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': CLIENT_ID,
        },
      );

      if (response.statusCode != 200) {
        if (showErrors) {
          print('Refresh failed: ${response.statusCode} ${response.body}');
        }
        _tokenCache.remove(_cacheKey(user));
        return null;
      }

      return _storeTokenResponse(user, response.body, showErrors);
    } catch (e) {
      if (showErrors) {
        print(e);
      }
      return null;
    }
  }

  String _storeTokenResponse(User user, String body, bool showErrors) {
    try {
      final Map<String, dynamic> jsonResponse = json.decode(body);

      if (jsonResponse['error'] == 'mfa_required') {
        if (showErrors) {
          print('MFA required: ${jsonResponse['mfa_token']}');
        }
        return null;
      }

      final dynamic accessToken = jsonResponse['access_token'];
      if (accessToken == null) {
        if (showErrors) {
          print('Token response does not contain access_token.');
        }
        return null;
      }

      final int expiresIn = (jsonResponse['expires_in'] is int)
          ? jsonResponse['expires_in']
          : 43200;

      _tokenCache[_cacheKey(user)] = _TokenCache(
        accessToken: accessToken.toString(),
        refreshToken: jsonResponse['refresh_token']?.toString(),
        expiresAt: DateTime.now().add(Duration(seconds: expiresIn - 30)),
      );

      return accessToken.toString();
    } catch (e) {
      if (showErrors) {
        print(e);
      }
      return null;
    }
  }

  void clearTokenCache(User user) {
    if (user != null) {
      _tokenCache.remove(_cacheKey(user));
    }
  }

  Future<String> _get(
    String endpoint,
    String token,
    bool showErrors,
  ) async {
    try {
      final http.Response response = await http.get(
        Uri.parse('$BASE_URL$endpoint'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      }

      if (showErrors) {
        print('GET $endpoint failed: ${response.statusCode} ${response.body}');
      }
      return null;
    } catch (e) {
      if (showErrors) {
        print(e);
      }
      return null;
    }
  }

  Future<String> _post(
    String endpoint,
    String token,
    Map<String, dynamic> body,
    bool showErrors,
  ) async {
    try {
      final http.Response response = await http.post(
        Uri.parse('$BASE_URL$endpoint'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      }

      if (showErrors) {
        print('POST $endpoint failed: ${response.statusCode} ${response.body}');
      }
      return null;
    } catch (e) {
      if (showErrors) {
        print(e);
      }
      return null;
    }
  }

  Future<String> getStudentString(User user, bool showErrors) async {
    final String token = await getBearerToken(user, showErrors);
    if (token == null) {
      return null;
    }

    final String student = await _get(
      '/ellenorzo/v3/sajat/TanuloAdatlap',
      token,
      showErrors,
    );
    if (student == null) {
      return null;
    }

    try {
      final Map<String, dynamic> studentJson = json.decode(student);

      final String evaluations =
          await _get('/ellenorzo/v3/sajat/Ertekelesek', token, showErrors);
      if (evaluations != null) {
        final dynamic evaluationJson = json.decode(evaluations);
        if (evaluationJson is List) {
          studentJson['Evaluations'] = evaluationJson;
          studentJson['Ertekelesek'] = evaluationJson;
        }
      }

      final String absences =
          await _get('/ellenorzo/v3/sajat/Mulasztasok', token, showErrors);
      if (absences != null) {
        final dynamic absenceJson = json.decode(absences);
        if (absenceJson is List) {
          studentJson['Absences'] = absenceJson;
          studentJson['Mulasztasok'] = absenceJson;
        }
      }

      return json.encode(studentJson);
    } catch (e) {
      if (showErrors) {
        print(e);
      }
      return student;
    }
  }

  Future<String> getMessages(String token, String schoolCode) async {
    return await _get(
      '/integration-kretamobile-api/v1/kommunikacio/postaladaelemek/sajat',
      token,
      true,
    );
  }

  Future<String> getMessageById(int id, String token, String schoolCode) async {
    return await _get(
      '/integration-kretamobile-api/v1/kommunikacio/postaladaelemek/$id',
      token,
      true,
    );
  }

  Future<String> markMessagesAsRead(String token, List<int> messageIds) async {
    return await _post(
      '/integration-kretamobile-api/v1/kommunikacio/uzenetek/olvasott',
      token,
      <String, dynamic>{
        'isOlvasott': true,
        'uzenetAzonositoLista': messageIds,
      },
      true,
    );
  }

  Future<String> sendMessage(
    String token,
    String subject,
    String text,
    String recipientUid,
    String recipientName,
    String senderName,
    String senderTitle,
  ) async {
    return await _post(
      '/integration-kretamobile-api/v1/kommunikacio/uzenetek',
      token,
      <String, dynamic>{
        'targy': subject,
        'szoveg': text,
        'cimzettUid': recipientUid,
        'cimzettNev': recipientName,
        'feladoNev': senderName,
        'feladoTitulus': senderTitle,
      },
      true,
    );
  }

  Future<String> getEvaluations(String token, String schoolCode) async {
    return await _get('/ellenorzo/v3/sajat/Ertekelesek', token, true);
  }

  Future<String> getProfile(String token, String schoolCode) async {
    return await _get('/ellenorzo/v3/sajat/TanuloAdatlap', token, true);
  }

  Future<String> getTimeTable(
    String token,
    String schoolCode,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _get('/ellenorzo/v3/sajat/OrarendElemek', token, true);
  }

  Future<String> getTests(String token, String schoolCode) async {
    return await _get(
      '/ellenorzo/v3/sajat/BejelentettSzamonkeresek',
      token,
      true,
    );
  }

  Future<String> getHomework(String token, String schoolCode) async {
    return await _get('/ellenorzo/v3/sajat/HaziFeladatok', token, true);
  }

  Future<String> getAbsences(String token, String schoolCode) async {
    return await _get('/ellenorzo/v3/sajat/Mulasztasok', token, true);
  }

  Future<String> getNotes(String token, String schoolCode) async {
    return await _get('/ellenorzo/v3/sajat/Feljegyzesek', token, true);
  }

  Future<String> getWall(String token, String schoolCode) async {
    return await _get('/ellenorzo/v3/sajat/FaliujsagElemek', token, true);
  }

  Future<String> getClassGroups(String token, String schoolCode) async {
    return await _get('/ellenorzo/v3/sajat/OsztalyCsoportok', token, true);
  }

  Future<String> getAverages(String token, String schoolCode) async {
    return await _get(
      '/ellenorzo/v3/sajat/Ertekelesek/Atlagok/OsztalyAtlagok',
      token,
      true,
    );
  }

  Future<String> getEventsString(User user, bool showErrors) async {
    final String token = await getBearerToken(user, showErrors);
    if (token == null) {
      return null;
    }

    final String notes =
        await _get('/ellenorzo/v3/sajat/Feljegyzesek', token, showErrors);
    final String wall =
        await _get('/ellenorzo/v3/sajat/FaliujsagElemek', token, showErrors);

    final List<dynamic> events = <dynamic>[];

    if (notes != null) {
      try {
        final dynamic jsonNotes = json.decode(notes);
        if (jsonNotes is List) {
          events.addAll(jsonNotes);
        }
      } catch (e) {
        if (showErrors) {
          print(e);
        }
      }
    }

    if (wall != null) {
      try {
        final dynamic jsonWall = json.decode(wall);
        if (jsonWall is List) {
          events.addAll(jsonWall);
        }
      } catch (e) {
        if (showErrors) {
          print(e);
        }
      }
    }

    return json.encode(events);
  }

  Future<String> getInstitutes() async {
    try {
      final http.Response response = await http.get(
        Uri.parse('$BASE_URL/intezmenyek'),
        headers: <String, String>{'Accept': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      }

      return json.encode(<Map<String, dynamic>>[
        <String, dynamic>{
          'InstituteCode': 'mockschool',
          'Kod': 'mockschool',
          'Name': 'ÚjKréta mock',
          'Nev': 'ÚjKréta mock',
          'Url': BASE_URL,
          'City': '',
        },
      ]);
    } catch (e) {
      print(e);
      return json.encode(<Map<String, dynamic>>[
        <String, dynamic>{
          'InstituteCode': 'mockschool',
          'Kod': 'mockschool',
          'Name': 'ÚjKréta mock',
          'Nev': 'ÚjKréta mock',
          'Url': BASE_URL,
          'City': '',
        },
      ]);
    }
  }

  Future<String> uploadHomework(
    String token,
    String schoolCode,
    dynamic homework,
  ) async {
    return null;
  }
}

class _TokenCache {
  _TokenCache({
    this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
}