import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/sevices/authvisitor_service.dart';

class VisitorSignUpScreen extends StatefulWidget {
  @override
  _VisitorSignUpScreenState createState() => _VisitorSignUpScreenState();
}

class _VisitorSignUpScreenState extends State<VisitorSignUpScreen> {
  final AuthVisitorService _authService = AuthVisitorService();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? errorMessage;
  String? successMessage;
  bool isLoading = false; // Variable pour gérer l'état de chargement

  void signUp() async {
  setState(() {
    isLoading = true;
  });

  String firstName = firstNameController.text.trim();
  String lastName = lastNameController.text.trim();
  String email = emailController.text.trim();
  String password = passwordController.text.trim();
  String confirmPassword = confirmPasswordController.text.trim();

  if (firstName.isEmpty ||
      lastName.isEmpty ||
      email.isEmpty ||
      password.isEmpty ||
      confirmPassword.isEmpty) {
    setState(() {
      errorMessage = 'Veuillez remplir tous les champs.';
      successMessage = null;
      isLoading = false;
    });
    return;
  }

  if (password != confirmPassword) {
    setState(() {
      errorMessage = 'Les mots de passe ne correspondent pas.';
      successMessage = null;
      isLoading = false;
    });
    return;
  }

  try {
    UserCredential? userCredential = await _authService.signUp(email, password);

    if (userCredential != null) {
      await _authService.addVisitorToFirestore(userCredential.user!.uid, firstName, lastName);

      setState(() {
        successMessage = 'Vous vous êtes inscrit avec succès !';
        errorMessage = null;
        isLoading = false;
      });
      showSuccessDialog();
    }
  } catch (e) {
    setState(() {
      // Ici on affiche directement le message d'erreur spécifique à l'email
      errorMessage = e.toString();
      successMessage = null;
      isLoading = false;
    });
  }
}

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                padding: EdgeInsets.all(16),
                child: Icon(
                  Icons.check,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Inscription réussie',
                style: TextStyle(
                  fontFamily: policePoppins,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: couleurPrincipale,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Merci pour votre inscription ! Vous avez maintenant accès à la plateforme et pouvez commencer à explorer les remèdes et traitements traditionnels.',
                style: TextStyle(
                  fontFamily: policePoppins,
                  fontSize: 15,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                },
                child: Text(
                  'Fermer',
                  style: TextStyle(
                    fontFamily: policePoppins,
                    color: couleurPrincipale,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  Text(
                    'Inscription',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                      color: couleurPrincipale,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Remplissez les informations ci-dessous',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),

                  if (successMessage != null)
                    Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.greenAccent,
                      child: Text(
                        successMessage!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                  if (errorMessage != null)
                    Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.redAccent,
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                  SizedBox(height: 20),

                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirmez le mot de passe',
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: signUp,
                      child: Text(
                        "S'inscrire",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: couleurPrincipale,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Déjà inscrit ? Connectez-vous',
                        style: TextStyle(
                          color: couleurPrincipale,
                          fontFamily: 'Poppins',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: couleurPrincipale,
              ),
            ),
        ],
      ),
    );
  }
}
