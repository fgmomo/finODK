import 'package:cloud_firestore/cloud_firestore.dart';

class RemedeMaladieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour récupérer les remèdes et maladies associés
  Stream<List<Map<String, dynamic>>> getRemedesAndMaladies() {
    return _firestore
        .collection('remede_maladie')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> remedesMaladies = [];

      for (var doc in snapshot.docs) {
        // Récupérer les références de maladie et remède
        DocumentReference maladieRef = doc['maladie_ref'];
        DocumentReference remedeRef = doc['remede_ref'];

        // Récupérer les données du remède et de la maladie
        DocumentSnapshot maladieSnapshot = await maladieRef.get();
        DocumentSnapshot remedeSnapshot = await remedeRef.get();

        // Vérifier que les deux documents existent
        if (maladieSnapshot.exists && remedeSnapshot.exists) {
          Map<String, dynamic> maladieData =
              maladieSnapshot.data() as Map<String, dynamic>;
          Map<String, dynamic> remedeData =
              remedeSnapshot.data() as Map<String, dynamic>;

          remedesMaladies.add({
            'maladie': maladieData,
            'remede': remedeData,
          'maladie_ref': maladieSnapshot.reference, // Assurez-vous que cela existe
      'remede_ref': remedeSnapshot.reference, // Assurez-vous que cela existe
          });
        }
      }
      return remedesMaladies;
    });
  }

  // Méthode pour dissocier un remède d'une maladie
Future<void> dissocierRemedeMaladie(DocumentReference remedeRef, DocumentReference maladieRef) async {
  final remedeMaladieRef = await _firestore
      .collection('remede_maladie')
      .where('remede_ref', isEqualTo: remedeRef)
      .where('maladie_ref', isEqualTo: maladieRef)
      .get();

  if (remedeMaladieRef.docs.isEmpty) {
    print('Aucun document trouvé pour dissociation.');
    return; // Sortir si aucun document n'est trouvé
  }

  for (var doc in remedeMaladieRef.docs) {
    await doc.reference.delete();
    print('Document supprimé: ${doc.id}');
  }
}

}
