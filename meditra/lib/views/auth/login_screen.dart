import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:meditra/config/config.dart';
import 'package:meditra/views/auth/registerpraticien_screen.dart';
import 'package:meditra/views/auth/registervisitor_screen.dart';
import 'package:meditra/views/home/Accueil.dart';
import 'package:meditra/views/home_praticien/Accueil.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String errorMessage = '';
  bool isLoading = false; // Pour gérer l'état de chargement

  @override
  void initState() {
    super.initState();
    // Vérification de l'état de l'utilisateur lors du démarrage
    checkUserLoggedIn();
  }

  Future<void> checkUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // L'utilisateur est déjà connecté
      await navigateToHome(user);
    }
  }

Future<void> navigateToHome(User user) async {
  // Vérification dans la collection "visiteurs"
  DocumentSnapshot visitorDoc = await FirebaseFirestore.instance
      .collection('visiteurs')
      .doc(user.uid)
      .get();

  if (visitorDoc.exists) {
    bool isActive = visitorDoc.get('isActive');

    if (isActive) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AccueilVisitorHomeScreen()),
      );
    } else {
      setState(() {
        errorMessage = "Votre compte de visiteur est désactivé.";
        isLoading = false; // Arrêter le chargement
      });
    }
    return;
  }
  // Vérification dans la collection "praticiens"
  DocumentSnapshot praticienDoc = await FirebaseFirestore.instance
      .collection('praticiens')
      .doc(user.uid)
      .get();

  if (praticienDoc.exists) {
    // Récupérer les informations de statut et d'activation
    String status = praticienDoc.get('status');
    bool isActive = praticienDoc.get('isActive');

    // Vérifier si le praticien est approuvé et actif
    if (status == "approuvé" && isActive) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AccueilPraticienHomeScreen()),
      );
      setState(() {
        isLoading = false; // Arrêter le chargement
      });
    } else if (status == "en attente") {
      setState(() {
        errorMessage = "Vos informations sont en attente de vérification.";
        isLoading = false; // Arrêter le chargement
      });
    } else if (!isActive) {
      setState(() {
        errorMessage = "Votre compte est désactivé.";
        isLoading = false; // Arrêter le chargement
      });
    }
    else {
      // Cas où le statut est inconnu
      setState(() {
        errorMessage = "Statut du compte inconnu. Veuillez contacter le support.";
        isLoading = false; // Arrêter le chargement
      });
    }
    return;
  }

  // Dans le cas où aucun document correspondant n'est trouvé
  setState(() {
    errorMessage = "Compte non trouvé.";
    isLoading = false; // Arrêter le chargement
  });
}

  Future<void> login() async {
    setState(() {
      errorMessage = '';
      isLoading = true; // Commence le chargement
    });

    // Vérification des champs vides
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'Veuillez remplir tous les champs.';
        isLoading = false; // Arrête le chargement
      });
      return;
    }

    try {
      // Authentification avec Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        await navigateToHome(user);
      }
    } catch (e) {
      print(e);
      setState(() {
        if (e is FirebaseAuthException) {
          if (e.code == 'user-not-found' || e.code == 'wrong-password') {
            errorMessage = 'Email ou mot de passe incorrect.';
          } else if (e.code == 'invalid-credential') {
            errorMessage = 'Les informations d\'identification sont invalides.';
          } else {
            errorMessage = 'Erreur: ${e.code}';
          }
        } else {
          errorMessage = 'Une erreur inattendue s\'est produite.';
        }
        isLoading = false; // Arrête le chargement
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              if (errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.redAccent,
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              // Ajout du logo en haut du formulaire
              Center(
                child: Image.asset(
                  'assets/yiri2.png',
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 10),

              SizedBox(height: 15),
              Center(
                child: Text(
                  'Connectez-vous',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: policeLato,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(fontFamily: policePoppins),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  labelStyle: TextStyle(fontFamily: policePoppins),
                  border: OutlineInputBorder(),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Logique de mot de passe oublié
                  },
                  child: Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                        color: Colors.blue[700], fontFamily: policePoppins),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? LoadingAnimationWidget.horizontalRotatingDots(
                          color: couleurPrincipale,
                          size: 30,
                        )
                      : Text(
                          'Connexion',
                          style: TextStyle(
                            fontFamily: policePoppins,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VisitorSignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "S'inscrire en tant que visiteur",
                      style: TextStyle(
                        color: couleurPrincipale,
                        fontFamily: policePoppins,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPraticienScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "S'inscrire en tant que praticien",
                      style: TextStyle(
                        color: couleurPrincipale,
                        fontFamily: policePoppins,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
