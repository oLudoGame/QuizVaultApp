import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:quizz_vault_app/models/qz_user.dart';

class UsersProvider extends ChangeNotifier {
  List<QzUser> users = [];
  bool loading = true;

  UsersProvider() {
    Stream<List<QzUser>> stream =
        FirebaseDatabase.instance.ref('users').onValue.map((event) {
      final Map? data = event.snapshot.value as Map?;
      if (data == null) {
        return [];
      }
      return data.entries
          .map((entry) => QzUser.fromJson(entry.value))
          .toList();
    });

    stream.listen((newUsers) {
      users = newUsers;
      loading = false;
      notifyListeners();
    });
  }
}
