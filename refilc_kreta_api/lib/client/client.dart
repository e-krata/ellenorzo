// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http_io;

import 'package:refilc/api/providers/database_provider.dart';
import 'package:refilc/api/providers/status_provider.dart';
import 'package:refilc/api/providers/user_provider.dart';
import 'package:refilc/models/settings.dart';
import 'package:refilc/models/user.dart';

import 'package:refilc_kreta_api/client/api.dart';

class KretaClient {
  String? accessToken;
  String? refreshToken;
  String? idToken;
  String? userAgent;

  late http.Client client;

  late final SettingsProvider _settings;
  late final UserProvider _user;
  late final DatabaseProvider _database;
  late final StatusProvider _status;

  KretaClient({
    this.accessToken,
    required SettingsProvider settings,
    required UserProvider user,
    required DatabaseProvider database,
    required StatusProvider status,
  })  : _settings = settings,
        _user = user,
        _database = database,
        _status = status,
        userAgent = settings.config.userAgent {
    final ioClient = HttpClient();

    ioClient.badCertificateCallback = _checkCerts;

    client = http_io.IOClient(ioClient);
  }

  bool _checkCerts(
    X509Certificate cert,
    String host,
    int port,
  ) {
    return _settings.developerMode;
  }

  // ============================================================
  // GET
  // ============================================================

  Future<dynamic> getAPI(
    String url, {
    Map<String, String>? headers,
    bool autoHeader = true,
    bool json = true,
    bool rawResponse = false,
  }) async {
    if (rawResponse) {
      json = false;
    }

    final headerMap = <String, String>{
      ...(headers ?? {}),
    };

    if (accessToken == null || accessToken!.isEmpty) {
      accessToken = _user.user?.accessToken;
    }

    try {
      http.Response? response;

      for (int attempt = 0; attempt < 2; attempt++) {
        if (autoHeader) {
          if (!headerMap.containsKey("authorization") &&
              accessToken != null &&
              accessToken!.isNotEmpty) {
            headerMap["authorization"] =
                "Bearer $accessToken";
          }

          if (!headerMap.containsKey("user-agent") &&
              userAgent != null &&
              userAgent!.isNotEmpty) {
            headerMap["user-agent"] = userAgent!;
          }

          if (!headerMap.containsKey("accept")) {
            headerMap["accept"] = "application/json";
          }
        }

        response = await client.get(
          Uri.parse(url),
          headers: headerMap,
        );

        _status.triggerRequest(response);

        if (response.statusCode == 401 && attempt == 0) {
          print(
            "DEBUG: GET 401, trying token refresh: $url",
          );

          final refreshResult = await refreshLogin();

          if (refreshResult != "success") {
            break;
          }

          headerMap.remove("authorization");

          await Future.delayed(
            const Duration(milliseconds: 300),
          );

          continue;
        }

        break;
      }

      if (response == null) {
        throw "No response";
      }

      if (response.body.trim().isEmpty) {
        return null;
      }

      if (response.statusCode >= 400) {
        print(
          "ERROR: GET $url -> "
          "${response.statusCode}: ${response.body}",
        );

        return null;
      }

      if (json) {
        return jsonDecode(response.body);
      }

      if (rawResponse) {
        return response.bodyBytes;
      }

      return response.body;
    } on http.ClientException catch (error) {
      print(
        "ERROR: KretaClient.getAPI "
        "($url) ClientException: ${error.message}",
      );
    } catch (error) {
      print(
        "ERROR: KretaClient.getAPI "
        "($url) ${error.runtimeType}: $error",
      );
    }

    return null;
  }

  // ============================================================
  // POST
  // ============================================================

  Future<dynamic> postAPI(
    String url, {
    Map<String, String>? headers,
    bool autoHeader = true,
    bool json = true,
    Object? body,
  }) async {
    final headerMap = <String, String>{
      ...(headers ?? {}),
    };

    if (accessToken == null || accessToken!.isEmpty) {
      accessToken = _user.user?.accessToken;
    }

    try {
      http.Response? response;

      for (int attempt = 0; attempt < 2; attempt++) {
        if (autoHeader) {
          if (!headerMap.containsKey("authorization") &&
              accessToken != null &&
              accessToken!.isNotEmpty) {
            headerMap["authorization"] =
                "Bearer $accessToken";
          }

          if (!headerMap.containsKey("user-agent") &&
              userAgent != null &&
              userAgent!.isNotEmpty) {
            headerMap["user-agent"] = userAgent!;
          }

          if (!headerMap.containsKey("content-type")) {
            headerMap["content-type"] =
                "application/json";
          }

          if (!headerMap.containsKey("accept")) {
            headerMap["accept"] =
                "application/json";
          }
        }

        response = await client.post(
          Uri.parse(url),
          headers: headerMap,
          body: body,
        );

        _status.triggerRequest(response);

        if (response.statusCode == 401 &&
            attempt == 0) {
          print(
            "DEBUG: POST 401, trying token refresh: $url",
          );

          final refreshResult = await refreshLogin();

          if (refreshResult != "success") {
            break;
          }

          headerMap.remove("authorization");

          await Future.delayed(
            const Duration(milliseconds: 300),
          );

          continue;
        }

        break;
      }

      if (response == null) {
        throw "No response";
      }

      if (response.body.trim().isEmpty) {
        return null;
      }

      if (response.statusCode >= 400) {
        print(
          "ERROR: POST $url -> "
          "${response.statusCode}: ${response.body}",
        );

        return null;
      }

      if (json) {
        return jsonDecode(response.body);
      }

      return response.body;
    } on http.ClientException catch (error) {
      print(
        "ERROR: KretaClient.postAPI "
        "($url) ClientException: ${error.message}",
      );
    } catch (error) {
      print(
        "ERROR: KretaClient.postAPI "
        "($url) ${error.runtimeType}: $error",
      );
    }

    return null;
  }

  // ============================================================
  // Multipart
  // ============================================================

  Future<dynamic> sendFilesAPI(
    String url, {
    Map<String, String>? headers,
    bool autoHeader = true,
    Map<String, String>? body,
  }) async {
    final headerMap = <String, String>{
      ...(headers ?? {}),
    };

    if (accessToken == null || accessToken!.isEmpty) {
      accessToken = _user.user?.accessToken;
    }

    try {
      http.StreamedResponse? response;

      for (int attempt = 0; attempt < 2; attempt++) {
        final request = http.MultipartRequest(
          "POST",
          Uri.parse(url),
        );

        if (autoHeader) {
          if (accessToken != null &&
              accessToken!.isNotEmpty) {
            request.headers["authorization"] =
                "Bearer $accessToken";
          }

          if (userAgent != null &&
              userAgent!.isNotEmpty) {
            request.headers["user-agent"] =
                userAgent!;
          }
        }

        request.headers.addAll(headerMap);

        request.fields.addAll(body ?? {});

        response = await request.send();

        if (response.statusCode == 401 &&
            attempt == 0) {
          final refreshResult = await refreshLogin();

          if (refreshResult != "success") {
            break;
          }

          continue;
        }

        break;
      }

      if (response == null) {
        return null;
      }

      print(
        "DEBUG: multipart POST $url -> "
        "${response.statusCode}",
      );

      return response.statusCode;
    } on http.ClientException catch (error) {
      print(
        "ERROR: KretaClient.sendFilesAPI "
        "($url) ClientException: ${error.message}",
      );
    } catch (error) {
      print(
        "ERROR: KretaClient.sendFilesAPI "
        "($url) ${error.runtimeType}: $error",
      );
    }

    return null;
  }

  // ============================================================
  // Refresh token
  // ============================================================

  Future<String?> refreshLogin() async {
    final loginUser = _user.user;

    if (loginUser == null) {
      return null;
    }

    refreshToken ??= loginUser.refreshToken;

    if (refreshToken == null ||
        refreshToken!.isEmpty) {
      return null;
    }

    if (!DateTime.now().isAfter(
      loginUser.accessTokenExpire,
    )) {
      return "success";
    }

    final headers = <String, String>{
      "content-type":
          "application/x-www-form-urlencoded",
      "accept": "application/json",
    };

    print(
      "DEBUG: refreshing token for "
      "${loginUser.name}",
    );

    final response = await postAPI(
      KretaAPI.login,
      headers: headers,
      autoHeader: false,
      body: {
        "grant_type": "refresh_token",
        "refresh_token": refreshToken!,
      },
    );

    if (response == null) {
      return null;
    }

    if (response["error"] != null) {
      if (response["error"] ==
          "invalid_grant") {
        print(
          "ERROR: refresh token expired",
        );

        return "refresh_token_expired";
      }

      return null;
    }

    final newAccessToken =
        response["access_token"];

    if (newAccessToken == null) {
      return null;
    }

    accessToken = newAccessToken;

    loginUser.accessToken =
        newAccessToken;

    final expiresIn =
        (response["expires_in"] ?? 43200)
            as num;

    loginUser.accessTokenExpire =
        DateTime.now().add(
      Duration(
        seconds: expiresIn.toInt() - 30,
      ),
    );

    if (response["refresh_token"] != null) {
      refreshToken =
          response["refresh_token"];

      loginUser.refreshToken =
          response["refresh_token"];
    }

    if (response["id_token"] != null) {
      idToken = response["id_token"];
    }

    await _database.store.storeUser(
      loginUser,
    );

    _user.refresh();

    print(
      "DEBUG: token refresh successful",
    );

    return "success";
  }

  // ============================================================
  // Logout
  // ============================================================

  Future<void> logout() async {
    // Az ÚjKréta dokumentáció jelenlegi változata
    // nem definiál revocation endpointot.
    //
    // Ezért lokálisan töröljük a kliens tokenjeit.

    accessToken = null;
    refreshToken = null;
    idToken = null;

    print(
      "DEBUG: logged out locally",
    );
  }
}
