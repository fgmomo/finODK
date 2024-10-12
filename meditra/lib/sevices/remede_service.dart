import 'package:cloud_firestore/cloud_firestore.dart';

class Remede {
  final String nom;
  final String description;
  final String image;
  final String utilisation;
  final String dosage;
  final String precaution;

  Remede({
    required this.nom,
    required this.description,
    required this.image,
    required this.utilisation,
    required this.dosage,
    required this.precaution,
  });

  // Méthode pour convertir un Remede en Map
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'description': description,
      'image': image,
      'utilisation': utilisation,
      'dosage': dosage,
      'precaution': precaution,
    };
  }

  // Méthode pour créer un Remede à partir d'un DocumentSnapshot
  factory Remede.fromDocument(DocumentSnapshot doc) {
    return Remede(
      nom: doc['nom'],
      description: doc['description'],
      image: doc['image'],
      utilisation: doc['utilisation'],
      dosage: doc['dosage'],
      precaution: doc['precaution'],
    );
  }
}

class RemedeService {
  final CollectionReference remedesCollection =
      FirebaseFirestore.instance.collection('remedes');

  // Ajouter un remède
  Future<void> addRemede(String nom, String description, String image, String utilisation, String dosage, String precaution) {
    return remedesCollection.add({
      'nom': nom,
      'description': description,
      'image': image,
      'utilisation': utilisation,
      'dosage': dosage,
      'precaution': precaution, // Ajout du champ précaution
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Supprimer un remède
  Future<void> deleteRemede(String remedeId) {
    return remedesCollection.doc(remedeId).delete();
  }

  // Mettre à jour un remède
  Future<void> updateRemede(DocumentReference docRef, Remede remede) async {
    await docRef.update(remede.toMap());
  }

  // Récupérer tous les remèdes
  Stream<QuerySnapshot> getRemedes() {
    return remedesCollection.snapshots(); 
  }
}
