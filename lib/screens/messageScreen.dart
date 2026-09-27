import 'dart:async';

import 'package:e_szivacs/Datas/Message.dart';
import 'package:e_szivacs/Dialog/MessageDialog.dart';
import 'package:e_szivacs/Helpers/RequestHelper.dart';
import 'package:flutter/material.dart';

import '../GlobalDrawer.dart';
import '../Utils/StringFormatter.dart';
import '../generated/i18n.dart';
import '../globals.dart' as globals;

void main() {
  runApp(new MaterialApp(home: new MessageScreen()));
}

class MessageScreen extends StatefulWidget {
  @override
  MessageScreenState createState() =>
      new MessageScreenState();
}

class MessageScreenState extends State<MessageScreen> {
  @override
  void initState() {
    super.initState();
    _onRefresh(showErrors: false);
  }

  List<Message> get messages =>
      globals.selectedAccount.messages;

  bool hasOfflineLoaded = true;
  bool hasLoaded = true;

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () {
        globals.screen = 0;
        Navigator.pushReplacementNamed(
            context, "/main");
      },
      child: Scaffold(
        drawer: GDrawer(),
        appBar: new AppBar(
          title: new Text(
            S.of(context).messages,
          ),
          actions: <Widget>[],
        ),
        body: new Container(
          child: hasOfflineLoaded &&
                  (messages != null)
              ? new Column(
                  children: <Widget>[
                    !hasLoaded
                        ? Container(
                            child:
                                new LinearProgressIndicator(
                              value: null,
                            ),
                            height: 3,
                          )
                        : Container(
                            height: 3,
                          ),
                    new Expanded(
                      child: new RefreshIndicator(
                        child: new ListView.builder(
                          itemBuilder: _itemBuilder,
                          itemCount: messages.length,
                        ),
                        onRefresh: _onRefresh,
                      ),
                    ),
                  ],
                )
              : new Center(
                  child:
                      new CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }

  Future<Null> _onRefresh(
      {bool showErrors = true}) async {
    setState(() {
      hasLoaded = false;
    });

    Completer<Null> completer =
        new Completer<Null>();

    await globals.selectedAccount
        .refreshStudentString(false, showErrors);

    hasLoaded = true;

    if (mounted) {
      setState(() {
        completer.complete();
      });
    }

    return completer.future;
  }

  Widget _itemBuilder(
      BuildContext context, int index) {
    Widget sep = new Container();

    Message message = messages[index];

    return new Column(
      children: <Widget>[
        sep,
        new Divider(
          height: index != 0 ? 2.0 : 0.0,
        ),
        new ListTile(
          title: new Text(
            message.subject ?? "",
            style: TextStyle(
              fontWeight: !message.seen
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          subtitle: new Text(
            message.senderName ?? "",
            style: TextStyle(
              fontWeight: !message.seen
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          trailing: new Column(
            children: <Widget>[
              new Text(
                message.date != null
                    ? dateToHuman(message.date)
                    : "",
                style: TextStyle(
                  fontWeight: !message.seen
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              new Text(
                message.date != null
                    ? dateToWeekDay(message.date)
                    : "",
                style: TextStyle(
                  fontWeight: !message.seen
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
          onTap: () async {
            /*
             * Az új API-nál az olvasottnak jelöléshez
             * a postafiók-elem külső azonosítója kell:
             *
             * POST
             * /integration-kretamobile-api/v1/
             * kommunikacio/uzenetek/olvasott
             *
             * {
             *   "isOlvasott": true,
             *   "uzenetAzonositoLista": [id]
             * }
             */
            if (!message.seen) {
              setState(() {
                message.seen = true;
              });

              try {
                String token =
                    await RequestHelper()
                        .getBearerToken(
                            globals.selectedAccount.user,
                            false);

                if (token != null) {
                  await RequestHelper()
                      .markMessagesAsRead(
                    token,
                    <int>[message.id],
                  );
                }
              } catch (e) {
                print(e);
              }
            }

            return showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder:
                      (BuildContext context) {
                    return new MessageDialog(
                        message);
                  },
                ) ??
                false;
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}