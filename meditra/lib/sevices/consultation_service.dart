import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fonction pour créer une nouvelle consultation
   Future<bool> hasExistingConsultation(String crenauId, String visiteurId) async {
    // Requête pour vérifier si une consultation existe déjà pour le créneau et le visiteur
    // Exemple avec Firestore :
    final snapshot = await FirebaseFirestore.instance
        .collection('consultations')
        .where('crenauId', isEqualTo: crenauId)
        .where('visiteurId', isEqualTo: visiteurId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> createConsultation(String crenauId, String message, String visiteurId) async {
    // Création de la consultation avec l'ID du créneau, du message et du visiteur
    await FirebaseFirestore.instance.collection('consultations').add({
      'crenauId': crenauId,
      'message': message,
      'visiteurId': visiteurId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Fonction pour récupérer les consultations (si nécessaire)
  Stream<List<Map<String, dynamic>>> getConsultations() {
    return _firestore.collection('consultations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}
