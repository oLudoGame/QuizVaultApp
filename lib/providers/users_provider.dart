import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizz_vault_app/models/qz_user.dart';

class UsersProvider extends ChangeNotifier {
  List<QzUser> users = [];
  bool loading = true;

  UsersProvider() {
    // Stream para acompanhar alterações em tempo real na coleção "users"
    FirebaseFirestore.instance.collection('users').snapshots().listen((snapshot) {
      users = snapshot.docs.map((doc) {
        QzUser user = QzUser.fromJson(doc.data());
        user.id = doc.id; // Atribui o ID do documento ao modelo, se necessário
        return user;
      }).toList();

      loading = false;
      notifyListeners();
    });
  }
}
