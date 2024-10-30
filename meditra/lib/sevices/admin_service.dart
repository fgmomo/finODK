import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


Future<Map<String, dynamic>?> recupererAdminConnecte() async {
  try {
    User? user = _auth.currentUser; // Obtenir l'utilisateur connecté
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('admin').doc(user.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    }
    return null; // Si aucun utilisateur n'est connecté ou que le document n'existe pas
  } catch (e) {
    throw Exception("Erreur lors de la récupération de l'admin connecté : $e");
  }
}

Future<void> ajouterAdmin(
      {required String email, required String password, required String nom, required String prenom}) async {
    try {
      // Créer l'utilisateur avec Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Ajouter les infos supplémentaires dans Firestore
      await _firestore.collection('admin').doc(userCredential.user?.uid).set({
        'firstName': nom,
        'lastName': prenom,
        'email': email,
        'isActive': true,
      });
    } catch (e) {
      throw Exception("Erreur lors de l'ajout de l'admin : $e");
    }
  }
  Future<void> desactiverAdmin(String uid) async {
    await _firestore.collection('admin').doc(uid).update({
      'isActive': false,
    });
  }

    Future<void> activerAdmin(String uid) async {
    await _firestore.collection('admin').doc(uid).update({
      'isActive': true,
    });
  }

  Future<List<Map<String, dynamic>>> recupererTousLesAdmins() async {
  QuerySnapshot snapshot = await _firestore.collection('admin').get();
  return snapshot.docs.map((doc) {
    var data = doc.data() as Map<String, dynamic>;
    data['reference'] = doc.id; // Ajouter l'ID du document à vos données
    return data;
  }).toList();
}


  
}