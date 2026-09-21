```dart
// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:refilc/api/providers/database_provider.dart';
import 'package:refilc/api/providers/user_provider.dart';
import 'package:refilc/models/settings.dart';
import 'package:refilc/models/user.dart';

import 'package:refilc_kreta_api/client/api.dart';
import 'package:refilc_kreta_api/client/client.dart';

import 'package:refilc_kreta_api/models/school.dart';
import 'package:refilc_kreta_api/models/student.dart';
import 'package:refilc_kreta_api/models/week.dart';

import 'package:refilc_kreta_api/providers/absence_provider.dart';
import 'package:refilc_kreta_api/providers/event_provider.dart';
import 'package:refilc_kreta_api/providers/exam_provider.dart';
import 'package:refilc_kreta_api/providers/grade_provider.dart';
import 'package:refilc_kreta_api/providers/homework_provider.dart';
import 'package:refilc_kreta_api/providers/message_provider.dart';
import 'package:refilc_kreta_api/providers/note_provider.dart';
import 'package:refilc_kreta_api/providers/timetable_provider.dart';

enum LoginState {
  missingFields,
  invalidGrant,
  failed,
  normal,
  inProgress,
  success,
}

// ============================================================
// Teszt login
// ============================================================

Future<LoginState> _testLogin({
  required String username,
  required String password,
  required String instituteCode,
  required BuildContext context,
  required School school,
  void Function(User)? onLogin,
  void Function()? onSuccess,
}) async {
  final user = User(
    username: username,
    password: password,
    instituteCode: instituteCode,
    name: 'Teszt Lajos',
    student: Student(
      birth: DateTime.now(),
      id: const Uuid().v4(),
      name: 'Teszt Lajos',
      school: school,
      yearId: '1',
      parents: [
        'Teszt András',
        'Teszt Linda',
      ],
      json: {
        "a": "b",
      },
      address:
          '1117 Budapest, Gábor Dénes utca 4.',
      gradeDelay: 0,
    ),
    role: Role.parent,
    accessToken: '',
    accessTokenExpire: DateTime.now(),
    refreshToken: '',
  );

  if (onLogin != null) {
    onLogin(user);
  }

  await Provider.of<DatabaseProvider>(
    context,
    listen: false,
  ).store.storeUser(user);

  Provider.of<UserProvider>(
    context,
    listen: false,
  ).addUser(user);

  Provider.of<UserProvider>(
    context,
    listen: false,
  ).setUser(user.id);

  if (onSuccess != null) {
    onSuccess();
  }

  return LoginState.success;
}

// ============================================================
// Password login
// ============================================================

Future<LoginState> loginAPI({
  required String username,
  required String password,
  required String instituteCode,
  required BuildContext context,
  void Function(User)? onLogin,
  void Function()? onSuccess,
}) async {
  // ----------------------------------------------------------
  // Régi teszt accountok
  // ----------------------------------------------------------

  switch (instituteCode) {
    case 'refilc-test-sweden':
      final school = School(
        city: "Stockholm",
        instituteCode: "refilc-test-sweden",
        name:
            "reFilc Test SE - Leo Ekström High School",
      );

      return _testLogin(
        username: username,
        password: password,
        instituteCode: instituteCode,
        context: context,
        school: school,
        onLogin: onLogin,
        onSuccess: onSuccess,
      );

    case 'refilc-test-spain':
      final school = School(
        city: "Madrid",
        instituteCode: "refilc-test-spain",
        name:
            "reFilc Test ES - Emilio Obrero University",
      );

      return _testLogin(
        username: username,
        password: password,
        instituteCode: instituteCode,
        context: context,
        school: school,
        onLogin: onLogin,
        onSuccess: onSuccess,
      );
  }

  // ----------------------------------------------------------
  // ÚjKréta login
  // ----------------------------------------------------------

  final kretaClient =
      Provider.of<KretaClient>(
    context,
    listen: false,
  );

  kretaClient.userAgent =
      Provider.of<SettingsProvider>(
    context,
    listen: false,
  ).config.userAgent;

  final headers = <String, String>{
    "content-type":
        "application/x-www-form-urlencoded",
    "accept": "application/json",
  };

  // ----------------------------------------------------------
  // POST /connect/token
  // ----------------------------------------------------------

  final Map<String, dynamic>? response =
      await kretaClient.postAPI(
    KretaAPI.login,
    headers: headers,
    autoHeader: false,
    body: {
      "grant_type": "password",
      "username": username,
      "password": password,
    },
  );

  if (response == null) {
    print(
      "ERROR: ÚjKréta login returned null",
    );

    return LoginState.failed;
  }

  // ----------------------------------------------------------
  // Login error
  // ----------------------------------------------------------

  if (response["error"] != null) {
    print(
      "ERROR: ÚjKréta login error: "
      "${response["error"]}",
    );

    if (response["error"] ==
        "invalid_grant") {
      return LoginState.invalidGrant;
    }

    return LoginState.failed;
  }

  // ----------------------------------------------------------
  // Access token
  // ----------------------------------------------------------

  final accessToken =
      response["access_token"];

  if (accessToken == null ||
      accessToken.toString().isEmpty) {
    print(
      "ERROR: ÚjKréta response "
      "does not contain access_token",
    );

    return LoginState.failed;
  }

  try {
    kretaClient.accessToken =
        accessToken.toString();

    if (response["refresh_token"] != null) {
      kretaClient.refreshToken =
          response["refresh_token"].toString();
    }

    if (response["id_token"] != null) {
      kretaClient.idToken =
          response["id_token"].toString();
    }

    // --------------------------------------------------------
    // Student profile
    // --------------------------------------------------------

    final studentJson =
        await kretaClient.getAPI(
      KretaAPI.student,
    );

    if (studentJson == null) {
      print(
        "ERROR: TanuloAdatlap returned null",
      );

      return LoginState.failed;
    }

    final student =
        Student.fromJson(studentJson);

    // --------------------------------------------------------
    // Token expiry
    // --------------------------------------------------------

    final expiresIn =
        (response["expires_in"] ?? 43200)
            as num;

    final accessTokenExpire =
        DateTime.now().add(
      Duration(
        seconds: expiresIn.toInt() - 30,
      ),
    );

    // --------------------------------------------------------
    // User
    // --------------------------------------------------------

    final user = User(
      username: username,
      password: password,

      // Az ÚjKréta token endpoint nem kér
      // institute_code-ot.
      //
      // A bejelentkezési képernyőből érkező értéket
      // továbbra is eltároljuk a kompatibilitás miatt.
      instituteCode: instituteCode,

      name: student.name,
      student: student,

      // A dokumentáció szerint a student role:
      // "Tanulo".
      role: Role.student,

      accessToken:
          accessToken.toString(),

      accessTokenExpire:
          accessTokenExpire,

      refreshToken:
          response["refresh_token"]?.toString() ?? "",
    );

    if (onLogin != null) {
      onLogin(user);
    }

    // --------------------------------------------------------
    // Save user
    // --------------------------------------------------------

    await Provider.of<DatabaseProvider>(
      context,
      listen: false,
    ).store.storeUser(user);

    Provider.of<UserProvider>(
      context,
      listen: false,
    ).addUser(user);

    Provider.of<UserProvider>(
      context,
      listen: false,
    ).setUser(user.id);

    // --------------------------------------------------------
    // Fetch data
    // --------------------------------------------------------

    try {
      await Future.wait([
        Provider.of<GradeProvider>(
          context,
          listen: false,
        ).fetch(),

        Provider.of<TimetableProvider>(
          context,
          listen: false,
        ).fetch(
          week: Week.current(),
        ),

        Provider.of<ExamProvider>(
          context,
          listen: false,
        ).fetch(),

        Provider.of<HomeworkProvider>(
          context,
          listen: false,
        ).fetch(),

        Provider.of<NoteProvider>(
          context,
          listen: false,
        ).fetch(),

        Provider.of<EventProvider>(
          context,
          listen: false,
        ).fetch(),

        Provider.of<AbsenceProvider>(
          context,
          listen: false,
        ).fetch(),
      ]);
    } catch (error) {
      print(
        "WARNING: failed to fetch user data: "
        "$error",
      );
    }

    if (onSuccess != null) {
      onSuccess();
    }

    return LoginState.success;
  } catch (error, stackTrace) {
    print(
      "ERROR: loginAPI: $error",
    );

    if (kDebugMode) {
      print(stackTrace);
    }

    return LoginState.failed;
  }
}

// ============================================================
// Authorization-code login
// ============================================================
//
// Az ÚjKréta docs szerint támogatott:
// grant_type=authorization_code
//
// A régi e-KRÉTA mobil redirect flow-t viszont nem
// használjuk automatikusan, mert az ÚjKréta saját
// dokumentációja a password grantet dokumentálja.
// ============================================================

Future<LoginState> newLoginAPI({
  required String code,
  required BuildContext context,
  void Function(User)? onLogin,
  void Function()? onSuccess,
}) async {
  final kretaClient =
      Provider.of<KretaClient>(
    context,
    listen: false,
  );

  kretaClient.userAgent =
      Provider.of<SettingsProvider>(
    context,
    listen: false,
  ).config.userAgent;

  final headers = <String, String>{
    "content-type":
        "application/x-www-form-urlencoded",
    "accept": "application/json",
  };

  final response =
      await kretaClient.postAPI(
    KretaAPI.login,
    headers: headers,
    autoHeader: false,
    body: {
      "grant_type": "authorization_code",
      "code": code,
    },
  );

  if (response == null) {
    return LoginState.failed;
  }

  if (response["error"] != null) {
    if (response["error"] ==
        "invalid_grant") {
      return LoginState.invalidGrant;
    }

    return LoginState.failed;
  }

  final accessToken =
      response["access_token"];

  if (accessToken == null) {
    return LoginState.failed;
  }

  try {
    kretaClient.accessToken =
        accessToken.toString();

    kretaClient.refreshToken =
        response["refresh_token"]?.toString();

    kretaClient.idToken =
        response["id_token"]?.toString();

    final studentJson =
        await kretaClient.getAPI(
      KretaAPI.student,
    );

    if (studentJson == null) {
      return LoginState.failed;
    }

    final student =
        Student.fromJson(studentJson);

    final expiresIn =
        (response["expires_in"] ?? 43200)
            as num;

    final user = User(
      username: "",
      password: "",
      instituteCode:
          instituteCodeFromStudent(
        studentJson,
      ),
      name: student.name,
      student: student,
      role: Role.student,
      accessToken:
          accessToken.toString(),
      accessTokenExpire:
          DateTime.now().add(
        Duration(
          seconds: expiresIn.toInt() - 30,
        ),
      ),
      refreshToken:
          response["refresh_token"]
              ?.toString() ??
          "",
    );

    if (onLogin != null) {
      onLogin(user);
    }

    await Provider.of<DatabaseProvider>(
      context,
      listen: false,
    ).store.storeUser(user);

    Provider.of<UserProvider>(
      context,
      listen: false,
    ).addUser(user);

    Provider.of<UserProvider>(
      context,
      listen: false,
    ).setUser(user.id);

    try {
      await Future.wait([
        Provider.of<GradeProvider>(
          context,
          listen: false,
        ).fetch(),

        Provider.of<TimetableProvider>(
          context,
          listen: false,
        ).fetch(
          week: Week.current(),
        ),

        Provider.of<ExamProvider>(
          context,
          listen: false,
        ).fetch(),

        Provider.of<HomeworkProvider>(
          context,
          listen: false,
        ).fetch(),

        Provider.of<NoteProvider>(
          context,
          listen: false,
        ).fetch(),

        Provider.of<EventProvider>(
          context,
          listen: false,
        ).fetch(),

        Provider.of<AbsenceProvider>(
          context,
          listen: false,
        ).fetch(),
      ]);
    } catch (error) {
      print(
        "WARNING: failed to fetch user data: "
        "$error",
      );
    }

    if (onSuccess != null) {
      onSuccess();
    }

    return LoginState.success;
  } catch (error) {
    print(
      "ERROR: newLoginAPI: $error",
    );

    return LoginState.failed;
  }
}

// ============================================================
// Helper
// ============================================================

String instituteCodeFromStudent(
  dynamic json,
) {
  if (json is Map) {
    final value =
        json["IntezmenyAzonosito"];

    if (value != null) {
      return value.toString();
    }
  }

  return "";
}
```
