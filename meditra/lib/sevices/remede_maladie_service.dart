import 'package:cloud_firestore/cloud_firestore.dart';

class RemedeMaladieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour récupérer les remèdes et maladies associés
  Stream<List<Map<String, dynamic>>> getRemedesAndMaladies() {
  return _firestore.collection('remede_maladie').snapshots().asyncMap((snapshot) async {
    // Récupérer tous les documents de remèdes et maladies en une seule fois
    final remedeRefs = snapshot.docs.map((doc) => doc['remede_ref']).toList();
    final maladieRefs = snapshot.docs.map((doc) => doc['maladie_ref']).toList();
    
    // Récupérer les remèdes et maladies en utilisant des Future
    final remedesFuture = Future.wait(remedeRefs.map((ref) => ref.get()));
    final maladiesFuture = Future.wait(maladieRefs.map((ref) => ref.get()));

    final remedesSnapshots = await remedesFuture;
    final maladiesSnapshots = await maladiesFuture;

    List<Map<String, dynamic>> remedesMaladies = [];

    for (int i = 0; i < snapshot.docs.length; i++) {
      final remedeData = remedesSnapshots[i].data();
      final maladieData = maladiesSnapshots[i].data();

      if (remedeData != null && maladieData != null) {
        remedesMaladies.add({
          'maladie': maladieData,
          'remede': remedeData,
          'maladie_ref': maladiesSnapshots[i].reference,
          'remede_ref': remedesSnapshots[i].reference,
        });
      }
    }

    return remedesMaladies;
  });
}


  // Méthode pour récupérer la liste des maladies
  Future<List<Map<String, dynamic>>> getMaladies() async {
    QuerySnapshot snapshot = await _firestore.collection('maladies').get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  // Méthode pour récupérer la liste des remèdes
  Future<List<Map<String, dynamic>>> getRemedes() async {
    QuerySnapshot snapshot = await _firestore.collection('remedes').get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  // Méthode pour associer un remède à une maladie
  Future<void> associerRemedeMaladie(String remedeId, String maladieId) async {
    try {
      // Vérifier si l'association existe déjà
      QuerySnapshot existingAssociation = await _firestore
          .collection('remede_maladie')
          .where('remede_ref',
              isEqualTo: _firestore.collection('remedes').doc(remedeId))
          .where('maladie_ref',
              isEqualTo: _firestore.collection('maladies').doc(maladieId))
          .get();

      if (existingAssociation.docs.isNotEmpty) {
        // Si l'association existe déjà, on renvoie une erreur
        throw Exception('Cette association existe déjà.');
      }

      // Si l'association n'existe pas, on procède à l'ajout
      await _firestore.collection('remede_maladie').add({
        'remede_ref': _firestore.collection('remedes').doc(remedeId),
        'maladie_ref': _firestore.collection('maladies').doc(maladieId),
      });
      print('Association réussie.');
    } catch (e) {
      // Gérer l'erreur et l'afficher
      print('Erreur lors de l\'association: $e');
      rethrow; // Relancer l'exception si nécessaire
    }
  }

  // Méthode pour dissocier un remède d'une maladie
  Future<void> dissocierRemedeMaladie(
      Map<String, dynamic> remedeMaladie) async {
    final remedeRef = remedeMaladie['remede_ref'];
    final maladieRef = remedeMaladie['maladie_ref'];

    if (remedeRef != null && maladieRef != null) {
      try {
        // Logique pour dissocier le remède et la maladie (suppression du document dans remede_maladie)
        await _firestore
            .collection('remede_maladie')
            .where('remede_ref', isEqualTo: remedeRef)
            .where('maladie_ref', isEqualTo: maladieRef)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
        print('Dissociation réussie.');
      } catch (e) {
        print('Erreur lors de la dissociation: $e');
      }
    } else {
      print('Erreur: Référence de remède ou de maladie est null.');
    }
  }
}
