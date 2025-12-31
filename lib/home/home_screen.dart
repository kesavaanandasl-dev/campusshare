import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Share"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          "Welcome to Campus Share 🎓",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
