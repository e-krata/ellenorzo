import 'dart:convert';

import 'RequestHelper.dart';

class UserInfoHelper {
  Future<Map<String, String>> getInfo(
      String instCode, String userName, String password, bool showErrors) async {
    final evaluationsMap =
        await _getEvaluationlist(instCode, userName, password, showErrors);

    String studentId = '';
    String studentName = '';

    if (evaluationsMap != null) {
      studentId = (evaluationsMap['Uid'] ?? evaluationsMap['StudentId'] ?? '').toString();
      studentName = (evaluationsMap['Nev'] ?? evaluationsMap['Name'] ?? '').toString();
    }

    return {
      'StudentId': studentId,
      'StudentName': studentName,
    };
  }

  Future<Map<String, dynamic>?> _getEvaluationlist(
      String instCode, String userName, String password, bool showErrors) async {
    // Token kérése a mocktól
    final body =
        'grant_type=password&username=$userName&password=$password';

    final bearerResponse =
        await RequestHelper().getBearer(body, instCode, showErrors);

    if (bearerResponse == null) return null;

    final bearerMap = json.decode(bearerResponse);
    final token = bearerMap['access_token'] as String?;

    if (token == null) {
      if (showErrors) RequestHelper().showError('Hibás bejelentkezés');
      return null;
    }

    // Profil lekérése
    final profileString = await RequestHelper().getStudentProfile(token);
    if (profileString == null) return null;

    return json.decode(profileString) as Map<String, dynamic>;
  }
}