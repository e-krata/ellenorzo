import 'dart:async';
import 'dart:convert' show json;

import 'package:e_szivacs/Helpers/RequestHelper.dart';

import '../Datas/Message.dart';
import '../Datas/User.dart';
import '../Helpers/DBHelper.dart';

class MessageHelper {
  Future<List<Message>> getMessages(User user, bool showErrors) async {
    List<Message> messages = new List();

    try {
      String code =
          await RequestHelper().getBearerToken(user, showErrors);

      String messageString = await RequestHelper().getMessages(
          code, user.schoolCode);

      if (messageString == null || messageString.isEmpty)
        return messages;

      var messagesJson = json.decode(messageString);

      if (messagesJson is! List)
        return messages;

      await DBHelper().addMessagesJson(messagesJson, user);

      for (var messageElement in messagesJson) {
        if (messageElement is Map &&
            messageElement["uzenet"] != null) {
          Message message = Message.fromJson(messageElement);
          messages.add(message);
        }
      }

      messages.sort(
          (Message a, Message b) => b.date.compareTo(a.date));
    } catch (e) {
      print(e);
    }

    return messages;
  }

  Future<List<Message>> getMessagesOffline(User user) async {
    List<Message> messages = new List();

    try {
      List messagesJson =
          await DBHelper().getMessagesJson(user);

      if (messagesJson == null)
        return messages;

      for (var messageElement in messagesJson) {
        if (messageElement is Map &&
            messageElement["uzenet"] != null) {
          Message message = Message.fromJson(messageElement);
          messages.add(message);
        }
      }

      messages.sort(
          (Message a, Message b) => b.date.compareTo(a.date));
    } catch (e) {
      print(e);
    }

    return messages;
  }

  Future<Message> getMessageById(User user, int id) async {
    Message message;

    try {
      String code =
          await RequestHelper().getBearerToken(user, true);

      String messageString =
          await RequestHelper().getMessageById(
              id, code, user.schoolCode);

      if (messageString == null || messageString.isEmpty)
        return null;

      var messageJson = json.decode(messageString);

      if (messageJson is! Map)
        return null;

      await DBHelper().addMessageByIdJson(
          id, messageJson, user);

      message = Message.fromJson(messageJson);
    } catch (e) {
      print(e);
    }

    return message;
  }

  Future<Message> getMessageByIdOffline(
      User user, int id) async {
    Message message;

    try {
      Map<String, dynamic> messageJson =
          await DBHelper().getMessageByIdJson(id, user);

      if (messageJson == null)
        return null;

      message = Message.fromJson(messageJson);
    } catch (e) {
      print(e);
    }

    return message;
  }
}
