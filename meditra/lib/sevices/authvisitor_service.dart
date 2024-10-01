import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthVisitorService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 Future<UserCredential?> signUp(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return userCredential;
  } catch (e) {
    if (e is FirebaseAuthException) {
      if (e.code == 'email-already-in-use') {
        // Retourne un message spécifique au lieu d'une exception générique
        return Future.error('Cet email est déjà utilisé.');
      }
    }
    return Future.error('Erreur d\'inscription : $e');
  }
}

  Future<void> addVisitorToFirestore(String uid, String firstName, String lastName) async {
    try {
      await _firestore.collection('visiteurs').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': _auth.currentUser!.email, // Utiliser l'email du nouvel utilisateur
        'role': 'visiteur',
      });
    } catch (e) {
      print('Erreur lors de l\'ajout du visiteur à Firestore: $e');
    }
  }
}