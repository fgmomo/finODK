import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class RegisterPraticienService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> registerPraticien({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String address,
    required String professionalNumber,
    required String justification,
    required File photo,
    required File justificatif,
  }) async {
    // Vérification des champs
    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty || address.isEmpty || professionalNumber.isEmpty) {
      return "Tous les champs doivent être remplis.";
    }

    // Créer l'utilisateur
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Stocker les photos dans Firebase Storage
      String photoUrl = await _uploadFile(photo);
      String justificatifUrl = await _uploadFile(justificatif);

      // Enregistrer les données de l'utilisateur dans Firestore
      await _firestore.collection('praticiens').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'address': address,
        'professionalNumber': professionalNumber,
        'justification': justification,
        'photoUrl': photoUrl,
        'justificatifUrl': justificatifUrl,
        'status': 'en attente', // Statut par défaut
        'email': email,
        'role': 'praticien',
        'isActive':true,
      });

      return "Inscription réussie ! Un email de confirmation a été envoyé.";
    } catch (e) {
      return "Une erreur est survenue : $e";
    }
  }

  Future<String> _uploadFile(File file) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child('uploads/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL(); // Retourner l'URL du fichier téléchargé
  }
}
