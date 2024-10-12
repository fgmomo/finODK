import 'package:cloud_firestore/cloud_firestore.dart';

class Maladie {
  final String nom;
  final String description;
 

  Maladie({
    required this.nom,
    required this.description,

  });

  // Méthode pour convertir un Maladie en Map
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'description': description,
   
    };
  }

  // Méthode pour créer un Maladie à partir d'un DocumentSnapshot
  factory Maladie.fromDocument(DocumentSnapshot doc) {
    return Maladie(
      nom: doc['nom'],
      description: doc['description'],
    );
  }
}

class MaladieService {
  final CollectionReference maladiesCollection =
      FirebaseFirestore.instance.collection('maladies');

  // Ajouter un remède
  Future<void> addMaladie(String nom, String description) {
    return maladiesCollection.add({
      'nom': nom,
      'description': description,
    });
  }

  // Supprimer un remède
  Future<void> deleteMaladie(String MaladieId) {
    return maladiesCollection.doc(MaladieId).delete();
  }

  // Mettre à jour un remède
  Future<void> updateMaladie(DocumentReference docRef, Maladie Maladie) async {
    await docRef.update(Maladie.toMap());
  }

  // Récupérer tous les remèdes
  Stream<QuerySnapshot> getMaladies() {
    return maladiesCollection.snapshots(); 
  }
}
