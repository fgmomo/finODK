import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConsultationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fonction pour créer une nouvelle consultation
  Future<bool> hasExistingConsultation(
      String crenauId, String visiteurId) async {
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
  Future<void> createConsultation(
      String crenauId, String message, String visiteurId) async {
    // Création de la consultation avec l'ID du créneau, du message et du visiteur
    await FirebaseFirestore.instance.collection('consultations').add({
      'crenauId': crenauId,
      'message': message,
      'visiteurId': visiteurId,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'en attente'
    });
  }

  // Consultation en attente du praticien
  Future<List<Map<String, dynamic>>> fetchConsultations() async {
    List<Map<String, dynamic>> consultations = [];

    // Récupération de l'ID du praticien connecté via Firebase Auth
    String? praticienId = FirebaseAuth.instance.currentUser?.uid;

    if (praticienId == null) {
      print("Aucun utilisateur connecté.");
      return consultations; // Retourne une liste vide si aucun utilisateur n'est connecté
    }

    QuerySnapshot consultationsSnapshot =
        await FirebaseFirestore.instance.collection('consultations').get();

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
        DateTime dateDemande =
            (consultationData['createdAt'] as Timestamp).toDate();

        // Ajout des données à la liste
        consultations.add({
          'reference': doc.id,
          'visiteur':
              '${visiteurData['firstName']} ${visiteurData['lastName']}',
          'dateDemande': dateDemande, // Stocker la date comme DateTime
          'crenau': crenauData,
          'message': consultationData['message'], // Ajout du message
          'profileImageUrl': visiteurData['profileImageUrl'],
        });
      }
    }
    return consultations;
  }

  // Consultation approuvé du praticien
  Future<List<Map<String, dynamic>>> fetchConsultationsApp() async {
    List<Map<String, dynamic>> consultations = [];

    // Récupération de l'ID du praticien connecté via Firebase Auth
    String? praticienId = FirebaseAuth.instance.currentUser?.uid;

    if (praticienId == null) {
      print("Aucun utilisateur connecté.");
      return consultations; // Retourne une liste vide si aucun utilisateur n'est connecté
    }

    QuerySnapshot consultationsSnapshot =
        await FirebaseFirestore.instance.collection('consultations').get();

    for (var doc in consultationsSnapshot.docs) {
      var consultationData = doc.data() as Map<String, dynamic>;
      String crenauId = consultationData['crenauId'];

      // Vérifie que le statut de la consultation est "en attente"
      if (consultationData['status'] != 'approuvé') {
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
        DateTime dateDemande =
            (consultationData['createdAt'] as Timestamp).toDate();

        // Ajout des données à la liste
        consultations.add({
          'reference': doc.id,
          'visiteur':
              '${visiteurData['firstName']} ${visiteurData['lastName']}',
          'dateDemande': dateDemande, // Stocker la date comme DateTime
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
      var consultationData =
          consultationSnapshot.data() as Map<String, dynamic>;
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
        'lastMessage':
            'La consultation a été approuvée. Vous pouvez maintenant discuter.',
      });

      print('Consultation approuvée et discussion créée avec succès.');
    } catch (error) {
      // En cas d'erreur, on lève une exception
      throw Exception(
          'Erreur lors de l\'approbation et création de discussion : $error');
    }
  }

Future<void> rejectConsultation(String reference) async {  
      await FirebaseFirestore.instance
          .collection('consultations')
          .doc(reference)
          .update({'status': 'rejeté'});
  }



// Consultation en attente du visiteur
  Future<List<Map<String, dynamic>>> fetchConsultationsAttVisiteur() async {
    List<Map<String, dynamic>> consultations = [];

    // Récupération de l'ID du visiteur connecté via Firebase Auth
    String? visiteurId = FirebaseAuth.instance.currentUser?.uid;

    if (visiteurId == null) {
      print("Aucun utilisateur connecté.");
      return consultations; // Retourne une liste vide si aucun utilisateur n'est connecté
    }

    try {
      // Récupération des consultations où le visiteurId correspond à l'ID du visiteur connecté
      QuerySnapshot consultationsSnapshot = await FirebaseFirestore.instance
          .collection('consultations')
          .where('visiteurId',
              isEqualTo: visiteurId) // Filtre sur le visiteur connecté
          .where('status',
              isEqualTo:
                  'en attente') // Filtre sur les consultations "en attente"
          .get();

      for (var doc in consultationsSnapshot.docs) {
        var consultationData = doc.data() as Map<String, dynamic>;
        String crenauId = consultationData['crenauId'];

        // Récupération du créneau correspondant à la consultation
        DocumentSnapshot crenauSnapshot = await FirebaseFirestore.instance
            .collection('crenaux')
            .doc(crenauId)
            .get();
        var crenauData = crenauSnapshot.data() as Map<String, dynamic>;

        // Récupération des données du praticien associé au créneau
        String praticienId = crenauData['praticien_id'];
        DocumentSnapshot praticienSnapshot = await FirebaseFirestore.instance
            .collection('praticiens')
            .doc(praticienId)
            .get();
        var praticienData = praticienSnapshot.data() as Map<String, dynamic>;

        // Conversion du Timestamp en DateTime
        DateTime dateDemande =
            (consultationData['createdAt'] as Timestamp).toDate();

        // Ajout des données à la liste des consultations
        consultations.add({
          'reference': doc.id,
          'crenau': crenauData,
          'dateDemande': dateDemande, // Stocker la date comme DateTime
          'praticien':
              '${praticienData['firstName']} ${praticienData['lastName']}', // Ajout des données du praticien
          'profileImageUrl': praticienData['photoUrl'],
          'message': consultationData['message'], // Ajout du message
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des consultations : $e");
    }

    return consultations;
  }

// Consultation approuvée du visiteur
  Future<List<Map<String, dynamic>>> fetchConsultationsAppVisiteur() async {
    List<Map<String, dynamic>> consultations = [];

    // Récupération de l'ID du visiteur connecté via Firebase Auth
    String? visiteurId = FirebaseAuth.instance.currentUser?.uid;

    if (visiteurId == null) {
      print("Aucun utilisateur connecté.");
      return consultations; // Retourne une liste vide si aucun utilisateur n'est connecté
    }

    try {
      // Récupération des consultations où le visiteurId correspond à l'ID du visiteur connecté
      QuerySnapshot consultationsSnapshot = await FirebaseFirestore.instance
          .collection('consultations')
          .where('visiteurId',
              isEqualTo: visiteurId) // Filtre sur le visiteur connecté
          .where('status', isEqualTo: 'approuvé')
          .get();

      for (var doc in consultationsSnapshot.docs) {
        var consultationData = doc.data() as Map<String, dynamic>;
        String crenauId = consultationData['crenauId'];

        // Récupération du créneau correspondant à la consultation
        DocumentSnapshot crenauSnapshot = await FirebaseFirestore.instance
            .collection('crenaux')
            .doc(crenauId)
            .get();
        var crenauData = crenauSnapshot.data() as Map<String, dynamic>;

        // Récupération des données du praticien associé au créneau
        String praticienId = crenauData['praticien_id'];
        DocumentSnapshot praticienSnapshot = await FirebaseFirestore.instance
            .collection('praticiens')
            .doc(praticienId)
            .get();
        var praticienData = praticienSnapshot.data() as Map<String, dynamic>;

        // Conversion du Timestamp en DateTime
        DateTime dateDemande =
            (consultationData['createdAt'] as Timestamp).toDate();

        // Ajout des données à la liste des consultations
        consultations.add({
          'reference': doc.id,
          'crenau': crenauData,
          'dateDemande': dateDemande, // Stocker la date comme DateTime
          'praticien':
              '${praticienData['firstName']} ${praticienData['lastName']}', // Ajout des données du praticien
          'profileImageUrl': praticienData['photoUrl'],
          'message': consultationData['message'], // Ajout du message
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des consultations : $e");
    }

    return consultations;
  }

  // Récupérer la dernière consultation approuvée du visiteur
  Future<Map<String, dynamic>?> fetchDerniereConsultationAppVisiteur() async {
    // Récupération de l'ID du visiteur connecté via Firebase Auth
    String? visiteurId = FirebaseAuth.instance.currentUser?.uid;

    if (visiteurId == null) {
      print("Aucun utilisateur connecté.");
      return null; // Retourne null si aucun utilisateur n'est connecté
    }

    try {
      print("Récupération des consultations pour le visiteur : $visiteurId");
      // Récupération de la dernière consultation approuvée (limitée à 1)
      QuerySnapshot consultationsSnapshot = await FirebaseFirestore.instance
          .collection('consultations')
          .where('visiteurId',
              isEqualTo: visiteurId) // Filtre sur le visiteur connecté
          .where('status',
              isEqualTo: 'approuvé') // Filtre pour les consultations approuvées
          .orderBy('createdAt',
              descending:
                  true) // Trie par date décroissante (la plus récente en premier)
          .limit(1) // Limite à une seule consultation
          .get();

      if (consultationsSnapshot.docs.isNotEmpty) {
        var consultationDoc = consultationsSnapshot
            .docs.first; // On prend le premier (et unique) document
        print("Consultation trouvée : ${consultationDoc.id}");
        var consultationData = consultationDoc.data() as Map<String, dynamic>;
        String crenauId = consultationData['crenauId'];

        // Récupération du créneau correspondant à la consultation
        DocumentSnapshot crenauSnapshot = await FirebaseFirestore.instance
            .collection('crenaux')
            .doc(crenauId)
            .get();

        if (crenauSnapshot.exists) {
          var crenauData = crenauSnapshot.data() as Map<String, dynamic>;
          String praticienId = crenauData['praticien_id'];

          // Récupération des données du praticien associé au créneau
          DocumentSnapshot praticienSnapshot = await FirebaseFirestore.instance
              .collection('praticiens')
              .doc(praticienId)
              .get();

          if (praticienSnapshot.exists) {
            var praticienData =
                praticienSnapshot.data() as Map<String, dynamic>;

            // Conversion du Timestamp en DateTime
            // DateTime dateDemande = (consultationData['createdAt'] as Timestamp).toDate();

            // Retourne les informations de la dernière consultation
            return {
              'reference': consultationDoc.id,
              'crenau_heures':
                  '${crenauData['heure_debut']} - ${crenauData['heure_fin']}', // Données du créneau
              'crenau_date': crenauData['date'],
              // 'dateDemande': dateDemande, // Stocker la date comme DateTime
              'praticien':
                  '${praticienData['firstName']} ${praticienData['lastName']}', // Nom complet du praticien
              'profileImageUrl':
                  praticienData['photoUrl'], // URL de la photo du praticien
              'message': consultationData[
                  'message'], // Message associé à la consultation
            };
          } else {
            print("Praticien non trouvé.");
          }
        } else {
          print("Créneau non trouvé.");
        }
      } else {
        print("Aucune consultation approuvée trouvée.");
      }
    } catch (e) {
      print("Erreur lors de la récupération de la dernière consultation : $e");
    }

    return null; // Retourne null s'il n'y a pas de consultation approuvée
  }




Future<Map<String, dynamic>?> fetchDerniereConsultationAppPraticien() async {
  // Récupération de l'ID du praticien connecté via Firebase Auth
  String? praticienId = FirebaseAuth.instance.currentUser?.uid;

  if (praticienId == null) {
    print("Aucun praticien connecté.");
    return null; // Retourne null si aucun praticien n'est connecté
  }

  try {
    print("Récupération des créneaux pour le praticien : $praticienId");

    // Récupération des créneaux associés au praticien
    QuerySnapshot crenauxSnapshot = await FirebaseFirestore.instance
        .collection('crenaux')
        .where('praticien_id', isEqualTo: praticienId)
        .get();

    if (crenauxSnapshot.docs.isEmpty) {
      print("Aucun créneau associé trouvé pour ce praticien.");
      return null;
    }

    // Extraire les IDs de créneaux
    List<String> crenauIds = crenauxSnapshot.docs.map((doc) => doc.id).toList();

    // Récupérer la dernière consultation approuvée parmi ces créneaux
    QuerySnapshot consultationsSnapshot = await FirebaseFirestore.instance
        .collection('consultations')
        .where('crenauId', whereIn: crenauIds) // Filtrer par les IDs de créneaux associés
        .where('status', isEqualTo: 'approuvé') // Filtre pour les consultations approuvées
        .orderBy('createdAt', descending: true) // Trie par date décroissante
        .limit(1) // Limite à une seule consultation
        .get();

    if (consultationsSnapshot.docs.isNotEmpty) {
      var consultationDoc = consultationsSnapshot.docs.first;
      print("Consultation trouvée : ${consultationDoc.id}");
      var consultationData = consultationDoc.data() as Map<String, dynamic>;
      String crenauId = consultationData['crenauId'];
      String visiteurId = consultationData['visiteurId'];

      // Récupération des détails du créneau
      DocumentSnapshot crenauSnapshot = await FirebaseFirestore.instance
          .collection('crenaux')
          .doc(crenauId)
          .get();

      if (!crenauSnapshot.exists) {
        print("Créneau non trouvé.");
        return null;
      }

      var crenauData = crenauSnapshot.data() as Map<String, dynamic>;

      // Récupération des informations du visiteur
      DocumentSnapshot visiteurSnapshot = await FirebaseFirestore.instance
          .collection('visiteurs')
          .doc(visiteurId)
          .get();

      String visiteurNom = '';
      String visiteurPrenom = '';
      String visiteurPhotoUrl = '';

      if (visiteurSnapshot.exists) {
        var visiteurData = visiteurSnapshot.data() as Map<String, dynamic>;
        visiteurNom = visiteurData['lastName'];
        visiteurPrenom = visiteurData['firstName'];
        visiteurPhotoUrl = visiteurData['profileImageUrl'];
      } else {
        print("Visiteur non trouvé.");
      }

      // Retourne les informations de la dernière consultation
      return {
        'reference': consultationDoc.id,
        'crenau_date': crenauData['date'],
        'crenau_heures': '${crenauData['heure_debut']} - ${crenauData['heure_fin']}',
        'message': consultationData['message'],
        'visiteur_nom': visiteurNom,
        'visiteur_prenom': visiteurPrenom,
        'visiteur_photo': visiteurPhotoUrl,
      };
    } else {
      print("Aucune consultation approuvée trouvée pour ces créneaux.");
    }
  } catch (e) {
    print("Erreur lors de la récupération de la dernière consultation : $e");
  }

  return null; // Retourne null s'il n'y a pas de consultation approuvée
}





// Consultation rejetée du visiteur
  Future<List<Map<String, dynamic>>> fetchConsultationsRejVisiteur() async {
    List<Map<String, dynamic>> consultations = [];

    // Récupération de l'ID du visiteur connecté via Firebase Auth
    String? visiteurId = FirebaseAuth.instance.currentUser?.uid;

    if (visiteurId == null) {
      print("Aucun utilisateur connecté.");
      return consultations; // Retourne une liste vide si aucun utilisateur n'est connecté
    }

    try {
      // Récupération des consultations où le visiteurId correspond à l'ID du visiteur connecté
      QuerySnapshot consultationsSnapshot = await FirebaseFirestore.instance
          .collection('consultations')
          .where('visiteurId',
              isEqualTo: visiteurId) // Filtre sur le visiteur connecté
          .where('status', isEqualTo: 'rejeté')
          .get();

      for (var doc in consultationsSnapshot.docs) {
        var consultationData = doc.data() as Map<String, dynamic>;
        String crenauId = consultationData['crenauId'];

        // Récupération du créneau correspondant à la consultation
        DocumentSnapshot crenauSnapshot = await FirebaseFirestore.instance
            .collection('crenaux')
            .doc(crenauId)
            .get();
        var crenauData = crenauSnapshot.data() as Map<String, dynamic>;

        // Récupération des données du praticien associé au créneau
        String praticienId = crenauData['praticien_id'];
        DocumentSnapshot praticienSnapshot = await FirebaseFirestore.instance
            .collection('praticiens')
            .doc(praticienId)
            .get();
        var praticienData = praticienSnapshot.data() as Map<String, dynamic>;

        // Conversion du Timestamp en DateTime
        DateTime dateDemande =
            (consultationData['createdAt'] as Timestamp).toDate();

        // Ajout des données à la liste des consultations
        consultations.add({
          'reference': doc.id,
          'crenau': crenauData,
          'dateDemande': dateDemande, // Stocker la date comme DateTime
          'praticien':
              '${praticienData['firstName']} ${praticienData['lastName']}', // Ajout des données du praticien
          'profileImageUrl': praticienData['photoUrl'],
          'message': consultationData['message'], // Ajout du message
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des consultations : $e");
    }

    return consultations;
  }
}
