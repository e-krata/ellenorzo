import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Datas/User.dart';

class RequestHelper {
  static const String BASE_URL =
      'https://ujkreta.onrender.com';

  static const String CLIENT_ID =
      'ekrata-ellenorzo-mobil';

  static const String GRANT_TYPE =
      'password';

  Future<String> getBearerToken(
    User user,
    bool showErrors,
  ) async {
    try {
      Map<String, String> body = {
        'grant_type': GRANT_TYPE,
        'username': user.username,
        'password': user.password,
        'client_id': CLIENT_ID,
      };

      if (user.schoolCode != null &&
          user.schoolCode.isNotEmpty) {
        body['institute_code'] =
            user.schoolCode;
      }

      var response = await http.post(
        Uri.parse(
          '$BASE_URL/connect/token',
        ),
        headers: {
          'Content-Type':
              'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        if (showErrors) {
          print(
            'Token request failed: '
            '${response.statusCode} '
            '${response.body}',
          );
        }

        return null;
      }

      Map<String, dynamic> jsonResponse =
          json.decode(response.body);

      dynamic accessToken =
          jsonResponse['access_token'];

      if (accessToken == null) {
        if (showErrors) {
          print(
            'Token response does not contain '
            'access_token.',
          );
        }

        return null;
      }

      return accessToken.toString();
    } catch (e) {
      if (showErrors) {
        print(e);
      }

      return null;
    }
  }

  Future<String> _get(
    String endpoint,
    String token,
    bool showErrors,
  ) async {
    try {
      var response = await http.get(
        Uri.parse(
          '$BASE_URL$endpoint',
        ),
        headers: {
          'Authorization':
              'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return response.body;
      }

      if (showErrors) {
        print(
          'GET $endpoint failed: '
          '${response.statusCode} '
          '${response.body}',
        );
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
      var response = await http.post(
        Uri.parse(
          '$BASE_URL$endpoint',
        ),
        headers: {
          'Authorization':
              'Bearer $token',
          'Content-Type':
              'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return response.body;
      }

      if (showErrors) {
        print(
          'POST $endpoint failed: '
          '${response.statusCode} '
          '${response.body}',
        );
      }

      return null;
    } catch (e) {
      if (showErrors) {
        print(e);
      }

      return null;
    }
  }

  Future<String> getStudentString(
    User user,
    bool showErrors,
  ) async {
    String token =
        await getBearerToken(
      user,
      showErrors,
    );

    if (token == null) {
      return null;
    }

    String student =
        await _get(
      '/ellenorzo/v3/sajat/TanuloAdatlap',
      token,
      showErrors,
    );

    if (student == null) {
      return null;
    }

    try {
      Map<String, dynamic> studentJson =
          json.decode(student);

      String evaluations =
          await _get(
        '/ellenorzo/v3/sajat/Ertekelesek',
        token,
        showErrors,
      );

      if (evaluations != null) {
        var evaluationJson =
            json.decode(evaluations);

        if (evaluationJson is List) {
          studentJson['Evaluations'] =
              evaluationJson;
        }
      }

      String absences =
          await _get(
        '/ellenorzo/v3/sajat/Mulasztasok',
        token,
        showErrors,
      );

      if (absences != null) {
        var absenceJson =
            json.decode(absences);

        if (absenceJson is List) {
          studentJson['Absences'] =
              absenceJson;
        }
      }

      return json.encode(
        studentJson,
      );
    } catch (e) {
      if (showErrors) {
        print(e);
      }

      return student;
    }
  }

  Future<String> getMessages(
    String token,
    String schoolCode,
  ) async {
    return await _get(
      '/integration-kretamobile-api/v1/'
      'kommunikacio/'
      'postaladaelemek/sajat',
      token,
      true,
    );
  }

  Future<String> getMessageById(
    int id,
    String token,
    String schoolCode,
  ) async {
    return await _get(
      '/integration-kretamobile-api/v1/'
      'kommunikacio/'
      'postaladaelemek/$id',
      token,
      true,
    );
  }

  Future<String> markMessagesAsRead(
    String token,
    List<int> messageIds,
  ) async {
    return await _post(
      '/integration-kretamobile-api/v1/'
      'kommunikacio/'
      'uzenetek/olvasott',
      token,
      {
        'isOlvasott': true,
        'uzenetAzonositoLista':
            messageIds,
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
      '/integration-kretamobile-api/v1/'
      'kommunikacio/'
      'uzenetek',
      token,
      {
        'targy': subject,
        'szoveg': text,
        'cimzettUid':
            recipientUid,
        'cimzettNev':
            recipientName,
        'feladoNev':
            senderName,
        'feladoTitulus':
            senderTitle,
      },
      true,
    );
  }

  Future<String> getEvaluations(
    String token,
    String schoolCode,
  ) async {
    return await _get(
      '/ellenorzo/v3/sajat/Ertekelesek',
      token,
      true,
    );
  }

  Future<String> getProfile(
    String token,
    String schoolCode,
  ) async {
    return await _get(
      '/ellenorzo/v3/sajat/TanuloAdatlap',
      token,
      true,
    );
  }

  Future<String> getTimeTable(
    String token,
    String schoolCode,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _get(
      '/ellenorzo/v3/sajat/OrarendElemek',
      token,
      true,
    );
  }

  Future<String> getTests(
    String token,
    String schoolCode,
  ) async {
    return await _get(
      '/ellenorzo/v3/sajat/'
      'BejelentettSzamonkeresek',
      token,
      true,
    );
  }

  Future<String> getHomework(
    String token,
    String schoolCode,
  ) async {
    return await _get(
      '/ellenorzo/v3/sajat/HaziFeladatok',
      token,
      true,
    );
  }

  Future<String> getAbsences(
    String token,
    String schoolCode,
  ) async {
    return await _get(
      '/ellenorzo/v3/sajat/Mulasztasok',
      token,
      true,
    );
  }

  Future<String> getNotes(
    String token,
    String schoolCode,
  ) async {
    return await _get(
      '/ellenorzo/v3/sajat/Feljegyzesek',
      token,
      true,
    );
  }

  Future<String> getWall(
    String token,
    String schoolCode,
  ) async {
    return await _get(
      '/ellenorzo/v3/sajat/FaliujsagElemek',
      token,
      true,
    );
  }

  Future<String> getClassGroups(
    String token,
    String schoolCode,
  ) async {
    return await _get(
      '/ellenorzo/v3/sajat/OsztalyCsoportok',
      token,
      true,
    );
  }

  Future<String> getAverages(
    String token,
    String schoolCode,
  ) async {
    return await _get(
      '/ellenorzo/v3/sajat/'
      'Ertekelesek/'
      'Atlagok/'
      'OsztalyAtlagok',
      token,
      true,
    );
  }

  Future<String> getEventsString(
    User user,
    bool showErrors,
  ) async {
    String token =
        await getBearerToken(
      user,
      showErrors,
    );

    if (token == null) {
      return null;
    }

    String notes =
        await _get(
      '/ellenorzo/v3/sajat/Feljegyzesek',
      token,
      showErrors,
    );

    String wall =
        await _get(
      '/ellenorzo/v3/sajat/FaliujsagElemek',
      token,
      showErrors,
    );

    List events = [];

    if (notes != null) {
      try {
        var jsonNotes =
            json.decode(notes);

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
        var jsonWall =
            json.decode(wall);

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
      var response = await http.get(
        Uri.parse(
          '$BASE_URL/intezmenyek',
        ),
        headers: {
          'Accept':
              'application/json',
        },
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return response.body;
      }

      print(
        'Institute request failed: '
        '${response.statusCode} '
        '${response.body}',
      );

      return json.encode([]);
    } catch (e) {
      print(e);

      return json.encode([]);
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