import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

// Consultation en attente
  Future<void> createConsultation(String crenauId, String message, String visiteurId) async {
    // Création de la consultation avec l'ID du créneau, du message et du visiteur
    await FirebaseFirestore.instance.collection('consultations').add({
      'crenauId': crenauId,
      'message': message,
      'visiteurId': visiteurId,
      'createdAt': FieldValue.serverTimestamp(),
       'status': 'en attente'
    });
  }
   Future<List<Map<String, dynamic>>> fetchConsultations() async {
    List<Map<String, dynamic>> consultations = [];

    // Récupération de l'ID du praticien connecté via Firebase Auth
    String? praticienId = FirebaseAuth.instance.currentUser?.uid;

    if (praticienId == null) {
      print("Aucun utilisateur connecté.");
      return consultations; // Retourne une liste vide si aucun utilisateur n'est connecté
    }

    QuerySnapshot consultationsSnapshot = await FirebaseFirestore.instance
        .collection('consultations')
        .get();

    for (var doc in consultationsSnapshot.docs) {
      var consultationData = doc.data() as Map<String, dynamic>;
      String crenauId = consultationData['crenauId'];

 // Vérifie que le statut de la consultation est "en attente"
    if (consultationData['status'] != 'en attente') {
      continue; // Passe à l'itération suivante si le statut n'est pas "en attente"
    }

      // Récupération du créneau
      DocumentSnapshot crenauSnapshot = await FirebaseFirestore.instance
          .collection('crenaux')
          .doc(crenauId)
          .get();
      var crenauData = crenauSnapshot.data() as Map<String, dynamic>;

      // Vérification que le créneau correspond au praticien connecté
      if (crenauData['praticien_id'] == praticienId) {
        String visiteurId = consultationData['visiteurId'];

        // Récupération des données du visiteur
        DocumentSnapshot visiteurSnapshot = await FirebaseFirestore.instance
            .collection('visiteurs')
            .doc(visiteurId)
            .get();
        var visiteurData = visiteurSnapshot.data() as Map<String, dynamic>;

        // Conversion du Timestamp en DateTime
        DateTime dateDemande = (consultationData['createdAt'] as Timestamp).toDate();

        // Ajout des données à la liste
        consultations.add({
          'reference': doc.id,
          'visiteur': '${visiteurData['firstName']} ${visiteurData['lastName']}',
          'dateDemande': dateDemande,  // Stocker la date comme DateTime
          'crenau': crenauData,
          'message': consultationData['message'], // Ajout du message
          'profileImageUrl': visiteurData['profileImageUrl'], 
        });
      }
    }
    return consultations;
  }
  // Fonction pour récupérer les consultations (si nécessaire)
  Stream<List<Map<String, dynamic>>> getConsultations() {
    return _firestore.collection('consultations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

Future<void> approveConsultation(String reference) async {
  try {
    // 1. Mettre à jour le statut de la consultation à "approuvé"
    await FirebaseFirestore.instance
        .collection('consultations')
        .doc(reference)
        .update({'status': 'approuvé'});

    // 2. Récupérer les informations de la consultation (crenauId et visiteurId)
    DocumentSnapshot consultationSnapshot = await FirebaseFirestore.instance
        .collection('consultations')
        .doc(reference)
        .get();
    var consultationData = consultationSnapshot.data() as Map<String, dynamic>;
    String crenauId = consultationData['crenauId'];
    String visiteurId = consultationData['visiteurId'];

    // 3. Récupérer l'ID du praticien à partir du créneau
    DocumentSnapshot crenauSnapshot = await FirebaseFirestore.instance
        .collection('crenaux')
        .doc(crenauId)
        .get();
    var crenauData = crenauSnapshot.data() as Map<String, dynamic>;
    String praticienId = crenauData['praticien_id'];

    // 4. Créer une nouvelle discussion dans Firestore
    await FirebaseFirestore.instance.collection('discussions').add({
      'praticienId': praticienId,
      'visiteurId': visiteurId,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': 'La consultation a été approuvée. Vous pouvez maintenant discuter.',
    });

    print('Consultation approuvée et discussion créée avec succès.');
  } catch (error) {
    // En cas d'erreur, on lève une exception
    throw Exception('Erreur lors de l\'approbation et création de discussion : $error');
  }
}



}
