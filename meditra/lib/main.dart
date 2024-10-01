import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meditra/FirebaseOptions.dart';
import 'package:meditra/views/auth/login_screen.dart'; // Import de la page de login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Backoffice Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // Définit la page de login comme page d'accueil
    );
  }
}
