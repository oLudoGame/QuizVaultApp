import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text("Entrar"),
          ElevatedButton.icon(
            onPressed: () {
              FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
            },
            icon: const Icon(Icons.g_mobiledata_rounded),
            label: const Text("Entrar com Google"),
          )
        ],
      ),
    );
  }
}
