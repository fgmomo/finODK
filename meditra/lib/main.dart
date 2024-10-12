import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import pour kIsWeb
import 'package:meditra/FirebaseOptions.dart';
import 'package:meditra/views/admin_home/layouts/main_layout.dart';
import 'package:meditra/views/auth/login_screen.dart'; // Page de login mobile (praticien/visiteur)
import 'package:meditra/views/auth/login_screen_admin.dart'; // Page de login pour admin (web)

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
      home: _getInitialPage(), // Logique pour rediriger vers la bonne page de login
    );
  }

  // Fonction pour rediriger vers la page de login correcte selon la plateforme
  Widget _getInitialPage() {
    if (kIsWeb) {
      // Si on est sur le web, rediriger vers la page de login pour admin
      // return LoginScreenAdmin();
      return MainLayout();
    } else {
      // Sinon, rediriger vers la page de login mobile (praticien/visiteur)
      return LoginScreen();
      //  return MainLayout();
    }
  }
}
