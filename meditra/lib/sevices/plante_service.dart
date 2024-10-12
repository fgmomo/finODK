// plante_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Plante {
  final String nom;
  final String nomLocal;
  final String description;
  final String bienfaits;
  final String imageUrl;
 final DocumentReference<Object?>? reference; 

  Plante({
    required this.nom,
    required this.nomLocal,
    required this.description,
    required this.bienfaits,
    required this.imageUrl,
      this.reference,
  });

  // Méthode pour convertir une plante en Map
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'nom_local': nomLocal,
      'description': description,
      'bienfaits': bienfaits,
      'image': imageUrl,
    };
  }

  // Factory pour créer une plante à partir d'un document Firestore
  factory Plante.fromDocument(DocumentSnapshot doc) {
    return Plante(
      nom: doc['nom'],
      nomLocal: doc['nom_local'],
      description: doc['description'],
      bienfaits: doc['bienfaits'],
      imageUrl: doc['image'],
      reference: doc.reference,
    );
  }
}

class PlanteService {
   final CollectionReference _planteCollection =
      FirebaseFirestore.instance.collection('plantes');
  // Méthode pour récupérer les plantes depuis Firestore
   Future<List<Plante>> fetchPlantes() async {
    final QuerySnapshot snapshot = await _planteCollection.get();

    return snapshot.docs.map((DocumentSnapshot doc) {
      return Plante.fromDocument(doc); 
    }).toList();
  }

  // Méthode pour ajouter une nouvelle plante
  Future<void> addPlante(Plante plante) async {
    await FirebaseFirestore.instance.collection('plantes').add(plante.toMap());
  }

   // Méthode pour mettre à jour une plante existante
  Future<void> updatePlante(DocumentReference docRef, Plante plante) async {
    await docRef.update(plante.toMap());
  }

 Future<void> deletePlante(DocumentReference docRef) async {
    await docRef.delete();
  }




  
}
