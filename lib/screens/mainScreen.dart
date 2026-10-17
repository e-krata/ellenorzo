import 'dart:async';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:e_szivacs/Cards/TomorrowLessonCard.dart';
import 'package:e_szivacs/Dialog/TOSDialog.dart';
import 'package:e_szivacs/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Cards/SummaryCards.dart';
import '../Cards/AbsenceCard.dart';
import '../Cards/ChangedLessonCard.dart';
import '../Cards/EvaluationCard.dart';
import '../Cards/LessonCard.dart';
import '../Cards/NoteCard.dart';
import '../Datas/Account.dart';
import '../Datas/Lesson.dart';
import '../Datas/Note.dart';
import '../Datas/Student.dart';
import '../GlobalDrawer.dart';
import '../Helpers/BackgroundHelper.dart';
import '../Helpers/SettingsHelper.dart';
import '../Helpers/TimetableHelper.dart';
import '../globals.dart' as globals;
import 'evaluationsScreen.dart';
import 'timeTableScreen.dart';
import 'absentsScreen.dart';
import 'settingsScreen.dart';

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => new MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  static const Color _primary = Color(0xFF247CFF);
  static const Color _bg = Color(0xFFF4F6FB);
  static const Color _cardBg = Colors.white;

  List mainScreenCards;

  List<Evaluation> evaluations = new List();
  Map<String, List<Absence>> absents = new Map();
  List<Note> notes = new List();
  List<Lesson> lessons = new List();

  DateTime get now => DateTime.now();

  DateTime startDate;

  bool hasOfflineLoaded = false;
  bool hasLoaded = true;

  int _bottomIndex = 0;

  void _initSettings() async {
    try {
      DynamicTheme.of(context).setBrightness(
          await SettingsHelper().getDarkTheme()
              ? Brightness.dark
              : Brightness.light);
    } catch (e) {}

    try {
      BackgroundHelper().configure();
    } catch (e) {}

    globals.color1 = await SettingsHelper().getEvalColor(0);
    globals.color2 = await SettingsHelper().getEvalColor(1);
    globals.color3 = await SettingsHelper().getEvalColor(2);
    globals.color4 = await SettingsHelper().getEvalColor(3);
    globals.color5 = await SettingsHelper().getEvalColor(4);

    globals.colorF1 =
        globals.color1.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
    globals.colorF2 =
        globals.color2.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
    globals.colorF3 =
        globals.color3.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
    globals.colorF4 =
        globals.color4.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
    globals.colorF5 =
        globals.color5.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
  }

  Future<bool> showBlockDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new SimpleDialog(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Az app az ÚjKréta API-t használja.",
              ),
            ),
            new MaterialButton(
              child: Text("Értem"),
              onPressed: () {
                SettingsHelper().setAcceptBlock(true);
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initSettings();
    _onRefresh(offline: true, showErrors: false).then((_) async {
      mainScreenCards = await feedItems();
      if (mounted) setState(() {});
      _onRefresh(offline: false, showErrors: false).then((_) async {
        mainScreenCards = await feedItems();
        if (mounted) setState(() {});
      });
    });
  }

  bool firstQuarterCard = false;
  bool halfYearCard = false;
  bool thirdQuarterCard = false;
  bool endYearCard = false;

  Future<List<Widget>> feedItems() async {
    int maximumFeedLength = 100;
    List<Widget> feedCards = new List();

    List<Evaluation> firstQuarterEvaluations = (evaluations
            .where((Evaluation evaluation) => evaluation.isFirstQuarter()))
        .toList();
    List<Evaluation> halfYearEvaluations = (evaluations
            .where((Evaluation evaluation) => evaluation.isHalfYear()))
        .toList();
    List<Evaluation> thirdQuarterEvaluations = (evaluations
            .where((Evaluation evaluation) => evaluation.isThirdQuarter()))
        .toList();
    List<Evaluation> endYearEvaluations = (evaluations
            .where((Evaluation evaluation) => evaluation.isEndYear()))
        .toList();

    // Filc-szerű szekciócím
    feedCards.add(_sectionHeader("Friss események"));

    for (String day in absents.keys.toList())
      feedCards.add(_wrapCard(
          new AbsenceCard(absents[day], globals.isSingle, context)));
    for (Evaluation evaluation in evaluations
        .where((Evaluation evaluation) => !evaluation.isSummaryEvaluation()))
      feedCards.add(_wrapCard(new EvaluationCard(
          evaluation, globals.isColor, globals.isSingle, context)));
    for (Note note in notes)
      feedCards
          .add(_wrapCard(new NoteCard(note, globals.isSingle, context)));
    for (Lesson l in lessons.where((Lesson lesson) =>
        (lesson.isMissed || lesson.isSubstitution) &&
        lesson.date.isAfter(now)))
      feedCards.add(_wrapCard(ChangedLessonCard(l, context)));

    if (firstQuarterEvaluations.isNotEmpty)
      feedCards.add(_wrapCard(new SummaryCard(
          firstQuarterEvaluations, context, "Első negyedévi jegyek", false, true)));
    if (halfYearEvaluations.isNotEmpty)
      feedCards.add(_wrapCard(new SummaryCard(
          halfYearEvaluations, context, "Félévi jegyek", false, true)));
    if (thirdQuarterEvaluations.isNotEmpty)
      feedCards.add(_wrapCard(new SummaryCard(
          thirdQuarterEvaluations, context, "Harmadik negyedévi jegyek", false, true)));
    if (endYearEvaluations.isNotEmpty)
      feedCards.add(_wrapCard(new SummaryCard(
          endYearEvaluations, context, "Év végi jegyek", false, true)));

    List realLessons = lessons.where((Lesson l) => !l.isMissed).toList();
    bool isLessonsToday = false;

    for (Lesson l in realLessons) {
      if (l.start.isAfter(now) && l.start.day == now.day) {
        isLessonsToday = true;
        break;
      }
    }

    if (realLessons.length > 0 && isLessonsToday) {
      feedCards.add(_sectionHeader("Mai órák"));
      feedCards.add(_wrapCard(new LessonCard(realLessons, context, now)));
    }

    try {
      feedCards.sort((Widget a, Widget b) {
        return 0;
      });
    } catch (e) {}

    try {
      bool isLessonsTomorrow = false;
      for (Lesson l in realLessons) {
        if (l.start.day == now.add(Duration(days: 1)).day) {
          isLessonsTomorrow = true;
          break;
        }
      }
      if (isLessonsTomorrow) {
        feedCards.add(_sectionHeader("Holnapi órák"));
        feedCards
            .add(_wrapCard(new TomorrowLessonCard(realLessons, context, now)));
      }
    } catch (e) {}

    if (maximumFeedLength > feedCards.length)
      maximumFeedLength = feedCards.length;

    if (feedCards.isEmpty) {
      feedCards.add(
        Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: <Widget>[
              Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
              SizedBox(height: 12),
              Text(
                "Még nincsenek megjelenítendő adatok.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return feedCards.sublist(0, maximumFeedLength);
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1D26),
        ),
      ),
    );
  }

  Widget _wrapCard(Widget child) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (BuildContext context) {
            return new AlertDialog(
              title: new Text(S.of(context).sure),
              content: new Text(S.of(context).confirm_close),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text(S.of(context).no),
                ),
                new FlatButton(
                  onPressed: () async {
                    await SystemChannels.platform
                        .invokeMethod<void>('SystemNavigator.pop');
                  },
                  child: new Text(S.of(context).yes),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  String _greeting() {
    final int h = now.hour;
    if (h < 11) return "Jó reggelt!";
    if (h < 18) return "Szép napot!";
    return "Jó estét!";
  }

  String _userName() {
    try {
      if (globals.selectedAccount != null &&
          globals.selectedAccount.user != null &&
          globals.selectedAccount.user.name != null) {
        return globals.selectedAccount.user.name;
      }
      if (globals.selectedUser != null && globals.selectedUser.name != null) {
        return globals.selectedUser.name;
      }
    } catch (e) {}
    return "Diák";
  }

  void _onBottomTap(int index) {
    if (index == 0) {
      setState(() {
        _bottomIndex = 0;
      });
      return;
    }

    Widget page;
    if (index == 1) {
      page = EvaluationsScreen();
    } else if (index == 2) {
      page = TimeTableScreen();
    } else if (index == 3) {
      page = AbsentsScreen();
    } else {
      page = SettingsScreen();
    }

    Navigator.of(context)
        .push(
      MaterialPageRoute(builder: (BuildContext context) => page),
    )
        .then((_) {
      if (mounted) {
        setState(() {
          _bottomIndex = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: _bg,
        drawer: GDrawer(),
        body: Column(
          children: <Widget>[
            // Filc-szerű fejléc
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                right: 16,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Color(0xFF247CFF),
                    Color(0xFF3D8BFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Builder(
                        builder: (BuildContext ctx) {
                          return IconButton(
                            icon: Icon(Icons.menu, color: Colors.white),
                            onPressed: () {
                              Scaffold.of(ctx).openDrawer();
                            },
                          );
                        },
                      ),
                      Expanded(
                        child: Text(
                          "Ellenőrző",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.white),
                        onPressed: () async {
                          await _onRefresh(offline: false, showErrors: true);
                          mainScreenCards = await feedItems();
                          if (mounted) setState(() {});
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Text(
                      _greeting(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 2, 16, 0),
                    child: Text(
                      _userName(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            !hasLoaded
                ? Container(
                    height: 3,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(_primary),
                    ),
                  )
                : SizedBox(height: 3),
            Expanded(
              child: hasOfflineLoaded &&
                      globals.isColor != null &&
                      mainScreenCards != null
                  ? RefreshIndicator(
                      color: _primary,
                      child: ListView(
                        padding: EdgeInsets.only(top: 8, bottom: 24),
                        children: mainScreenCards,
                      ),
                      onRefresh: () async {
                        await _onRefresh(offline: false, showErrors: true);
                        mainScreenCards = await feedItems();
                        if (mounted) setState(() {});
                      },
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(_primary),
                      ),
                    ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _bottomIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: _primary,
          unselectedItemColor: Colors.grey[500],
          backgroundColor: Colors.white,
          elevation: 8,
          onTap: _onBottomTap,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              title: Text("Kezdőlap"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grade_outlined),
              activeIcon: Icon(Icons.grade),
              title: Text("Jegyek"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              title: Text("Órarend"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_busy_outlined),
              activeIcon: Icon(Icons.event_busy),
              title: Text("Hiányzás"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              activeIcon: Icon(Icons.more_horiz),
              title: Text("Egyéb"),
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> _onRefresh({
    bool offline = false,
    bool showErrors = true,
  }) async {
    List<Evaluation> tempEvaluations = new List();
    Map<String, List<Absence>> tempAbsents = new Map();
    List<Note> tempNotes = new List();

    try {
      setState(() {
        if (offline)
          hasOfflineLoaded = false;
        else
          hasLoaded = false;
      });
    } catch (e) {}

    if (globals.isSingle) {
      try {
        await globals.selectedAccount.refreshStudentString(offline, showErrors);
        tempEvaluations.addAll(globals.selectedAccount.student.Evaluations);
        tempNotes.addAll(globals.selectedAccount.notes);
        tempAbsents.addAll(globals.selectedAccount.absents);
      } catch (exception) {
        if (showErrors) {
          Fluttertoast.showToast(
            msg: "Hiba",
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        print(exception);
      }
    } else {
      for (Account account in globals.accounts) {
        try {
          try {
            await account.refreshStudentString(offline, showErrors);
          } catch (e) {
            print("HIBA 2");
            print(e);
          }
          tempEvaluations.addAll(account.student.Evaluations);
          tempNotes.addAll(account.notes);
          tempAbsents.addAll(account.absents);
        } catch (exception) {
          print(exception);
        }
      }
    }

    if (tempEvaluations.length > 0) evaluations = tempEvaluations;
    if (tempAbsents.length > 0) absents = tempAbsents;
    if (tempNotes.length > 0) notes = tempNotes;

    startDate = now;

    if (offline) {
      if (globals.lessons.length > 0) {
        lessons = new List();
        lessons.addAll(globals.lessons);
      } else {
        try {
          lessons = await getLessonsOffline(
            startDate,
            startDate.add(Duration(days: 6)),
            globals.selectedUser,
          );
        } catch (exception) {
          print(exception);
        }
        if (lessons.length > 0) globals.lessons.addAll(lessons);
      }
    } else {
      try {
        lessons = await getLessons(
          startDate,
          startDate.add(Duration(days: 6)),
          globals.selectedUser,
          showErrors,
        );
      } catch (exception) {
        print(exception);
      }
    }

    try {
      lessons.sort((Lesson a, Lesson b) => a.start.compareTo(b.start));
      if (lessons.length > 0) globals.lessons = lessons;
    } catch (e) {
      print(e);
    }

    Completer<Null> completer = new Completer<Null>();
    if (!offline) hasLoaded = true;

    hasOfflineLoaded = true;
    if (mounted) {
      setState(() {
        completer.complete();
      });
    }
    return completer.future;
  }

  @override
  void dispose() {
    super.dispose();
  }
}