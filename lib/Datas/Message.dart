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
    if (json == null)
      return;

    /*
     * Az új API struktúrája:
     *
     * {
     *   "azonosito": 1001,
     *   "isElolvasva": false,
     *   "uzenet": {
     *     "azonosito": 50001,
     *     "kuldesDatum": "...",
     *     "feladoNev": "...",
     *     "feladoTitulus": "...",
     *     "szoveg": "...",
     *     "targy": "...",
     *     "cimzettLista": [...],
     *     "csatolmanyok": [...]
     *   }
     * }
     */

    id = _toInt(json["azonosito"]);

    seen = json["isElolvasva"] == true;

    Map message = json["uzenet"];

    if (message == null) {
      /*
       * Biztonsági fallback a régebbi JSON formátumhoz.
       */
      message = json;
    }

    messageId = _toInt(message["azonosito"]);

    date = _parseDate(
      message["kuldesDatum"] ??
          message["date"] ??
          message["Date"],
    );

    senderName =
        message["feladoNev"] ??
        message["senderName"] ??
        "";

    senderType =
        message["feladoTitulus"] ??
        message["senderType"] ??
        "";

    text =
        message["szoveg"] ??
        message["text"] ??
        "";

    subject =
        message["targy"] ??
        message["subject"] ??
        "";

    receivers = new List<String>();

    var receiverList =
        message["cimzettLista"] ??
        message["receivers"];

    if (receiverList is List) {
      for (var receiver in receiverList) {
        if (receiver is Map) {
          if (receiver["nev"] != null)
            receivers.add(
                receiver["nev"].toString());
        } else if (receiver != null) {
          receivers.add(receiver.toString());
        }
      }
    }

    attachments = new List<String>();

    var attachmentList =
        message["csatolmanyok"] ??
        message["attachments"];

    if (attachmentList is List) {
      for (var attachment in attachmentList) {
        if (attachment is Map) {
          if (attachment["fajlNev"] != null)
            attachments.add(
                attachment["fajlNev"].toString());
        } else if (attachment != null) {
          attachments.add(
              attachment.toString());
        }
      }
    }
  }

  static int _toInt(dynamic value) {
    if (value == null)
      return null;

    if (value is int)
      return value;

    return int.tryParse(value.toString());
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null)
      return null;

    if (value is DateTime)
      return value;

    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }
}