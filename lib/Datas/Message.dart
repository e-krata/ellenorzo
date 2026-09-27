class Message {
  int id;
  int messageId;
  bool seen;
  DateTime date;
  String senderName;
  String senderType;
  String text;
  String subject;
  List<String> receivers;
  List<String> attachments;

  Message.fromJson(Map json) {
    if (json == null) {
      receivers = <String>[];
      attachments = <String>[];
      return;
    }

    final Map message = json["uzenet"] is Map
        ? json["uzenet"]
        : json;

    id = _intValue(
      json["azonosito"] ?? json["id"] ?? json["Uid"],
    );

    messageId = _intValue(
      json["uzenet"] is Map
          ? json["uzenet"]["azonosito"] ??
              json["uzenet"]["id"] ??
              json["uzenet"]["Uid"]
          : json["messageId"] ??
              json["MessageId"] ??
              json["azonosito"] ??
              json["id"] ??
              json["Uid"],
    );

    seen = _boolValue(
      json["isElolvasva"] ??
          json["seen"] ??
          json["Seen"] ??
          json["IsRead"],
    );

    date = _dateValue(
      message["kuldesDatum"] ??
          message["date"] ??
          message["Date"] ??
          json["kuldesDatum"] ??
          json["date"] ??
          json["Date"],
    );

    senderName = _stringValue(
      message["feladoNev"] ??
          message["senderName"] ??
          message["SenderName"],
    );

    senderType = _stringValue(
      message["feladoTitulus"] ??
          message["senderType"] ??
          message["SenderType"],
    );

    text = _stringValue(
      message["szoveg"] ??
          message["text"] ??
          message["Text"],
    );

    subject = _stringValue(
      message["targy"] ??
          message["subject"] ??
          message["Subject"],
    );

    receivers = <String>[];

    final dynamic receiverList =
        message["cimzettLista"] ??
            message["receivers"] ??
            message["Receivers"];

    if (receiverList is List) {
      for (final dynamic receiver in receiverList) {
        if (receiver is Map) {
          receivers.add(
            _stringValue(
              receiver["nev"] ??
                  receiver["name"] ??
                  receiver["Name"],
            ),
          );
        } else if (receiver != null) {
          receivers.add(
            receiver.toString(),
          );
        }
      }
    }

    attachments = <String>[];

    final dynamic attachmentList =
        message["csatolmanyok"] ??
            message["attachments"] ??
            message["Attachments"];

    if (attachmentList is List) {
      for (final dynamic attachment in attachmentList) {
        if (attachment is Map) {
          attachments.add(
            _stringValue(
              attachment["fajlNev"] ??
                  attachment["fileName"] ??
                  attachment["FileName"] ??
                  attachment["nev"] ??
                  attachment["Name"],
            ),
          );
        } else if (attachment != null) {
          attachments.add(
            attachment.toString(),
          );
        }
      }
    }
  }

  static int _intValue(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static bool _boolValue(dynamic value) {
    if (value == null) {
      return false;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final String stringValue =
        value.toString().toLowerCase();

    return stringValue == "true" ||
        stringValue == "1" ||
        stringValue == "yes";
  }

  static String _stringValue(dynamic value) {
    if (value == null) {
      return "";
    }

    return value.toString();
  }

  static DateTime _dateValue(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }
}