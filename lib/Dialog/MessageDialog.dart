import 'package:e_szivacs/Datas/Message.dart';
import 'package:e_szivacs/Helpers/MessageHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';

import '../generated/i18n.dart';
import '../globals.dart' as globals;

class MessageDialog extends StatefulWidget {
  const MessageDialog(this.message);

  final Message message;

  @override
  MessageDialogState createState() =>
      new MessageDialogState();
}

class MessageDialogState extends State<MessageDialog> {
  Message currentMessage;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    currentMessage = widget.message;

    _loadMessage();
  }

  Future<void> _loadMessage() async {
    /*
     * Először megpróbáljuk a lokális cache-ből
     * betölteni a teljes üzenetet.
     */
    try {
      Message offlineMessage =
          await MessageHelper()
              .getMessageByIdOffline(
                  globals.selectedAccount.user,
                  currentMessage.id);

      if (offlineMessage != null &&
          mounted) {
        setState(() {
          currentMessage = offlineMessage;
        });
      }
    } catch (e) {
      print(e);
    }

    /*
     * Ezután lekérjük a szerverről a teljes
     * üzenetet.
     *
     * Az új API:
     *
     * GET
     * /integration-kretamobile-api/v1/
     * kommunikacio/postaladaelemek/{azonosito}
     */
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    try {
      Message onlineMessage =
          await MessageHelper()
              .getMessageById(
                  globals.selectedAccount.user,
                  currentMessage.id);

      if (onlineMessage != null &&
          mounted) {
        setState(() {
          currentMessage = onlineMessage;
        });
      }
    } catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String subject =
        currentMessage.subject ?? "";

    String text =
        currentMessage.text ?? "";

    List<String> receivers =
        currentMessage.receivers ?? new List<String>();

    String senderName =
        currentMessage.senderName ?? "";

    return new SimpleDialog(
      title: new Text(subject),
      titlePadding: EdgeInsets.all(15),
      contentPadding:
          const EdgeInsets.all(15.0),
      children: <Widget>[
        if (loading)
          Container(
            height: 2,
            child:
                new LinearProgressIndicator(
              value: null,
            ),
          ),

        Container(
          child: Text(
            S.of(context).receivers +
                receivers.join(", "),
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),

        SizedBox(height: 12),

        Container(
          child: new Html(
            data: HtmlUnescape()
                .convert(text),
          ),
        ),

        SizedBox(height: 12),

        Container(
          child: Text(
            senderName,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}