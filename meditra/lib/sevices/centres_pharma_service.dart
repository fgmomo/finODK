import 'package:cloud_firestore/cloud_firestore.dart';

class CentreService {
  // Méthode pour ajouter un centre avec des données dynamiques
  Future<void> ajouterCentrePharmacopee({
    required String nom,
    required String adresse,
    required String telephone,
     required String description,
    required double latitude,
    required double longitude,
    String? image,
  }) async {
    CollectionReference centres = FirebaseFirestore.instance.collection('centres');

    // Les données à insérer sans imbrication
    await centres.add({
      'nom': nom,
      'adresse': adresse,
      'telephone': telephone,
      'description':description,
       'localisation': {
      'latitude': 14.6928,
      'longitude': -17.4467,
    },
      'image': image,
    }).then((value) {
      print("Centre ajouté avec succès");
    }).catchError((error) {
      print("Erreur lors de l'ajout du centre: $error");
    });
  }

  // Méthode pour récupérer tous les centres de pharmacopée
  Future<List<Map<String, dynamic>>> recupererCentresPharmacopee() async {
    CollectionReference centres = FirebaseFirestore.instance.collection('centres');

    // Récupérer les données sous forme de snapshot
    QuerySnapshot querySnapshot = await centres.get();
    // Parcourir les documents et les transformer en liste de Map
    List<Map<String, dynamic>> centresList = querySnapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();

    return centresList;
  }
}
