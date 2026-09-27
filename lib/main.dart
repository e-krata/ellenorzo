import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Datas/Institution.dart';
import 'Datas/User.dart';
import 'Helpers/RequestHelper.dart';
import 'Utils/AccountManager.dart';
import 'screens/mainScreen.dart';
import 'globals.dart' as globals;

void main() {
  runApp(
    new KrataApp(),
  );
}

class KrataApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Ellenőrző',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: new LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final bool fromApp;

  LoginScreen({
    this.fromApp = false,
  });

  @override
  LoginScreenState createState() =>
      new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController =
      new TextEditingController();

  final TextEditingController passwordController =
      new TextEditingController();

  final TextEditingController schoolController =
      new TextEditingController();

  List<Institution> institutions =
      new List<Institution>();

  Institution selectedInstitution;

  bool loadingInstitutions = false;
  bool loggingIn = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();

    loadInstitutions();
  }

  Future<void> loadInstitutions() async {
    setState(() {
      loadingInstitutions = true;
    });

    try {
      String response =
          await RequestHelper().getInstitutes();

      if (response != null) {
        dynamic jsonResponse =
            json.decode(response);

        if (jsonResponse is List) {
          List<Institution> loaded =
              new List<Institution>();

          for (dynamic item in jsonResponse) {
            if (item is Map) {
              loaded.add(
                Institution.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              );
            }
          }

          if (mounted) {
            setState(() {
              institutions = loaded;
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {
        loadingInstitutions = false;
      });
    }
  }

  Future<void> login() async {
    if (loggingIn) {
      return;
    }

    String username =
        usernameController.text.trim();

    String password =
        passwordController.text;

    if (username.isEmpty ||
        password.isEmpty) {
      showError(
        'Add meg a felhasználónevet és a jelszót.',
      );
      return;
    }

    if (selectedInstitution == null) {
      showError(
        'Válaszd ki az intézményt.',
      );
      return;
    }

    setState(() {
      loggingIn = true;
    });

    User user = new User(
      DateTime.now()
          .millisecondsSinceEpoch,
      username,
      password,
      username,
      selectedInstitution.code,
      selectedInstitution.url,
      selectedInstitution.name,
      '',
      '',
    );

    try {
      String token =
          await RequestHelper()
              .getBearerToken(
        user,
        true,
      );

      if (token == null ||
          token.isEmpty) {
        showError(
          'Sikertelen bejelentkezés. '
          'Ellenőrizd a felhasználónevet és a jelszót.',
        );
        return;
      }

      String studentString =
          await RequestHelper()
              .getStudentString(
        user,
        true,
      );

      if (studentString == null ||
          studentString.isEmpty) {
        showError(
          'A bejelentkezés sikerült, '
          'de a tanulói adatok nem tölthetők be.',
        );
        return;
      }

      try {
        Map studentJson =
            json.decode(studentString);

        if (studentJson != null) {
          String studentName =
              _getStudentName(studentJson);

          if (studentName != null &&
              studentName.isNotEmpty) {
            user.name = studentName;
          }
        }
      } catch (e) {
        print(e);
      }

      user.schoolCode =
          selectedInstitution.code;

      user.schoolUrl =
          selectedInstitution.url;

      user.schoolName =
          selectedInstitution.name;

      await AccountManager()
          .addUser(user);

      globals.users =
          await AccountManager()
              .getUsers();

      globals.selectedUser = user;
      globals.selectedSchoolCode =
          user.schoolCode;
      globals.selectedSchoolUrl =
          user.schoolUrl;
      globals.selectedSchoolName =
          user.schoolName;

      globals.isLoggedIn = true;
      globals.isSingle = true;
      globals.multiAccount = false;

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        new MaterialPageRoute(
          builder: (BuildContext context) =>
              new MainScreen(),
        ),
      );
    } catch (e) {
      print(e);

      showError(
        'Hiba történt a bejelentkezés közben.',
      );
    } finally {
      if (mounted) {
        setState(() {
          loggingIn = false;
        });
      }
    }
  }

  String _getStudentName(Map json) {
    dynamic value;

    value = json['Nev'];

    if (value == null) {
      value = json['nev'];
    }

    if (value == null) {
      value = json['Name'];
    }

    if (value == null) {
      value = json['name'];
    }

    if (value == null) {
      value = json['TanuloNev'];
    }

    if (value == null) {
      value = json['tanuloNev'];
    }

    if (value == null) {
      value = json['FullName'];
    }

    if (value == null) {
      value = json['fullName'];
    }

    if (value == null) {
      return null;
    }

    return value.toString();
  }

  void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    schoolController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Bejelentkezés',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: new EdgeInsets.all(20),
          child: new Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: <Widget>[
              new SizedBox(
                height: 30,
              ),

              new Icon(
                Icons.school,
                size: 80,
              ),

              new SizedBox(
                height: 20,
              ),

              new Text(
                'Ellenőrző',
                textAlign: TextAlign.center,
                style: new TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              new SizedBox(
                height: 30,
              ),

              new TextField(
                controller: usernameController,
                keyboardType:
                    TextInputType.text,
                decoration:
                    new InputDecoration(
                  labelText: 'Felhasználónév',
                  border:
                      new OutlineInputBorder(),
                ),
              ),

              new SizedBox(
                height: 16,
              ),

              new TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration:
                    new InputDecoration(
                  labelText: 'Jelszó',
                  border:
                      new OutlineInputBorder(),
                  suffixIcon:
                      new IconButton(
                    icon: new Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                            !obscurePassword;
                      });
                    },
                  ),
                ),
                onSubmitted: (_) {
                  login();
                },
              ),

              new SizedBox(
                height: 16,
              ),

              new InputDecorator(
                decoration:
                    new InputDecoration(
                  labelText: 'Intézmény',
                  border:
                      new OutlineInputBorder(),
                ),
                child:
                    loadingInstitutions
                        ? new Row(
                            children: <Widget>[
                              new SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    new CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              new SizedBox(
                                width: 12,
                              ),
                              new Text(
                                'Intézmények betöltése...',
                              ),
                            ],
                          )
                        : new DropdownButtonHideUnderline(
                            child:
                                new DropdownButton<Institution>(
                              isExpanded: true,
                              value:
                                  selectedInstitution,
                              hint: new Text(
                                'Válassz intézményt',
                              ),
                              items: institutions
                                  .map(
                                    (
                                      Institution institution,
                                    ) {
                                      return new DropdownMenuItem<
                                          Institution>(
                                        value:
                                            institution,
                                        child: new Text(
                                          institution.name ??
                                              institution.code ??
                                              '',
                                        ),
                                      );
                                    },
                                  )
                                  .toList(),
                              onChanged:
                                  (Institution value) {
                                setState(() {
                                  selectedInstitution =
                                      value;
                                });
                              },
                            ),
                          ),
              ),

              new SizedBox(
                height: 25,
              ),

              new SizedBox(
                height: 50,
                child: new RaisedButton(
                  onPressed:
                      loggingIn
                          ? null
                          : login,
                  child:
                      loggingIn
                          ? new CircularProgressIndicator(
                              valueColor:
                                  new AlwaysStoppedAnimation<
                                      Color>(
                                Colors.white,
                              ),
                            )
                          : new Text(
                              'BEJELENTKEZÉS',
                            ),
                ),
              ),

              new SizedBox(
                height: 15,
              ),

              new Text(
                'Az intézménylista az új KRÉTA API-ból töltődik be.',
                textAlign: TextAlign.center,
                style: new TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}