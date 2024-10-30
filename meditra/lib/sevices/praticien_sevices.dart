import 'package:cloud_firestore/cloud_firestore.dart';

class PraticienService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> recupererTousLesPraticiens() async {
  QuerySnapshot snapshot = await _firestore.collection('praticiens').get();
  return snapshot.docs.map((doc) {
    var data = doc.data() as Map<String, dynamic>;
    data['reference'] = doc.id; // Ajouter l'ID du document à vos données
    return data;
  }).toList();
}


 Future<void> desactiverPraticien(String uid) async {
    await _firestore.collection('praticiens').doc(uid).update({
      'isActive': false,
    });
  }

    Future<void> activerPraticien(String uid) async {
    await _firestore.collection('praticiens').doc(uid).update({
      'isActive': true,
    });
  }

   // Méthode pour approuver un praticien
  Future<void> approuverPraticien(String praticienRef) async {
    await _firestore.collection('praticiens').doc(praticienRef).update({
      'status': 'approuvé',
    });
  }

     // Méthode pour approuver un praticien
  Future<void> rejeterPraticien(String praticienRef) async {
    await _firestore.collection('praticiens').doc(praticienRef).update({
      'status': 'rejeté',
    });
  }

  
}