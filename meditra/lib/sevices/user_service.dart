import 'package:cloud_firestore/cloud_firestore.dart';

class VisiteurService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> desactiverVisiteur(String uid) async {
    await _firestore.collection('visiteurs').doc(uid).update({
      'isActive': false,
    });
  }

    Future<void> activerVisiteur(String uid) async {
    await _firestore.collection('visiteurs').doc(uid).update({
      'isActive': true,
    });
  }

  Future<List<Map<String, dynamic>>> recupererTousLesVisiteurs() async {
  QuerySnapshot snapshot = await _firestore.collection('visiteurs').get();
  return snapshot.docs.map((doc) {
    var data = doc.data() as Map<String, dynamic>;
    data['reference'] = doc.id; // Ajouter l'ID du document à vos données
    return data;
  }).toList();
}


  
}