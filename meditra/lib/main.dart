import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import pour kIsWeb
import 'package:meditra/FirebaseOptions.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/authadmin_service.dart';
import 'package:meditra/views/admin_home/layouts/main_layout.dart';
import 'package:meditra/views/auth/login_screen.dart'; // Page de login mobile (praticien/visiteur)
import 'package:meditra/views/auth/login_screen_admin.dart'; // Page de login pour admin (web)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    // Créer une instance du service Admin
  AuthAdminService adminService = AuthAdminService();
  
  // Appel de la méthode pour créer un admin par défaut
  await adminService.createDefaultAdmin();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Backoffice Flutter',
      theme: ThemeData(
        // Modifier la couleur primaire et d'autres propriétés
        primaryColor: couleurPrincipale, // Couleur principale
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: couleurPrincipale, // Couleur principale
          secondary: couleurSecondaire, // Couleur secondaire pour les actions
        ),
        // Modifier la couleur du loader et du ripple effect
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: couleurPrincipale, // Couleur du CircularProgressIndicator
        ),
        // Modifier la couleur du focus des inputs
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey), // Bordure lorsqu'il n'est pas focus
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: couleurPrincipale), // Bordure verte lors du focus
          ),
        ),
      ),
      home: _getInitialPage(), // Logique pour rediriger vers la bonne page de login
    );
  }

  // Fonction pour rediriger vers la page de login correcte selon la plateforme
  Widget _getInitialPage() {
    if (kIsWeb) {
      // Si on est sur le web, rediriger vers la page de login pour admin
      return LoginScreenAdmin();
      // return MainLayout();
    } else {
      // Sinon, rediriger vers la page de login mobile (praticien/visiteur)
      return LoginScreen();
      //  return MainLayout();
    }
  }
}
