import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';

import '../Datas/User.dart';
import '../Utils/Saver.dart';
import '../globals.dart' as globals;

class AccountManager {
  Future<List<User>> getUsers() async {
    List<Map<String, dynamic>> usersJson =
        new List();

    try {
      usersJson = await readUsers();
    } catch (e) {
      print(e);
    }

    List<User> users = new List();

    if (usersJson != null && usersJson.isNotEmpty) {
      for (Map<String, dynamic> json
          in usersJson) {
        users.add(
          User.fromJson(json),
        );
      }
    }

    List<Color> colors = <Color>[
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.black,
      Colors.brown,
      Colors.orange,
    ];

    int colorIndex = 0;

    for (User user in users) {
      if (user.color == null ||
          user.color.value == 0) {
        user.color =
            colors[colorIndex % colors.length];

        colorIndex++;
      }
    }

    return users;
  }

  Future<void> addUser(User user) async {
    try {
      List<User> users =
          await getUsers();

      for (User existingUser in users) {
        if (existingUser.id == user.id) {
          return;
        }
      }

      users.add(user);

      globals.users = users;

      await saveUsers(users);
    } catch (e) {
      print(e);

      List<User> users = new List();

      users.add(user);

      globals.users = users;

      await saveUsers(users);
    }
  }

  Future<void> removeUser(User user) async {
    List<User> users =
        await getUsers();

    List<User> newUsers = new List();

    for (User existingUser in users) {
      if (existingUser.id != user.id) {
        newUsers.add(existingUser);
      }
    }

    if (newUsers.length < 2) {
      globals.multiAccount = false;
    }

    globals.users = newUsers;

    await saveUsers(newUsers);
  }

  Future<void> removeUserIndex(
      int index) async {
    List<User> users =
        await getUsers();

    if (index < 0 ||
        index >= users.length) {
      return;
    }

    users.removeAt(index);

    globals.users = users;

    await saveUsers(users);
  }
}