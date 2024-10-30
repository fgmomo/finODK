import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FullNameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


Future<Map<String, dynamic>?> recupererPraticienConnecte() async {
  try {
    User? user = _auth.currentUser; // Obtenir l'utilisateur connecté
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('praticiens').doc(user.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    }
    return null; // Si aucun utilisateur n'est connecté ou que le document n'existe pas
  } catch (e) {
    throw Exception("Erreur lors de la récupération du praticien connecté : $e");
  }
}


Future<Map<String, dynamic>?> recupererVisiteurConnecte() async {
  try {
    User? user = _auth.currentUser; // Obtenir l'utilisateur connecté
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('visiteurs').doc(user.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    }
    return null; // Si aucun utilisateur n'est connecté ou que le document n'existe pas
  } catch (e) {
    throw Exception("Erreur lors de la récupération du visiteur connecté : $e");
  }
}
}