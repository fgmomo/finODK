import 'package:cloud_firestore/cloud_firestore.dart';

class CentreService {
  // Méthode pour ajouter un centre avec des données dynamiques
  Future<void> ajouterCentrePharmacopee({
    required String nom,
    required String adresse,
    required String telephone,
    required String description,
    String? email,
    String? siteWeb,
    required double latitude,
    required double longitude,
    String? image,
  }) async {
    CollectionReference centres =
        FirebaseFirestore.instance.collection('centres');

    // Les données à insérer sans imbrication
    await centres.add({
      'nom': nom,
      'adresse': adresse,
      'telephone': telephone,
      'description': description,
      'siteWeb': siteWeb,
      'email': email,
      'localisation': GeoPoint(latitude, longitude), // Utilisation de GeoPoint
      'image': image,
    }).then((value) {
      print("Centre ajouté avec succès");
    }).catchError((error) {
      print("Erreur lors de l'ajout du centre: $error");
    });
  }

  // Fonction pour mettre à jour un centre existant
  Future<void> mettreAJourCentrePharmacopee({
    required DocumentReference centreRef,
    required String nom,
    required String adresse,
    required String telephone,
    required String email,
    required String siteWeb,
    required double latitude,
    required double longitude,
    required String description,
    required String image,
  }) async {
    try {
      await centreRef.update({
        'nom': nom,
        'adresse': adresse,
        'telephone': telephone,
        'email': email,
        'siteWeb': siteWeb,
         'localisation': GeoPoint(latitude, longitude), // Utilisation de GeoPoint
        'description': description,
        'image': image,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour: $e');
      throw Exception('Erreur lors de la mise à jour du centre.');
    }
  }

  // Méthode pour récupérer tous les centres de pharmacopée
  Future<List<Map<String, dynamic>>> recupererCentresPharmacopee() async {
    CollectionReference centres =
        FirebaseFirestore.instance.collection('centres');

    // Récupérer les données sous forme de snapshot
    QuerySnapshot querySnapshot = await centres.get();

    // Parcourir les documents et les transformer en liste de Map
    List<Map<String, dynamic>> centresList = querySnapshot.docs.map((doc) {
      return {
        ...doc.data() as Map<String, dynamic>,
        'reference': doc.reference, // Ajouter la référence du document
      };
    }).toList();

    return centresList;
  }

  Future<void> deleteCentre(DocumentReference centreRef) async {
    try {
      await centreRef.delete(); // Suppression dans Firestore
    } catch (e) {
      print('Erreur lors de la suppression : $e');
    }
  }
}
