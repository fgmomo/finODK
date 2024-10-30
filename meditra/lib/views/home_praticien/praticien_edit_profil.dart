import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditra/config/config.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:meditra/views/home_praticien/praticien_profil.dart';


class PraticienEditProfilScreen extends StatefulWidget {
  const PraticienEditProfilScreen({super.key});

  @override
  State<PraticienEditProfilScreen> createState() =>
      _PraticienEditProfilScreenState();
}

class _PraticienEditProfilScreenState extends State<PraticienEditProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String currentPassword = '';
  String newPassword = '';
  String confirmNewPassword = '';
  String email = '';
  String firstname = '';
  String lastname = '';
  String errorMessage = '';
  String successMessage = '';
  File? profileImage; // Variable pour stocker l'image de profil

  bool isLoading = false; // État de chargement

  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker(); // Instance de l'image picker

  @override
  void initState() {
    super.initState();
    _loadCurrentUserInfo();
  }

  Future<void> _loadCurrentUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot visitorDoc = await FirebaseFirestore.instance
          .collection('praticiens')
          .doc(user.uid)
          .get();

      if (visitorDoc.exists) {
        Map<String, dynamic>? visitorData =
            visitorDoc.data() as Map<String, dynamic>?;
        if (visitorData != null) {
          setState(() {
            email = user.email ?? '';
            firstname = visitorData['firstName'] ?? '';
            lastname = visitorData['lastName'] ?? '';
             firstname = visitorData['firstName'] ?? '';
            lastname = visitorData['lastName'] ?? '';
            emailController.text = email;
            firstnameController.text = firstname;
            lastnameController.text = lastname;
          });
        }
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Démarre l'animation de chargement
      });
      User? user = FirebaseAuth.instance.currentUser;

      try {
        await user!.reauthenticateWithCredential(
          EmailAuthProvider.credential(
              email: user.email!, password: currentPasswordController.text),
        );

        if (newPasswordController.text.isNotEmpty) {
          await user.updatePassword(newPasswordController.text);
        }

        String? imageUrl;
        if (profileImage != null) {
          // Téléchargez l'image sur Firebase Storage
          final ref = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${user.uid}.jpg');

          // Téléchargez le fichier
          await ref.putFile(profileImage!);
          
          // Récupérez l'URL de téléchargement
          imageUrl = await ref.getDownloadURL();
        }

        // Mise à jour des données Firestore
        await FirebaseFirestore.instance
            .collection('praticiens')
            .doc(user.uid)
            .update({
          'email': emailController.text,
          'firstName': firstnameController.text,
          'lastName': lastnameController.text,
          if (imageUrl != null) 'photoUrl': imageUrl, // Ajoutez l'URL de l'image
        });

        setState(() {
          // successMessage = 'Profil mis à jour';
          errorMessage = '';
          isLoading = false; // Arrête l'animation de chargement
        });

        currentPasswordController.clear();
        newPasswordController.clear();
        confirmNewPasswordController.clear();

        // Affiche le modal de succès
        _showSuccessModal();
      } catch (e) {
        setState(() {
          errorMessage =
              'Erreur lors de la mise à jour du profil. Veuillez vérifier vos informations et réessayer.';
          successMessage = '';
          isLoading = false; // Arrête l'animation de chargement
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

 void _showSuccessModal() {
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
              'Profil mis à jour avec succès',
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
              'Votre profil a été mis à jour avec succès. Vous pouvez maintenant continuer à utiliser l\'application.',
              style: TextStyle(
                fontFamily: policePoppins,
                fontSize: 15,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20), // Espace avant le bouton
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Ferme le modal
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PraticienProfilScreen(), // Remplacez par votre écran de profil
                ),
              );
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
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Modifier Profil',
          style: TextStyle(
            color: Colors.black,
            fontFamily: policeLato,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.black,
            height: 0.2,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.redAccent,
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              if (successMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.green,
                  child: Text(
                    successMessage,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

              // Affichage de l'image de profil
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                           : AssetImage('assets/prof.jpg'),
                    child: profileImage == null
                        ? Icon(Icons.camera_alt, color: couleurPrincipale)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(fontFamily: policePoppins),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: firstnameController,
                      decoration: InputDecoration(
                        labelText: 'Prénom',
                        labelStyle: TextStyle(fontFamily: policePoppins),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Veuillez entrer votre prénom';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: lastnameController,
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        labelStyle: TextStyle(fontFamily: policePoppins),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: currentPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe actuel',
                        labelStyle: TextStyle(fontFamily: policePoppins),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Veuillez entrer votre mot de passe actuel';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Nouveau mot de passe',
                        labelStyle: TextStyle(fontFamily: policePoppins),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: confirmNewPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirmer le nouveau mot de passe',
                        labelStyle: TextStyle(fontFamily: policePoppins),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != newPasswordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: couleurPrincipale, // Couleur de fond personnalisée
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Arrondi des coins
                        ),
                      ),
                      onPressed: isLoading ? null : _updateProfile,
                      child: isLoading
                          ? LoadingAnimationWidget.horizontalRotatingDots(
                              color: Colors.white,
                              size: 30,
                            )
                          : Text(
                              'Mettre à jour mon profil',
                              style: TextStyle(
                                fontFamily: policePoppins,
                                color: Colors.white, // Couleur du texte
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
