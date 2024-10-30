import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/authadmin_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meditra/views/admin_home/layouts/main_layout.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreenAdmin extends StatefulWidget {
  @override
  _LoginScreenAdminState createState() => _LoginScreenAdminState();
}

class _LoginScreenAdminState extends State<LoginScreenAdmin> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;
  String errorMessage = '';
  final authAdminService = AuthAdminService();

  Future<void> login() async {
  setState(() {
    isLoading = true;
    errorMessage = '';
  });

  User? user = await authAdminService.loginAdmin(
    emailController.text,
    passwordController.text,
  );

  setState(() {
    isLoading = false;
  });

  if (user != null) {
    // Vérifie si l'utilisateur admin est actif
    final adminDoc = await FirebaseFirestore.instance
        .collection('admin')
        .doc(user.uid)
        .get();

    if (adminDoc.exists && adminDoc.data()!['isActive'] == true) {
      // Si l'administrateur est actif, redirige vers la page principale
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainLayout()),
      );
    } else {
      // Si l'administrateur n'est pas actif, affiche un message d'erreur
      setState(() {
        errorMessage = 'Compte admin inactif. Contactez l\'administrateur.';
      });
    }
  } else {
    setState(() {
      errorMessage = 'Email ou mot de passe incorrect, ou non-admin';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/back.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: isSmallScreen ? screenWidth * 0.9 : 800,
                height: isSmallScreen ? null : 450,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (!isSmallScreen)
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            image: DecorationImage(
                              image: AssetImage('assets/pra.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Container pour garder de l'espace pour le message d'erreur
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              margin: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: errorMessage.isNotEmpty ? Colors.redAccent : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                errorMessage.isNotEmpty ? errorMessage : '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              "Connexion Admin",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: passwordController,
                              obscureText: !isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                border: OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // Logique de mot de passe oublié
                                },
                                child: Text(
                                  'Mot de passe oublié ?',
                                  style: TextStyle(
                                    color: couleurPrincipale,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : login, // Désactive le bouton si en chargement
                                child: isLoading
                                    ? LoadingAnimationWidget.progressiveDots(
                                        color: Colors.white, // Couleur de l'animation
                                        size: 20, // Taille de l'animation
                                      )
                                    : Text(
                                        "Connexion",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmallScreen ? 15 : 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: couleurPrincipale,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
